import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/task_category.dart';
import '../models/task_repeat.dart';
import '../core/services/notification_service.dart';
import 'settings_provider.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoaded = false;
  bool _syncing = false;

  bool get isLoaded => _isLoaded;
  List<Task> get tasks => _tasks;

  SupabaseClient get _client => Supabase.instance.client;
  bool get _signedIn => _client.auth.currentUser != null;

  TaskProvider() {
    SettingsProvider.tasksProvider = () => _tasks;
    _loadTasks();

    // ☁️ Sync automatically whenever the user signs in
    _client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        syncFromCloud();
      }
    });
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('weekflow_tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
    }
    await NotificationService.instance.scheduleAll(_tasks);
    _isLoaded = true;
    notifyListeners();
    if (_signedIn) syncFromCloud();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('weekflow_tasks', tasksString);
  }

  // ================= ☁️ CLOUD SYNC =================
  Future<void> syncFromCloud() async {
    if (!_signedIn || _syncing) return;
    _syncing = true;
    try {
      final userId = _client.auth.currentUser!.id;
      final rows = await _client.from('tasks').select().eq('user_id', userId);
      final cloudTasks = (rows as List)
          .map((r) => _fromRow(Map<String, dynamic>.from(r)))
          .toList();

      final cloudIds = cloudTasks.map((t) => t.id).toSet();
      final localOnly = _tasks.where((t) => !cloudIds.contains(t.id)).toList();

      _tasks = [...cloudTasks, ...localOnly];
      await _saveTasks();

      // Upload tasks created while offline
      for (final t in localOnly) {
        await _upload(t);
      }

      await NotificationService.instance.scheduleAll(_tasks);
      print('☁️ Synced ${_tasks.length} tasks from cloud');
    } catch (e) {
      print('⚠️ Sync error: $e');
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _toRow(Task task, String userId) {
    return {
      'id': task.id,
      'user_id': userId,
      'title': task.title,
      'is_completed': task.isCompleted,
      'task_date': task.date.toIso8601String(),
      'time': task.time,
      'category': task.category.index,
      'repeat_rule': task.repeat.index,
      'completed_dates': task.completedDates,
      'subtasks': task.subtasks.map((s) => s.toJson()).toList(),
    };
  }

  Task _fromRow(Map<String, dynamic> row) {
    final int catIndex = row['category'] ?? 0;
    final int repIndex = row['repeat_rule'] ?? 0;
    return Task(
      id: row['id'] as String,
      title: row['title'] as String,
      isCompleted: row['is_completed'] ?? false,
      date: DateTime.parse(row['task_date'] as String),
      time: row['time'] as String?,
      category: TaskCategory.values[
          catIndex >= 0 && catIndex < TaskCategory.values.length ? catIndex : 0],
      repeat: TaskRepeat.values[
          repIndex >= 0 && repIndex < TaskRepeat.values.length ? repIndex : 0],
      completedDates: List<String>.from(row['completed_dates'] ?? []),
      subtasks: (row['subtasks'] as List? ?? [])
          .map((e) => Subtask.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Future<void> _upload(Task task) async {
    if (!_signedIn) return;
    try {
      await _client
          .from('tasks')
          .upsert(_toRow(task, _client.auth.currentUser!.id));
    } catch (e) {
      print('⚠️ Upload error: $e');
    }
  }

  Future<void> _deleteFromCloud(String taskId) async {
    if (!_signedIn) return;
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      print('⚠️ Cloud delete error: $e');
    }
  }

  // ================= LOCAL + CLOUD MUTATIONS =================
  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool occursOn(Task task, DateTime date) {
    final start = DateTime(task.date.year, task.date.month, task.date.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(start)) return false;
    switch (task.repeat) {
      case TaskRepeat.none:
        return start == day;
      case TaskRepeat.daily:
        return true;
      case TaskRepeat.weekly:
        return day.weekday == start.weekday;
    }
  }

  bool isCompletedOn(Task task, DateTime date) {
    if (task.repeat == TaskRepeat.none) return task.isCompleted;
    return task.completedDates.contains(_dateKey(date));
  }

  List<Task> getTodayTasks() => getTasksForDate(DateTime.now());

  List<Task> getTasksForDate(DateTime date) =>
      _tasks.where((t) => occursOn(t, date)).toList();

  int getTodayCompletedCount() {
    final now = DateTime.now();
    return getTasksForDate(now).where((t) => isCompletedOn(t, now)).length;
  }

  int getTodayTotalCount() => getTodayTasks().length;

  double getTodayCompletionPercentage() {
    final total = getTodayTotalCount();
    if (total == 0) return 0.0;
    return getTodayCompletedCount() / total;
  }

  void toggleTaskOn(String taskId, DateTime date) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];

    if (task.repeat == TaskRepeat.none) {
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    } else {
      final key = _dateKey(date);
      final list = List<String>.from(task.completedDates);
      if (list.contains(key)) {
        list.remove(key);
      } else {
        list.add(key);
      }
      _tasks[index] = task.copyWith(completedDates: list);
    }
    _saveTasks();
    _upload(_tasks[index]);
    NotificationService.instance.scheduleForTask(_tasks[index]);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    _upload(task);
    NotificationService.instance.scheduleForTask(task);
    notifyListeners();
  }

  void updateTask(String taskId,
      {String? title,
      DateTime? date,
      TaskCategory? category,
      TaskRepeat? repeat,
      String? time = Task.noTime}) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title ?? _tasks[index].title,
        date: date ?? _tasks[index].date,
        category: category ?? _tasks[index].category,
        repeat: repeat ?? _tasks[index].repeat,
        time: time,
      );
      _saveTasks();
      _upload(_tasks[index]);
      NotificationService.instance.scheduleForTask(_tasks[index]);
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    NotificationService.instance.cancelForTask(task);
    _tasks.removeWhere((t) => t.id == taskId);
    _saveTasks();
    _deleteFromCloud(taskId);
    notifyListeners();
  }

  void addSubtask(String taskId, String title) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1 || title.trim().isEmpty) return;
    final task = _tasks[index];
    final list = List<Subtask>.from(task.subtasks);
    list.add(Subtask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    ));
    _tasks[index] = task.copyWith(subtasks: list);
    _saveTasks();
    _upload(_tasks[index]);
    notifyListeners();
  }

  void toggleSubtask(String taskId, String subtaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    final list = task.subtasks
        .map((s) => s.id == subtaskId ? s.copyWith(isCompleted: !s.isCompleted) : s)
        .toList();
    _tasks[index] = task.copyWith(subtasks: list);
    _saveTasks();
    _upload(_tasks[index]);
    notifyListeners();
  }

  void deleteSubtask(String taskId, String subtaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    final list = List<Subtask>.from(task.subtasks)
      ..removeWhere((s) => s.id == subtaskId);
    _tasks[index] = task.copyWith(subtasks: list);
    _saveTasks();
    _upload(_tasks[index]);
    notifyListeners();
  }
}