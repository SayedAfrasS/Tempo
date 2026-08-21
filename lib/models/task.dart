class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime date;
  final String? time;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
    this.time,
  });

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? date,
    String? time,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}