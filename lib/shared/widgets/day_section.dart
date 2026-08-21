import 'package:flutter/material.dart';
import '../../core/colors/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task.dart';
import 'task_tile.dart';

class DaySection extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final bool isToday;
  final Function(String) onToggleTask;
  final VoidCallback onAddTask;

  const DaySection({
    super.key,
    required this.date,
    required this.tasks,
    this.isToday = false,
    required this.onToggleTask,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final dayMonth = AppDateUtils.getDayMonth(date);
    final dayName = AppDateUtils.getShortDayName(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayMonth,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isToday ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            Text(
              dayName,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Divider
        Container(
          height: 2,
          color: isToday ? AppColors.primary : AppColors.borderLight,
        ),
        const SizedBox(height: 16),

        // Tasks
        ...tasks.map((task) => TaskTile(
          task: task,
          onToggle: () => onToggleTask(task.id),
        )),

        // Add Task
        if (tasks.isEmpty || tasks.length < 3)
          GestureDetector(
            onTap: onAddTask,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }
}