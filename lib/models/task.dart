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

  // Convert Task to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'time': time,
    };
  }

  // Convert JSON back to Task when loading
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      date: DateTime.parse(json['date']),
      time: json['time'],
    );
  }

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