import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/task_category.dart';
import '../core/utils/date_utils.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('weekflow_tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('weekflow_tasks', tasksString);
  }

  List<Task> getTodayTasks() {
    return _tasks.where((task) => AppDateUtils.isToday(task.date)).toList();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) =>
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day
    ).toList();
  }

  int getTodayCompletedCount() {
    return getTodayTasks().where((task) => task.isCompleted).length;
  }

  int getTodayTotalCount() {
    return getTodayTasks().length;
  }

  double getTodayCompletionPercentage() {
    final total = getTodayTotalCount();
    if (total == 0) return 0.0;
    return getTodayCompletedCount() / total;
  }

  void toggleTask(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(String taskId, {String? title, DateTime? date, TaskCategory? category}) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title ?? _tasks[index].title,
        date: date ?? _tasks[index].date,
        category: category ?? _tasks[index].category,
      );
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }
}