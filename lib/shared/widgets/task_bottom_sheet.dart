import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';

class TaskBottomSheet extends StatefulWidget {
  final Task? task;
  final DateTime initialDate;

  const TaskBottomSheet({
    super.key,
    this.task,
    required this.initialDate,
  });

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _selectedDate = widget.task!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final primary = Theme.of(context).primaryColor;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (widget.task != null) {
        taskProvider.updateTask(
          widget.task!.id,
          title: _titleController.text.trim(),
          date: _selectedDate,
        );
      } else {
        taskProvider.addTask(Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          isCompleted: false,
          date: _selectedDate,
        ));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final primary = Theme.of(context).primaryColor;
    final isEditing = widget.task != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ext.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: ext.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              isEditing ? 'Edit Task' : 'Add New Task',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ext.textPrimary),
            ),
            const SizedBox(height: 24),

            Text('Task Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: ext.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter task title',
                hintStyle: TextStyle(color: ext.textTertiary),
                filled: true, fillColor: ext.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a task title' : null,
            ),
            const SizedBox(height: 20),

            Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.textPrimary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: ext.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, color: primary, size: 20),
                    const SizedBox(width: 12),
                    Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate), style: TextStyle(fontSize: 16, color: ext.textPrimary)),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: ext.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ext.surface, foregroundColor: ext.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                    ),
                    child: Text(isEditing ? 'Save Changes' : 'Add Task', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}