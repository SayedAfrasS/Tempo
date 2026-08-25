import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'shared/navigation/bottom_nav_bar.dart';

void main() {
  runApp(const WeekFlowApp());
}

class WeekFlowApp extends StatelessWidget {
  const WeekFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (!settingsProvider.isLoaded) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp(
            title: 'Tempo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(settingsProvider.theme),
            home: const BottomNavBar(),
          );
        },
      ),
    );
  }
}