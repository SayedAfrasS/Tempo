import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/battery_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../../../shared/widgets/theme_picker_bottom_sheet.dart';
import '../../../shared/widgets/settings_sheets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        backgroundColor: ext.background,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (!settings.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final supaName = ((Supabase.instance.client.auth.currentUser
                      ?.userMetadata?['full_name'] as String? ??
                  '')
              .trim());

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SettingsSectionHeader(title: 'APPEARANCE'),
              SettingsTile(
                title: 'Theme',
                trailing: _trailingText(context, settings.theme.name),
                onTap: () => _showSheet(context, const ThemePickerBottomSheet()),
              ),

              const SettingsSectionHeader(title: 'PLANNER'),
              SettingsTile(
                title: 'Week starts on',
                trailing: _trailingText(
                  context,
                  settings.weekStartsOn == WeekStart.monday ? 'Monday' : 'Sunday',
                ),
                onTap: () => _showSheet(context, const WeekStartPickerSheet()),
              ),

              const SettingsSectionHeader(title: 'NOTIFICATIONS'),
              SettingsTile(
                title: 'Task reminders',
                trailing: Switch(
                  value: settings.taskReminders,
                  onChanged: settings.setTaskReminders,
                ),
              ),
              if (settings.taskReminders) ...[
                const _BatteryTile(),
                SettingsTile(
                  title: 'Allow Exact Alarms',
                  trailing: const Icon(Icons.alarm, color: Colors.blue),
                  onTap: () async {
                    await BatteryService.openExactAlarmSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Turn ON the switch for Tempo/WeekFlow, then come back!'),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  title: 'Test Reminder (15s)',
                  trailing: const Icon(Icons.timer, color: Colors.orange),
                  onTap: () async {
                    await NotificationService.instance.testScheduledReminder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alarm set! Wait 15 seconds...'),
                      ),
                    );
                  },
                ),
              ],

              const SettingsSectionHeader(title: 'ACCOUNT'),
              SettingsTile(
                title: 'Profile',
                trailing: _trailingText(
                  context,
                  supaName.isEmpty ? 'View' : supaName,
                ),
                onTap: () => _showSheet(context, const ProfileSheet()),
              ),
              SettingsTile(
                title: 'Sign out',
                trailing: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                },
              ),

              const SettingsSectionHeader(title: 'ABOUT'),
              SettingsTile(
                title: 'About Tempo',
                trailing: _trailingText(context, '1.0.0'),
                onTap: () => _showSheet(context, const AboutWeekFlowSheet()),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _trailingText(BuildContext context, String text) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ext.textTertiary),
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.chevron_right, color: ext.textTertiary),
      ],
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }
}

class _BatteryTile extends StatefulWidget {
  const _BatteryTile();

  @override
  State<_BatteryTile> createState() => _BatteryTileState();
}

class _BatteryTileState extends State<_BatteryTile> with WidgetsBindingObserver {
  bool? _ok;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final v = await BatteryService.isIgnoringBatteryOptimizations();
    if (mounted) setState(() => _ok = v);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final ok = _ok ?? false;

    return SettingsTile(
      title: 'Battery boost',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ok ? 'On ✅' : 'Tap to enable',
            style:
                TextStyle(color: ok ? const Color(0xFF22C55E) : ext.textTertiary),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: ext.textTertiary),
        ],
      ),
      onTap: () async {
        if (!ok) await BatteryService.requestIgnoreBatteryOptimizations();
      },
    );
  }
}