import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';

class ThemePickerBottomSheet extends StatelessWidget {
  const ThemePickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
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
          Text('Theme', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ext.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Every theme follows the 60-30-10 color rule.',
            style: TextStyle(fontSize: 13, color: ext.textTertiary),
          ),
          const SizedBox(height: 24),
          ...AppThemes.all.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ThemeTile(
                theme: t,
                isSelected: settings.theme.id == t.id,
                onTap: () {
                  settings.setTheme(t);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final WeekFlowTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.theme,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ext.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // 60:30:10 swatch bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(width: 54, height: 36, color: theme.background), // 60%
                  Container(width: 27, height: 36, color: theme.surface),    // 30%
                  Container(width: 9, height: 36, color: theme.accent),      // 10%
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ext.textPrimary),
                  ),
                  Text(
                    '60-30-10 palette',
                    style: TextStyle(fontSize: 12, color: ext.textTertiary),
                  ),
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