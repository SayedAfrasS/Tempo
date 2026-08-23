import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../../models/task.dart';

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
    if (!enabled && wasEnabled) {
      cancelAll();
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      // FIX 1: flutter_timezone now returns a TimezoneInfo object
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    // FIX 2: initialize() now uses named arguments (settings:)
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final AndroidFlutterLocalNotificationsPlugin? android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    _initialized = true;
  }

  int _baseId(Task task) {
    final String id = task.id;
    final String digits = id.length > 7 ? id.substring(id.length - 7) : id;
    return int.tryParse(digits) ?? digits.hashCode.abs() % 1000000;
  }

  DateTime _taskDateTime(Task task) {
    final DateTime day = task.date;
    DateTime dt = DateTime(day.year, day.month, day.day, 9, 0);
    if (task.time != null && task.time!.isNotEmpty) {
      try {
        final DateTime parsed = DateFormat('h:mm a').parse(task.time!);
        dt = DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
      } catch (_) {}
    }
    return dt;
  }

  Future<void> scheduleForTask(Task task) async {
    if (!_initialized || !_enabled || task.isCompleted) {
      await cancelForTask(task);
      return;
    }

    await cancelForTask(task);

    final DateTime first = _taskDateTime(task);
    final DateTime dayEnd = DateTime(first.year, first.month, first.day, 22, 0);

    final List<DateTime> times = [first];
    DateTime next = first;
    while (times.length < 4) {
      next = next.add(Duration(hours: _cycleHours));
      if (next.isAfter(dayEnd)) break;
      times.add(next);
    }

    for (int i = 0; i < times.length; i++) {
      final DateTime when = times[i];
      if (!when.isAfter(DateTime.now())) continue;

      // FIX 3 & 4: zonedSchedule() now uses named arguments, and
      // uiLocalNotificationDateInterpretation was removed in v18+
      await _plugin.zonedSchedule(
        id: _baseId(task) + i,
        title: i == 0 ? 'Task due now' : 'Still pending',
        body: i == 0 ? task.title : '${task.title} — don\'t forget!',
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekflow_tasks',
            'Task reminders',
            channelDescription: 'Reminders for your scheduled tasks',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelForTask(Task task) async {
    final int base = _baseId(task);
    for (int i = 0; i < 4; i++) {
      // FIX 5: cancel() now uses named arguments (id:)
      await _plugin.cancel(id: base + i);
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