import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/week_planner/presentation/week_planner_screen.dart';
import '../../features/month/presentation/month_view_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WeekPlannerScreen(),
    MonthViewScreen(),
    TodayScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ext.background,
          border: Border(top: BorderSide(color: ext.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: ext.background,
          selectedItemColor: primary,
          unselectedItemColor: ext.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(LucideIcons.home, size: 24), label: 'Week'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.calendar, size: 24), label: 'Month'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.sun, size: 24), label: 'Today'),
            BottomNavigationBarItem(icon: Icon(LucideIcons.settings, size: 24), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}