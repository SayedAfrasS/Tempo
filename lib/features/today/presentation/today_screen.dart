import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/colors/app_colors.dart';
import '../../../models/task.dart'; // <-- Added this import
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/task_tile.dart';
import '../../../shared/widgets/progress_bar.dart';
   import '../../../shared/widgets/task_bottom_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Today',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              LucideIcons.calendar,
              color: AppColors.textPrimary,
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
                _buildDateSection(),
                const SizedBox(height: 32),
                _buildProgressSection(completed, total, percentage),
                const SizedBox(height: 32),
                _buildTaskList(context, tasks, taskProvider), // <-- Pass context here
                const SizedBox(height: 16),
                _buildAddTask(context), // <-- Pass context here
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateString = DateFormat('dd MMMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateString,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(int completed, int total, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total tasks completed',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomProgressBar(progress: percentage),
      ],
    );
  }

  // <-- FIXED: Added BuildContext context as the first parameter
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
              color: AppColors.error,
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
              const SnackBar(
                content: Text('Task deleted'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
             child: TaskTile(
               task: task,
               onToggle: () => taskProvider.toggleTask(task.id),
               onEdit: () { // ADD THIS BLOCK
                 showModalBottomSheet(
                   context: context,
                   isScrollControlled: true,
                   backgroundColor: Colors.transparent,
                   builder: (context) {
                     return TaskBottomSheet(
                       task: task, // Pass the task to edit it
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

  // <-- FIXED: Added BuildContext context as the first parameter
  Widget _buildAddTask(BuildContext context) {
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
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Task',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}