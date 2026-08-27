import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../models/task.dart';
import 'task_tile.dart';

class DaySection extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final bool isToday;
  final bool Function(Task) isTaskCompleted;
  final Function(String) onToggleTask;
  final Function(String) onDeleteTask;
  final Function(Task) onEditTask;
  final VoidCallback onAddTask;

  const DaySection({
    super.key,
    required this.date,
    required this.tasks,
    this.isToday = false,
    required this.isTaskCompleted,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final dayMonth = AppDateUtils.getDayMonth(date);
    final dayName = AppDateUtils.getShortDayName(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayMonth,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isToday ? primary : ext.textPrimary,
              ),
            ),
            Text(
              dayName,
              style: TextStyle(fontSize: 16, color: ext.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          color: isToday ? primary : ext.border,
        ),
        const SizedBox(height: 16),

        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No tasks for this day',
              style: TextStyle(
                fontSize: 16,
                color: ext.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...tasks.map((task) => Dismissible(
                key: Key(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                ),
                onDismissed: (direction) => onDeleteTask(task.id),
                child: TaskTile(
                  task: task,
                  completed: isTaskCompleted(task),
                  onToggle: () => onToggleTask(task.id),
                  onEdit: () => onEditTask(task),
                ),
              )),

        GestureDetector(
          onTap: onAddTask,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ext.border, width: 2),
                  ),
                  child: Icon(Icons.add, size: 16, color: ext.textTertiary),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Task',
                  style: TextStyle(fontSize: 16, color: ext.textTertiary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}