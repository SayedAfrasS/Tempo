enum TaskRepeat { none, daily, weekly }

extension TaskRepeatX on TaskRepeat {
  String get label {
    switch (this) {
      case TaskRepeat.none:
        return 'None';
      case TaskRepeat.daily:
        return 'Daily';
      case TaskRepeat.weekly:
        return 'Weekly';
    }
  }
}