import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/colors/app_colors.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/day_section.dart';

class WeekPlannerScreen extends StatefulWidget {
  const WeekPlannerScreen({super.key});

  @override
  State<WeekPlannerScreen> createState() => _WeekPlannerScreenState();
}

class _WeekPlannerScreenState extends State<WeekPlannerScreen> {
  DateTime _weekStart = DateTime.now();

  void _goToNextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          DateFormat('MMM yyyy').format(_weekStart),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.chevronLeft,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                onPressed: _goToPreviousWeek,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                onPressed: _goToNextWeek,
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final weekDays = List.generate(7, (index) {
            return _weekStart.add(Duration(days: index));
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final date = weekDays[index];
              final tasks = taskProvider.getTasksForDate(date);
              final isToday = _isSameDay(date, DateTime.now());

              return DaySection(
                date: date,
                tasks: tasks,
                isToday: isToday,
                onToggleTask: (taskId) => taskProvider.toggleTask(taskId),
                onAddTask: () {
                  // TODO: Implement add task
                },
              );
            },
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}