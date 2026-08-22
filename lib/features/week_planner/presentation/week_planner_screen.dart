import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/colors/app_colors.dart';
import '../../../providers/task_provider.dart';
import '../../../shared/widgets/day_section.dart';
import '../../../shared/widgets/add_task_bottom_sheet.dart';

class WeekPlannerScreen extends StatefulWidget {
  const WeekPlannerScreen({super.key});

  @override
  State<WeekPlannerScreen> createState() => _WeekPlannerScreenState();
}

class _WeekPlannerScreenState extends State<WeekPlannerScreen> {
  late DateTime _weekStart;
  final GlobalKey _todayKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _weekStart = _getStartOfWeek(DateTime.now());

    // Wait for the UI to fully render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToToday();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - DateTime.monday;
    if (daysToSubtract < 0) daysToSubtract = 0;
    return date.subtract(Duration(days: daysToSubtract));
  }

  // 🎯 THE BULLETPROOF SCROLL METHOD
  void _scrollToToday() {
    if (_todayKey.currentContext == null || !_scrollController.hasClients) return;

    // 1. Find the exact pixel position of the "Today" widget
    final RenderBox renderBox = _todayKey.currentContext!.findRenderObject() as RenderBox;
    final scrollable = Scrollable.of(_todayKey.currentContext!);

    // 2. Calculate the offset relative to the scroll view
    final offset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: scrollable.context.findRenderObject()
    ).dy;

    // 3. Animate exactly to that offset (This forces it to the absolute top!)
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  void _goToPreviousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (index) {
      return _weekStart.add(Duration(days: index));
    });

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
                  child: const Icon(LucideIcons.chevronLeft, color: AppColors.primary, size: 20),
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
                  child: const Icon(LucideIcons.chevronRight, color: AppColors.primary, size: 20),
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
          // We use ListView instead of ListView.builder so all 7 days render immediately
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              ...weekDays.map((date) {
                final tasks = taskProvider.getTasksForDate(date);
                final isToday = _isSameDay(date, DateTime.now());

                return DaySection(
                  key: isToday ? _todayKey : null,
                  date: date,
                  tasks: tasks,
                  isToday: isToday,
                  onToggleTask: (taskId) => taskProvider.toggleTask(taskId),
                  onDeleteTask: (taskId) => taskProvider.deleteTask(taskId),
                  onAddTask: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return AddTaskBottomSheet(selectedDate: date);
                      },
                    );
                  },
                );
              }),
              // The bottom spacer to allow scrolling past Sunday
              SizedBox(height: MediaQuery.of(context).size.height * 0.8),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}