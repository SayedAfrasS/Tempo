import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class _SheetScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SheetScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ext.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: ext.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ext.textPrimary)),
          const SizedBox(height: 24),
          ...children,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ext.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primary : ext.textTertiary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? primary : ext.textPrimary)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: ext.textTertiary)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class WeekStartPickerSheet extends StatelessWidget {
  const WeekStartPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SheetScaffold(
      title: 'Week starts on',
      children: [
        _OptionTile(
          icon: LucideIcons.calendar,
          title: 'Monday',
          subtitle: 'Start your week on Monday',
          isSelected: settings.weekStartsOn == WeekStart.monday,
          onTap: () {
            settings.setWeekStartsOn(WeekStart.monday);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: LucideIcons.sun,
          title: 'Sunday',
          subtitle: 'Start your week on Sunday',
          isSelected: settings.weekStartsOn == WeekStart.sunday,
          onTap: () {
            settings.setWeekStartsOn(WeekStart.sunday);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ReminderCyclePickerSheet extends StatelessWidget {
  const ReminderCyclePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SheetScaffold(
      title: 'Reminder cycle',
      children: [
        _OptionTile(
          icon: LucideIcons.bell,
          title: '2 hours',
          subtitle: 'Remind every 2 hours (9am – 10pm)',
          isSelected: settings.reminderCycle == ReminderCycle.hours2,
          onTap: () {
            settings.setReminderCycle(ReminderCycle.hours2);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: LucideIcons.bell,
          title: '4 hours',
          subtitle: 'Remind every 4 hours (9am – 10pm)',
          isSelected: settings.reminderCycle == ReminderCycle.hours4,
          onTap: () {
            settings.setReminderCycle(ReminderCycle.hours4);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: LucideIcons.bell,
          title: '6 hours',
          subtitle: 'Remind every 6 hours (9am – 10pm)',
          isSelected: settings.reminderCycle == ReminderCycle.hours6,
          onTap: () {
            settings.setReminderCycle(ReminderCycle.hours6);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: LucideIcons.bell,
          title: '8 hours',
          subtitle: 'Remind every 8 hours (9am – 10pm)',
          isSelected: settings.reminderCycle == ReminderCycle.hours8,
          onTap: () {
            settings.setReminderCycle(ReminderCycle.hours8);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text =
        Provider.of<SettingsProvider>(context, listen: false).userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    context.read<SettingsProvider>().setUserName(_nameController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final settings = context.watch<SettingsProvider>();
    final displayName = settings.userName.isEmpty ? 'Tempo User' : settings.userName;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ext.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: ext.border, borderRadius: BorderRadius.circular(2)),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: primary,
            child: Text(
              displayName[0].toUpperCase(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(displayName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ext.textPrimary)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: TextStyle(color: ext.textPrimary),
            decoration: InputDecoration(
              labelText: 'Your name',
              hintText: 'Enter your name',
              filled: true,
              fillColor: ext.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ext.surface,
                    foregroundColor: ext.textPrimary,
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AboutWeekFlowSheet extends StatelessWidget {
  const AboutWeekFlowSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return _SheetScaffold(
      title: 'About Tempo',
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(18)),
            child: const Icon(LucideIcons.calendar, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        Text('Tempo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ext.textPrimary)),
        const SizedBox(height: 4),
        Text('Version 1.0.0', style: TextStyle(fontSize: 13, color: ext.textTertiary)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: ext.surface, borderRadius: BorderRadius.circular(12)),
          child: Text(
            'A minimal weekly planner & todo app to plan your week, stay focused and get things done.',
            style: TextStyle(fontSize: 14, height: 1.5, color: ext.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        _AboutRow(icon: Icons.favorite, text: 'Made with love by Sayed Afras'),
        const SizedBox(height: 10),
        _AboutRow(icon: Icons.code, text: 'Built with Flutter'),
        const SizedBox(height: 10),
        _AboutRow(icon: Icons.palette, text: 'Designed with the 60-30-10 color rule'),
        const SizedBox(height: 10),
        _AboutRow(icon: Icons.lock, text: 'Your data stays safely on your device'),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AboutRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Row(
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}