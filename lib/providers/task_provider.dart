import 'package:flutter/material.dart';
import '../models/task.dart';
import '../core/utils/date_utils.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  TaskProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));

    _tasks = [
      // Today's tasks
      Task(
        id: '1',
        title: 'Complete DSA assignment',
        isCompleted: false,
        date: today,
        time: '6:00 PM',
      ),
      Task(
        id: '2',
        title: 'Practice Sliding Window',
        isCompleted: false,
        date: today,
        time: '8:00 PM',
      ),
      Task(
        id: '3',
        title: 'Finish ML preprocessing',
        isCompleted: true,
        date: today,
        time: 'Done',
      ),
      Task(
        id: '4',
        title: 'Read system design notes',
        isCompleted: false,
        date: today,
        time: '9:30 PM',
      ),
      // Tomorrow's tasks
      Task(
        id: '5',
        title: 'React project',
        isCompleted: false,
        date: tomorrow,
        time: '10:00 AM',
      ),
      // Day after tomorrow
      Task(
        id: '6',
        title: 'DBMS assignment',
        isCompleted: false,
        date: dayAfter,
        time: '5:00 PM',
      ),
    ];
  }

  List<Task> get tasks => _tasks;

  List<Task> getTodayTasks() {
    final today = DateTime.now();
    return _tasks.where((task) => AppDateUtils.isToday(task.date)).toList();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) =>
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day
    ).toList();
  }

  Map<DateTime, List<Task>> getWeekTasks(DateTime weekStart) {
    final weekDays = AppDateUtils.getWeekDays(weekStart);
    final Map<DateTime, List<Task>> tasksByDate = {};

    for (final day in weekDays) {
      tasksByDate[day] = getTasksForDate(day);
    }

    return tasksByDate;
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
      notifyListeners();
    }
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }
}