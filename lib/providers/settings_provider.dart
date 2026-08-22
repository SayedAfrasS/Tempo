import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class SettingsProvider with ChangeNotifier {
  WeekFlowTheme _theme = AppThemes.jay;
  WeekStart _weekStartsOn = WeekStart.monday;
  bool _taskReminders = true;
  ReminderCycle _reminderCycle = ReminderCycle.hours2;
  String _userName = '';
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  WeekFlowTheme get theme => _theme;
  WeekStart get weekStartsOn => _weekStartsOn;
  bool get taskReminders => _taskReminders;
  ReminderCycle get reminderCycle => _reminderCycle;
  String get userName => _userName;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeId = prefs.getString('theme_id') ?? 'jay';
    _theme = AppThemes.all.firstWhere(
      (t) => t.id == themeId,
      orElse: () => AppThemes.jay,
    );

    final weekIndex = prefs.getInt('week_starts_on') ?? 0;
    _weekStartsOn = WeekStart.values[weekIndex];

    _taskReminders = prefs.getBool('task_reminders') ?? true;

    final cycleIndex = prefs.getInt('reminder_cycle') ?? 0;
    _reminderCycle = ReminderCycle.values[cycleIndex];

    _userName = prefs.getString('user_name') ?? '';

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', _theme.id);
    await prefs.setInt('week_starts_on', _weekStartsOn.index);
    await prefs.setBool('task_reminders', _taskReminders);
    await prefs.setInt('reminder_cycle', _reminderCycle.index);
    await prefs.setString('user_name', _userName);
  }

  void setTheme(WeekFlowTheme theme) {
    _theme = theme;
    _saveSettings();
    notifyListeners();
  }

  void setWeekStartsOn(WeekStart day) {
    _weekStartsOn = day;
    _saveSettings();
    notifyListeners();
  }

  void setTaskReminders(bool value) {
    _taskReminders = value;
    _saveSettings();
    notifyListeners();
  }

  void setReminderCycle(ReminderCycle cycle) {
    _reminderCycle = cycle;
    _saveSettings();
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    _saveSettings();
    notifyListeners();
  }
}

enum WeekStart { monday, sunday }

enum ReminderCycle { hours2, hours4, hours6, hours8 }