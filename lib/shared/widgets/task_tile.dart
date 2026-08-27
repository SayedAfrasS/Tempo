import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task.dart';
import '../../models/task_category.dart';
import '../../models/task_repeat.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.completed,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final hasCategory = task.category != TaskCategory.none;
    final isRecurring = task.repeat != TaskRepeat.none;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: hasCategory
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: task.category.color.withOpacity(completed ? 0.10 : 0.22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: completed ? ext.textTertiary : ext.textPrimary,
                                decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ),
                          if (isRecurring)
                            Icon(LucideIcons.repeat, size: 13, color: ext.textTertiary),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              color: completed ? ext.textTertiary : ext.textPrimary,
                              decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (isRecurring)
                          Icon(LucideIcons.repeat, size: 13, color: ext.textTertiary),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: completed ? primary : ext.border, width: 2),
                color: completed ? primary : ext.background,
              ),
              child: completed ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ),
        ],
      ),
    );
  }
}