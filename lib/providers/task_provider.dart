import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/subtask.dart';
import '../models/task_category.dart';
import '../models/task_repeat.dart';
import '../core/utils/date_utils.dart';
import '../core/services/notification_service.dart';
import 'settings_provider.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<Task> get tasks => _tasks;

  TaskProvider() {
    SettingsProvider.tasksProvider = () => _tasks;
    _loadTasks();
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
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('weekflow_tasks', tasksString);
  }

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
      NotificationService.instance.scheduleForTask(_tasks[index]);
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
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    NotificationService.instance.scheduleForTask(task);
    _saveTasks();
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
      NotificationService.instance.scheduleForTask(_tasks[index]);
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    NotificationService.instance.cancelForTask(task);
    _tasks.removeWhere((t) => t.id == taskId);
    _saveTasks();
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
    notifyListeners();
  }

  void deleteSubtask(String taskId, String subtaskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    final list = List<Subtask>.from(task.subtasks)..removeWhere((s) => s.id == subtaskId);
    _tasks[index] = task.copyWith(subtasks: list);
    _saveTasks();
    notifyListeners();
  }
}