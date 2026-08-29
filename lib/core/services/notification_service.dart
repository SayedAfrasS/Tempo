import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../models/task.dart';
import '../../models/task_repeat.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _enabled = true;
  int _cycleHours = 2;
  bool _initialized = false;

  void configure({required bool enabled, required int cycleHours}) {
    final wasEnabled = _enabled;
    _enabled = enabled;
    _cycleHours = cycleHours;
    if (!enabled && wasEnabled) cancelAll();
  }

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {}

    _initialized = true;
  }

  int _baseId(Task task) {
    final String id = task.id;
    final String digits = id.length > 6 ? id.substring(id.length - 6) : id;
    return int.tryParse(digits) ?? digits.hashCode.abs() % 1000000;
  }

  int _idFor(Task task, int dayOffset, int slot) =>
      _baseId(task) * 100 + dayOffset * 10 + slot;

  Future<void> scheduleForTask(Task task) async {
    if (!_initialized || !_enabled || task.isCompleted) {
      await cancelForTask(task);
      return;
    }

    await cancelForTask(task);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(task.date.year, task.date.month, task.date.day);

    // Which days need reminders? (7-day horizon for recurring tasks)
    final List<DateTime> days = [];
    if (task.repeat == TaskRepeat.none) {
      if (!start.isBefore(today)) days.add(start);
    } else {
      for (int d = 0; d < 7; d++) {
        final day = today.add(Duration(days: d));
        if (day.isBefore(start)) continue;
        if (task.repeat == TaskRepeat.weekly && day.weekday != start.weekday) continue;
        days.add(day);
      }
    }

    bool scheduledAny = false;
    for (final day in days) {
      final dayOffset = day.difference(today).inDays;
      DateTime slot = DateTime(day.year, day.month, day.day, 9, 0);
      final end = DateTime(day.year, day.month, day.day, 22, 0);

      for (int i = 0; i < 4; i++) {
        if (slot.isAfter(end)) break;
        if (slot.isAfter(now)) {
          await _scheduleAt(task, dayOffset, i, slot);
          scheduledAny = true;
        }
        slot = slot.add(Duration(hours: _cycleHours));
      }
    }

    // Overdue nudge: one-time task due today, all times passed
    if (!scheduledAny && task.repeat == TaskRepeat.none && start == today) {
      await _scheduleAt(task, 0, 0, now.add(const Duration(minutes: 1)));
    }
  }

  Future<void> _scheduleAt(Task task, int dayOffset, int slot, DateTime when) async {
    await _plugin.zonedSchedule(
      id: _idFor(task, dayOffset, slot),
      title: task.title,
      body: 'Time to work on this task ✅',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tempo_tasks',
          'Task reminders',
          channelDescription: 'Reminders for your tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelForTask(Task task) async {
    for (int d = 0; d < 7; d++) {
      for (int i = 0; i < 4; i++) {
        await _plugin.cancel(id: _idFor(task, d, i));
      }
    }
  }

  Future<void> scheduleAll(List<Task> tasks) async {
    if (!_enabled || !_initialized) return;
    for (final t in tasks) {
      await scheduleForTask(t);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}