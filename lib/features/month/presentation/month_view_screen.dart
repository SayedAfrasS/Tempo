import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/task.dart';
import '../../../models/task_category.dart';
import '../../../providers/task_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/task_tile.dart';
import '../../../shared/widgets/task_bottom_sheet.dart';

class MonthViewScreen extends StatefulWidget {
  const MonthViewScreen({super.key});

  @override
  State<MonthViewScreen> createState() => _MonthViewScreenState();
}

class _MonthViewScreenState extends State<MonthViewScreen> {
  late DateTime _monthStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _monthStart = DateTime(now.year, now.month, 1);
  }

  void _changeMonth(int delta) {
    setState(() {
      _monthStart = DateTime(_monthStart.year, _monthStart.month + delta, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _weekStartOf(DateTime date, WeekStart weekStart) {
    final clean = DateTime(date.year, date.month, date.day);
    if (weekStart == WeekStart.sunday) {
      return clean.subtract(Duration(days: clean.weekday % 7));
    }
    return clean.subtract(Duration(days: clean.weekday - 1));
  }

  List<List<DateTime>> _buildWeeks(WeekStart weekStart) {
    final lastDay = DateTime(_monthStart.year, _monthStart.month + 1, 0);
    final weeks = <List<DateTime>>[];
    var current = _weekStartOf(_monthStart, weekStart);
    while (!current.isAfter(lastDay)) {
      weeks.add(List.generate(7, (i) => current.add(Duration(days: i))));
      current = current.add(const Duration(days: 7));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final weekStart = context.watch<SettingsProvider>().weekStartsOn;
    final weeks = _buildWeeks(weekStart);

    return Scaffold(
      backgroundColor: ext.background,
      appBar: AppBar(
        backgroundColor: ext.background,
        elevation: 0,
        // 🎯 SMART CLOSE BUTTON: only shows when pushed as a page (from Today),
        // hidden when used as a bottom nav tab.
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.close, color: ext.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          DateFormat('MMMM yyyy').format(_monthStart),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ext.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: primary),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: Icon(LucideIcons.chevronRight, color: primary),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _weekdayHeader(ext, weekStart),
              const SizedBox(height: 12),
              ...weeks.map((week) => _weekRow(ext, week, taskProvider)),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _weekdayHeader(AppThemeExtension ext, WeekStart weekStart) {
    final labels = weekStart == WeekStart.sunday
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: labels
          .map((l) => Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ext.textTertiary,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _weekRow(
      AppThemeExtension ext, List<DateTime> week, TaskProvider provider) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              week.map((date) => _dayCell(ext, date, provider)).toList(),
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: ext.border),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dayCell(AppThemeExtension ext, DateTime date, TaskProvider provider) {
    final inMonth = date.month == _monthStart.month;
    final isToday = _isSameDay(date, DateTime.now());
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final tasks = provider.getTasksForDate(date);

    return Expanded(
      child: GestureDetector(
        onTap: () => _openDaySheet(date),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isToday
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? Colors.white
                      : !inMonth
                          ? ext.textTertiary.withOpacity(0.5)
                          : isWeekend
                              ? ext.textTertiary
                              : ext.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // ✅ EDIT 1: pass provider + date into the chip
            ...tasks.take(3).map((t) => _chip(ext, t, provider, date)),
            if (tasks.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${tasks.length - 3} more',
                  style: TextStyle(fontSize: 9, color: ext.textTertiary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ EDIT 2: chip now uses per-date completion for recurring tasks
  Widget _chip(
      AppThemeExtension ext, Task task, TaskProvider provider, DateTime date) {
    final completed = provider.isCompletedOn(task, date);
    final Color bg = task.category == TaskCategory.none
        ? ext.surface
        : task.category.color.withOpacity(0.25);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 3, left: 2, right: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        task.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9,
          color: completed ? ext.textTertiary : ext.textPrimary,
          decoration: completed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
    );
  }

  void _openDaySheet(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DaySheet(date: date),
    );
  }
}

// ---------- Bottom sheet showing a day's full task list ----------
class _DaySheet extends StatelessWidget {
  final DateTime date;

  const _DaySheet({required this.date});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ext.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.getTasksForDate(date);
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: ext.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d').format(date),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary),
                ),
                const SizedBox(height: 16),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No tasks for this day',
                      style: TextStyle(
                          fontSize: 15,
                          color: ext.textTertiary,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  // ✅ EDIT 3: per-date completion + toggle for recurring tasks
                  ...tasks.map((task) => TaskTile(
                        task: task,
                        completed: provider.isCompletedOn(task, date),
                        onToggle: () => provider.toggleTaskOn(task.id, date),
                        onEdit: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TaskBottomSheet(
                                task: task, initialDate: date),
                          );
                        },
                      )),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => TaskBottomSheet(initialDate: date),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: ext.border, width: 2),
                          ),
                          child:
                              Icon(Icons.add, size: 16, color: ext.textTertiary),
                        ),
                        const SizedBox(width: 12),
                        Text('Add Task',
                            style: TextStyle(
                                fontSize: 16, color: ext.textTertiary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}