import 'package:flutter/services.dart';

class BatteryService {
  static const _channel = MethodChannel('tempo/battery');

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod('isIgnoringBatteryOptimizations') ?? false;
    } catch (e) {
      print('🔴 Battery check error: $e');
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
      print('🟢 Battery request sent to Android');
    } catch (e) {
      print('🔴 Battery request error: $e');
    }
  }
}