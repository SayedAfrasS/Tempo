import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task.dart';
import '../../models/subtask.dart';
import '../../models/task_category.dart';
import '../../models/task_repeat.dart';
import '../../providers/task_provider.dart';

class TaskTile extends StatefulWidget {
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
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool _expanded = false;
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    context.read<TaskProvider>().addSubtask(widget.task.id, text);
    _subtaskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final hasCategory = widget.task.category != TaskCategory.none;
    final isRecurring = widget.task.repeat != TaskRepeat.none;
    final completed = widget.completed;
    final subtasks = widget.task.subtasks;
    final doneCount = subtasks.where((s) => s.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Main row: title + checkbox ----------
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onEdit,
                  child: hasCategory
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: widget.task.category.color
                                .withOpacity(completed ? 0.10 : 0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.task.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: completed
                                        ? ext.textTertiary
                                        : ext.textPrimary,
                                    decoration: completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              if (isRecurring)
                                Icon(LucideIcons.repeat,
                                    size: 13, color: ext.textTertiary),
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: completed
                                      ? ext.textTertiary
                                      : ext.textPrimary,
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isRecurring)
                              Icon(LucideIcons.repeat,
                                  size: 13, color: ext.textTertiary),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed ? primary : ext.border,
                      width: 2,
                    ),
                    color: completed ? primary : ext.background,
                  ),
                  child: completed
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ),
            ],
          ),

          // ---------- Subtasks expander (ALWAYS visible) ----------
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expanded
                        ? LucideIcons.chevronDown
                        : (subtasks.isEmpty
                            ? Icons.add
                            : LucideIcons.chevronRight),
                    size: 14,
                    color: ext.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subtasks.isEmpty
                        ? 'Add subtask'
                        : '$doneCount/${subtasks.length} subtasks',
                    style: TextStyle(fontSize: 12, color: ext.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 8),
            ...subtasks.map((sub) => _subtaskRow(ext, primary, sub)),
            const SizedBox(height: 4),
            _addSubtaskRow(ext, primary),
          ],
        ],
      ),
    );
  }

  Widget _subtaskRow(AppThemeExtension ext, Color primary, Subtask sub) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context
                .read<TaskProvider>()
                .toggleSubtask(widget.task.id, sub.id),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: sub.isCompleted ? primary : ext.border,
                  width: 1.5,
                ),
                color: sub.isCompleted ? primary : Colors.transparent,
              ),
              child: sub.isCompleted
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sub.title,
              style: TextStyle(
                fontSize: 14,
                color: sub.isCompleted ? ext.textTertiary : ext.textSecondary,
                decoration: sub.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context
                .read<TaskProvider>()
                .deleteSubtask(widget.task.id, sub.id),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: ext.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addSubtaskRow(AppThemeExtension ext, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _subtaskController,
              style: TextStyle(fontSize: 14, color: ext.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Add subtask',
                hintStyle: TextStyle(fontSize: 13, color: ext.textTertiary),
                filled: true,
                fillColor: ext.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              onSubmitted: (_) => _addSubtask(),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _addSubtask,
            child: Icon(Icons.add, size: 18, color: primary),
          ),
        ],
      ),
    );
  }
}