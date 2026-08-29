import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/battery_service.dart';
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

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // APPEARANCE
              const SettingsSectionHeader(title: 'APPEARANCE'),
              SettingsTile(
                title: 'Theme',
                trailing: _trailingText(context, settings.theme.name),
                onTap: () => _showSheet(context, const ThemePickerBottomSheet()),
              ),

              // PLANNER
              const SettingsSectionHeader(title: 'PLANNER'),
              SettingsTile(
                title: 'Week starts on',
                trailing: _trailingText(
                  context,
                  settings.weekStartsOn == WeekStart.monday ? 'Monday' : 'Sunday',
                ),
                onTap: () => _showSheet(context, const WeekStartPickerSheet()),
              ),

              // NOTIFICATIONS
              const SettingsSectionHeader(title: 'NOTIFICATIONS'),
              SettingsTile(
                title: 'Task reminders',
                trailing: Switch(
                  value: settings.taskReminders,
                  onChanged: settings.setTaskReminders,
                ),
              ),
              if (settings.taskReminders) ...[
                SettingsTile(
                  title: 'Reminder cycle',
                  trailing: _trailingText(context, _cycleName(settings.reminderCycle)),
                  onTap: () => _showSheet(context, const ReminderCyclePickerSheet()),
                ),
                const _BatteryTile(),
              ],

              // ACCOUNT
              const SettingsSectionHeader(title: 'ACCOUNT'),
              SettingsTile(
                title: 'Profile',
                trailing: _trailingText(
                  context,
                  settings.userName.isEmpty ? 'Set name' : settings.userName,
                ),
                onTap: () => _showSheet(context, const ProfileSheet()),
              ),

              // ABOUT
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
        Text(text, style: TextStyle(color: ext.textTertiary)),
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

  String _cycleName(ReminderCycle cycle) {
    switch (cycle) {
      case ReminderCycle.hours2: return '2 hr';
      case ReminderCycle.hours4: return '4 hr';
      case ReminderCycle.hours6: return '6 hr';
      case ReminderCycle.hours8: return '8 hr';
    }
  }
}

// ---------- Battery Boost tile ----------
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
            style: TextStyle(color: ok ? const Color(0xFF22C55E) : ext.textTertiary),
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