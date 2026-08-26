import 'task_category.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime date;
  final TaskCategory category;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
    this.category = TaskCategory.none,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'category': category.index,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final int catIndex = json['category'] as int? ?? 0;
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      date: DateTime.parse(json['date']),
      category: TaskCategory.values[
          catIndex >= 0 && catIndex < TaskCategory.values.length ? catIndex : 0],
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
    TaskCategory? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }
}