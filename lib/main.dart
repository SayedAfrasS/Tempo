import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/colors/app_colors.dart';
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
      child: MaterialApp(
        title: 'WeekFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.textSecondary,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
        ),
        home: const BottomNavBar(),
      ),
    );
  }
}