import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart'; // Replaced AppColors
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/task_tile.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/task_bottom_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        backgroundColor: ext.background,
        elevation: 0,
        title: Text(
          'Today',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ext.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.calendar,
              color: ext.textPrimary,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.getTodayTasks();
          final completed = taskProvider.getTodayCompletedCount();
          final total = taskProvider.getTodayTotalCount();
          final percentage = taskProvider.getTodayCompletionPercentage();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSection(ext),
                const SizedBox(height: 32),
                _buildProgressSection(ext, completed, total, percentage),
                const SizedBox(height: 32),
                _buildTaskList(context, tasks, taskProvider),
                const SizedBox(height: 16),
                _buildAddTask(context, ext),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection(AppThemeExtension ext) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateString = DateFormat('dd MMMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ext.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: TextStyle(
            fontSize: 16,
            color: ext.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(AppThemeExtension ext, int completed, int total, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total tasks completed',
              style: TextStyle(
                fontSize: 14,
                color: ext.textPrimary,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: ext.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomProgressBar(progress: percentage),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks, TaskProvider taskProvider) {
    return Column(
      children: tasks.map((task) {
        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          onDismissed: (direction) {
            taskProvider.deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: TaskTile(
            task: task,
            onToggle: () => taskProvider.toggleTask(task.id),
            onEdit: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return TaskBottomSheet(
                    task: task,
                    initialDate: task.date,
                  );
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddTask(BuildContext context, AppThemeExtension ext) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return TaskBottomSheet(
              initialDate: DateTime.now(),
            );
          },
        );
      },
      child: Container(
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
              child: Icon(
                Icons.add,
                size: 16,
                color: ext.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add Task',
              style: TextStyle(
                fontSize: 16,
                color: ext.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}