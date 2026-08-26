import 'package:flutter/material.dart';

enum TaskCategory {
  none,
  personal,
  study,
  work,
  health,
}

extension TaskCategoryX on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.none:
        return 'None';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.health:
        return 'Health';
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.none:
        return const Color(0xFF9CA3AF);
      case TaskCategory.personal:
        return const Color(0xFF5B6CFF);
      case TaskCategory.study:
        return const Color(0xFFA855F7);
      case TaskCategory.work:
        return const Color(0xFFF97316);
      case TaskCategory.health:
        return const Color(0xFF22C55E);
    }
  }
}