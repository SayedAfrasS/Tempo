import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../month/presentation/month_view_screen.dart';
import '../../../models/task.dart';
import '../../../models/task_category.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/task_tile.dart';
import '../../../shared/widgets/progress_bar.dart';
import '../../../shared/widgets/task_bottom_sheet.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  TaskCategory? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        backgroundColor: ext.background,
        elevation: 0,
        title: Text(
          'Today',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ext.textPrimary),
        ),
        actions: [
                    IconButton(
                      icon: Icon(LucideIcons.calendar, color: ext.textPrimary, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MonthViewScreen()),
                        );
                      },
                    ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.getTodayTasks();
          final visibleTasks = _filter == null
              ? tasks
              : tasks.where((t) => t.category == _filter).toList();
          final completed = taskProvider.getTodayCompletedCount();
          final total = taskProvider.getTodayTotalCount();
          final percentage = taskProvider.getTodayCompletionPercentage();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSection(ext),
                const SizedBox(height: 24),
                _buildFilterChips(ext),
                const SizedBox(height: 24),
                _buildProgressSection(ext, completed, total, percentage),
                const SizedBox(height: 24),
                _buildTaskList(context, visibleTasks, taskProvider),
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
        Text(dayName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ext.textPrimary)),
        const SizedBox(height: 4),
        Text(dateString, style: TextStyle(fontSize: 16, color: ext.textSecondary)),
      ],
    );
  }

  Widget _buildFilterChips(AppThemeExtension ext) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(ext, 'All', null, const Color(0xFF9CA3AF)),
          ...TaskCategory.values
              .where((c) => c != TaskCategory.none)
              .map((c) => _chip(ext, c.label, c, c.color)),
        ],
      ),
    );
  }

  Widget _chip(AppThemeExtension ext, String label, TaskCategory? category, Color color) {
    final selected = _filter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? color : ext.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : ext.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(AppThemeExtension ext, int completed, int total, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$completed of $total tasks completed', style: TextStyle(fontSize: 14, color: ext.textPrimary)),
            Text('${(percentage * 100).toInt()}%', style: TextStyle(fontSize: 14, color: ext.textSecondary)),
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
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
          ),
          onDismissed: (direction) {
            taskProvider.deleteTask(task.id);
          },
                    child: TaskTile(
                      task: task,
                      completed: taskProvider.isCompletedOn(task, DateTime.now()),
                      onToggle: () => taskProvider.toggleTaskOn(task.id, DateTime.now()),
                      onEdit: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return TaskBottomSheet(task: task, initialDate: task.date);
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
            return TaskBottomSheet(initialDate: DateTime.now());
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
              child: Icon(Icons.add, size: 16, color: ext.textTertiary),
            ),
            const SizedBox(width: 12),
            Text('Add Task', style: TextStyle(fontSize: 16, color: ext.textTertiary)),
          ],
        ),
      ),
    );
  }
}