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
  bool _initialized = false;

  void configure({required bool enabled}) {
    final wasEnabled = _enabled;
    _enabled = enabled;
    if (!enabled && wasEnabled) cancelAll();
  }

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      print('🌍 Timezone: ${tzInfo.identifier}');
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

    final bool? notificationsAllowed = await android?.areNotificationsEnabled();
    print('🔔 Notifications allowed: $notificationsAllowed');
    if (notificationsAllowed == false) {
      await android?.requestNotificationsPermission();
    }

    _initialized = true;
    print('✅ NotificationService ready');
  }

  int _baseId(Task task) {
    final String id = task.id;
    final String digits = id.length > 6 ? id.substring(id.length - 6) : id;
    return int.tryParse(digits) ?? digits.hashCode.abs() % 1000000;
  }

  DateTime? _reminderTime(Task task) {
    if (task.time == null || task.time!.isEmpty) return null;
    try {
      final DateTime parsed = DateFormat('h:mm a', 'en_US').parse(task.time!);
      return DateTime(task.date.year, task.date.month, task.date.day,
          parsed.hour, parsed.minute);
    } catch (e) {
      print('❌ Time parse error: $e');
      return null;
    }
  }

  Future<void> scheduleForTask(Task task) async {
    print('🔔 scheduleForTask called for: ${task.title}');

    if (!_initialized || !_enabled || task.isCompleted) {
      print('⛔ Skipped (disabled/completed)');
      await cancelForTask(task);
      return;
    }

    final DateTime? when = _reminderTime(task);
    print('⏰ Calculated time: $when');

    if (when == null) {
      print('⛔ Skipped (no time set)');
      await cancelForTask(task);
      return;
    }

    await cancelForTask(task);

    final now = DateTime.now();
    print('⏳ Comparing $when vs $now');
    if (!when.isAfter(now)) {
        print('⛔ Skipped (time is in the past)');
        return;
    }

    print('✅ CALLING zonedSchedule for ID ${_baseId(task)} at $when');
    await _scheduleAt(_baseId(task), task.title, when);
  }

  Future<void> _scheduleAt(int id, String title, DateTime when) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: 'Time to work on this task ✅',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tempo_reminders_final_v7',
          'Task reminders',
          channelDescription: 'Reminders for your tasks',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelForTask(Task task) async {
    await _plugin.cancel(id: _baseId(task));
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

  Future<void> testScheduledReminder() async {
    if (!_initialized) await init();
    print('🧪 Showing immediate test notification...');
    await _plugin.show(
      id: 99999,
      title: 'Tempo Reminder Test ⏰',
      body: 'If you see this instantly, the notification engine works!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'tempo_test_final_v7',
          'Test reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
    print('✅ Immediate notification sent');
  }
}