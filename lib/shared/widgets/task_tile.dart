import 'package:flutter/material.dart';
import '../../core/colors/app_colors.dart';
import '../../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  color: task.isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.black
                        : AppColors.grayLight,
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? AppColors.black
                      : AppColors.white,
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 14,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}