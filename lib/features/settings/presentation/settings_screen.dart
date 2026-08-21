import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/colors/app_colors.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // APPEARANCE
                const SettingsSectionHeader(title: 'APPEARANCE'),
                SettingsTile(
                  title: 'Theme',
                  subtitle: 'System',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'System',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Show theme picker
                  },
                ),
                SettingsTile(
                  title: 'Accent Color',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Show color picker
                  },
                ),

                // PLANNER
                const SettingsSectionHeader(title: 'PLANNER'),
                SettingsTile(
                  title: 'Week starts on',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Monday',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Show day picker
                  },
                ),

                // NOTIFICATIONS
                const SettingsSectionHeader(title: 'NOTIFICATIONS'),
                SettingsTile(
                  title: 'Task reminders',
                  trailing: Switch(
                    value: settingsProvider.taskReminders,
                    onChanged: (value) {
                      settingsProvider.setTaskReminders(value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),

                // ACCOUNT
                const SettingsSectionHeader(title: 'ACCOUNT'),
                SettingsTile(
                  title: 'Profile',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onTap: () {
                    // TODO: Navigate to profile
                  },
                ),
                SettingsTile(
                  title: 'Sign out',
                  titleColor: AppColors.error,
                  onTap: () {
                    // TODO: Implement sign out
                  },
                ),

                // ABOUT
                const SettingsSectionHeader(title: 'ABOUT'),
                SettingsTile(
                  title: 'About Minimal Planner',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '1.0.0',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}