import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = const Color(0xFF5B6CFF);
  DayOfWeek _weekStartsOn = DayOfWeek.monday;
  bool _taskReminders = true;
  bool _dailySummary = false;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  DayOfWeek get weekStartsOn => _weekStartsOn;
  bool get taskReminders => _taskReminders;
  bool get dailySummary => _dailySummary;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  void setWeekStartsOn(DayOfWeek day) {
    _weekStartsOn = day;
    notifyListeners();
  }

  void setTaskReminders(bool value) {
    _taskReminders = value;
    notifyListeners();
  }

  void setDailySummary(bool value) {
    _dailySummary = value;
    notifyListeners();
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}