import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart'; // Added for AppThemeExtension
import '../../../models/task.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/day_section.dart';
import '../../../shared/widgets/task_bottom_sheet.dart';

class WeekPlannerScreen extends StatefulWidget {
  const WeekPlannerScreen({super.key});

  @override
  State<WeekPlannerScreen> createState() => _WeekPlannerScreenState();
}

class _WeekPlannerScreenState extends State<WeekPlannerScreen> {
  late DateTime _weekStart;
  final GlobalKey _centerKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _weekStart = _getStartOfWeek(DateTime.now(), settings.weekStartsOn);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date, WeekStart weekStart) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    if (weekStart == WeekStart.sunday) {
      return cleanDate.subtract(Duration(days: cleanDate.weekday % 7));
    }
    return cleanDate.subtract(Duration(days: cleanDate.weekday - 1));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _changeWeek(int days) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: days));
    });
    // Reset to the top (which is always the "center" day) when changing weeks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _openSheet({Task? task, required DateTime date}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskBottomSheet(task: task, initialDate: date),
    );
  }

  Widget _buildDaySection(DateTime date, TaskProvider taskProvider) {
    final tasks = taskProvider.getTasksForDate(date);
    final isToday = _isSameDay(date, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DaySection(
        date: date,
        tasks: tasks,
        isToday: isToday,
        onToggleTask: (taskId) => taskProvider.toggleTask(taskId),
        onDeleteTask: (taskId) => taskProvider.deleteTask(taskId),
        onEditTask: (task) => _openSheet(task: task, date: date),
        onAddTask: () => _openSheet(date: date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final weekDays = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    // 🎯 THE MAGIC: Split the week into "past days" and "today + future days"
    final todayIndex = weekDays.indexWhere((d) => _isSameDay(d, DateTime.now()));
    final centerIndex = todayIndex == -1 ? 0 : todayIndex;
    final pastDays = weekDays.sublist(0, centerIndex);
    final todayAndFutureDays = weekDays.sublist(centerIndex);

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (!taskProvider.isLoaded) {
          return Scaffold(
            backgroundColor: ext.background,
            body: Center(child: CircularProgressIndicator(color: primary)),
          );
        }

        return Scaffold(
          backgroundColor: ext.background,
          appBar: AppBar(
            backgroundColor: ext.background,
            elevation: 0,
            title: Text(
              DateFormat('MMM yyyy').format(_weekStart),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ext.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ext.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.chevronLeft, color: primary, size: 20),
                ),
                onPressed: () => _changeWeek(-7),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ext.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.chevronRight, color: primary, size: 20),
                ),
                onPressed: () => _changeWeek(7),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CustomScrollView(
            controller: _scrollController,
            center: _centerKey, // 🎯 This makes the 2nd sliver start at scroll position 0
            slivers: [
              // 1. PAST DAYS (Monday → Yesterday). These live ABOVE the top edge.
              //    The user scrolls UP to see them.
              SliverList(
                delegate: SliverChildListDelegate(
                  pastDays.map((d) => _buildDaySection(d, taskProvider)).toList(),
                ),
              ),

              // 2. TODAY + FUTURE DAYS. This sliver starts EXACTLY at the top
              //    of the screen on the very first frame. No scrolling needed!
              SliverList(
                key: _centerKey,
                delegate: SliverChildListDelegate(
                  [
                    ...todayAndFutureDays.map((d) => _buildDaySection(d, taskProvider)),
                    const SizedBox(height: 120), // Small bottom breathing room
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}