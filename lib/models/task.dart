import 'task_category.dart';
import 'task_repeat.dart';
import 'subtask.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime date;
  final TaskCategory category;
  final TaskRepeat repeat;
  final List<String> completedDates;
  final List<Subtask> subtasks;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
    this.category = TaskCategory.none,
    this.repeat = TaskRepeat.none,
    List<String>? completedDates,
    List<Subtask>? subtasks,
  })  : completedDates = completedDates ?? [],
        subtasks = subtasks ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'category': category.index,
      'repeat': repeat.index,
      'completedDates': completedDates,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final int catIndex = json['category'] as int? ?? 0;
    final int repIndex = json['repeat'] as int? ?? 0;
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      date: DateTime.parse(json['date']),
      category: TaskCategory.values[
          catIndex >= 0 && catIndex < TaskCategory.values.length ? catIndex : 0],
      repeat: TaskRepeat.values[
          repIndex >= 0 && repIndex < TaskRepeat.values.length ? repIndex : 0],
      completedDates: (json['completedDates'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      subtasks: (json['subtasks'] as List<dynamic>? ?? [])
          .map((e) => Subtask.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
    TaskCategory? category,
    TaskRepeat? repeat,
    List<String>? completedDates,
    List<Subtask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      completedDates: completedDates ?? this.completedDates,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}