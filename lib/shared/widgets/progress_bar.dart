import 'package:flutter/material.dart';
import '../../core/colors/app_colors.dart';

class CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;

  const CustomProgressBar({
    super.key,
    required this.progress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}