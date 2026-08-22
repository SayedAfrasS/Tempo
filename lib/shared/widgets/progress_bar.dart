import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;

  const CustomProgressBar({super.key, required this.progress, this.color});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: ext.primaryLight,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}