import 'package:flutter/material.dart';

// A theme built with the 60:30:10 rule
class WeekFlowTheme {
  final String id;
  final String name;
  final Color background; // 60%
  final Color surface;    // 30%
  final Color accent;     // 10%
  final bool isDark;

  const WeekFlowTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.accent,
    this.isDark = false,
  });
}

class AppThemes {
  static const WeekFlowTheme jay = WeekFlowTheme(
    id: 'jay', name: 'Jay',
    background: Color(0xFFFFFFFF), surface: Color(0xFFEEF1FF), accent: Color(0xFF5B6CFF),
  );
  static const WeekFlowTheme tweek = WeekFlowTheme(
    id: 'tweek', name: 'Tweek',
    background: Color(0xFFFFFEF7), surface: Color(0xFFFFF3CC), accent: Color(0xFFD99A06),
  );
  static const WeekFlowTheme tody = WeekFlowTheme(
    id: 'tody', name: 'Tody',
    background: Color(0xFFF8FCF9), surface: Color(0xFFDFF3E7), accent: Color(0xFF16A34A),
  );
  static const WeekFlowTheme finch = WeekFlowTheme(
    id: 'finch', name: 'Finch',
    background: Color(0xFFFFFBF7), surface: Color(0xFFFFE7D1), accent: Color(0xFFF97316),
  );
  static const WeekFlowTheme sora = WeekFlowTheme(
    id: 'sora', name: 'Sora',
    background: Color(0xFFF7FAFC), surface: Color(0xFFDFEDF6), accent: Color(0xFF0EA5E9),
  );
  static const WeekFlowTheme weka = WeekFlowTheme(
    id: 'weka', name: 'Weka',
    background: Color(0xFFFBF9F5), surface: Color(0xFFF0E7D9), accent: Color(0xFF8B5E34),
  );
  static const WeekFlowTheme ruff = WeekFlowTheme(
    id: 'ruff', name: 'Ruff',
    background: Color(0xFFFEF7FA), surface: Color(0xFFFBE9F0), accent: Color(0xFFE11D48),
  );

  static const List<WeekFlowTheme> all = [jay, tweek, tody, finch, sora, weka, ruff];
}

class AppTheme {
  // Picks readable text color on top of the accent (white or black)
  static Color _onColor(Color color) =>
      color.computeLuminance() > 0.45 ? const Color(0xFF111111) : const Color(0xFFFFFFFF);

  static ThemeData getTheme(WeekFlowTheme t) {
    final Color textPrimary = t.isDark ? const Color(0xFFF5F5F5) : const Color(0xFF111111);
    final Color textSecondary = t.isDark ? const Color(0xFFB3B3B3) : const Color(0xFF6E6E6E);
    final Color textTertiary = t.isDark ? const Color(0xFF8A8A8A) : const Color(0xFF9CA3AF);
    final Color border = t.isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEBEBEB);
    final Color onAccent = _onColor(t.accent);

    return ThemeData(
      useMaterial3: true,
      brightness: t.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: t.background,
      primaryColor: t.accent,
      colorScheme: ColorScheme(
        brightness: t.isDark ? Brightness.dark : Brightness.light,
        primary: t.accent,
        onPrimary: onAccent,
        secondary: t.surface,
        onSecondary: textPrimary,
        surface: t.surface,
        onSurface: textPrimary,
        error: const Color(0xFFEF4444),
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.background,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.background,
        selectedItemColor: t.accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? t.accent
            : (t.isDark ? const Color(0xFF808080) : const Color(0xFF9CA3AF))),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected)
            ? t.accent.withOpacity(0.5)
            : (t.isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE5E7EB))),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
      ),
      extensions: [
        AppThemeExtension(
          primaryLight: t.accent.withOpacity(t.isDark ? 0.18 : 0.12),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          textTertiary: textTertiary,
          border: border,
          background: t.background,
          surface: t.surface,
        ),
      ],
    );
  }
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color background;
  final Color surface;

  AppThemeExtension({
    required this.primaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.background,
    required this.surface,
  });

  @override
  AppThemeExtension copyWith({
    Color? primaryLight, Color? textPrimary, Color? textSecondary,
    Color? textTertiary, Color? border, Color? background, Color? surface,
  }) {
    return AppThemeExtension(
      primaryLight: primaryLight ?? this.primaryLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      background: background ?? this.background,
      surface: surface ?? this.surface,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }
}