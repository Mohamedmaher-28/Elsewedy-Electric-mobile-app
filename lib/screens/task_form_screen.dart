import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/custom_delete_dialog.dart';
import '../core/widgets/custom_header_bar.dart';
import '../features/auth/widgets/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskItem? taskToEdit;

  const TaskFormScreen({
    super.key,
    this.taskToEdit,
  });

  bool get isEditing => taskToEdit != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;

  String? _selectedPriority;
  String? _selectedWorker;
  bool _isSaving = false;

  final List<String> _priorities = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task != null
          ? (task.description.isNotEmpty
              ? task.description
              : 'Detailed inspection and maintenance operations for ${task.title}.')
          : '',
    );
    _dateController = TextEditingController(text: task?.date ?? '');
    _selectedPriority = task?.priority;
    _selectedWorker = task?.assignedWorker;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime initialDate = today;
    if (_dateController.text.trim().isNotEmpty) {
      try {
        final parts = _dateController.text.trim().split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final parsedDate = DateTime(year, month, day);
          if (!parsedDate.isBefore(today)) {
            initialDate = parsedDate;
          }
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final priority = _selectedPriority?.trim() ?? '';
    final worker = _selectedWorker?.trim() ?? '';
    final date = _dateController.text.trim();

    if (title.isEmpty ||
        desc.isEmpty ||
        priority.isEmpty ||
        worker.isEmpty ||
        date.isEmpty) {
      _formKey.currentState?.validate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all fields. No field can be left empty.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final task = TaskItem(
      id: widget.taskToEdit?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      assignedWorker: _selectedWorker ?? 'Unassigned',
      date: _dateController.text.trim().isNotEmpty
          ? _dateController.text.trim()
          : 'Pending schedule',
      priority: _selectedPriority ?? 'High',
      status: widget.taskToEdit?.status ?? 'Pending',
    );

    try {
      if (widget.isEditing) {
        await FirebaseService.updateTask(task);
      } else {
        await FirebaseService.addTask(task);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Task updated successfully!'
                : 'Task saved successfully!',
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save task. Please try again.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDelete() {
    CustomDeleteDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${widget.taskToEdit?.title}"?',
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        try {
          if (widget.taskToEdit != null) {
            await FirebaseService.deleteTask(widget.taskToEdit!.id);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task deleted successfully!'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(); // Return from edit screen
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting task: $e'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeaderBar(
            title: isEditing ? AppStrings.editTask : AppStrings.addNewTask,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: AppStrings.taskTitleLabel,
                      hintText: AppStrings.taskTitleHint,
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Task title is required';
                        }
                        final trimmed = value.trim();
                        if (trimmed.length < 3) {
                          return 'Task title must be at least 3 characters';
                        }
                        if (trimmed.length > 80) {
                          return 'Task title must not exceed 80 characters';
                        }
                        if (!RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(trimmed)) {
                          return 'Task title must contain descriptive letters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.taskDescriptionLabel,
                      hintText: AppStrings.taskDescriptionHint,
                      controller: _descriptionController,
                      maxLines: 4,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Task description is required';
                        }
                        final trimmed = value.trim();
                        if (trimmed.length < 10) {
                          return 'Task description must be at least 10 characters';
                        }
                        if (trimmed.length > 500) {
                          return 'Task description must not exceed 500 characters';
                        }
                        if (!RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(trimmed)) {
                          return 'Task description must contain descriptive text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    // Priority Dropdown
                    const Text(
                      AppStrings.priorityLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPriority,
                      decoration: const InputDecoration(
                        hintText: AppStrings.priorityHint,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF64748B),
                      ),
                      items: _priorities
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPriority = val;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Priority is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    // Assign Worker Dropdown
                    const Text(
                      AppStrings.assignWorkerLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Worker>>(
                      stream: FirebaseService.getWorkersStream(),
                      builder: (context, snapshot) {
                        final workers = snapshot.data ?? [];
                        final workerNames =
                            workers.map((w) => w.fullName).toSet().toList();
                        if (_selectedWorker != null &&
                            _selectedWorker!.isNotEmpty &&
                            !workerNames.contains(_selectedWorker)) {
                          workerNames.add(_selectedWorker!);
                        }
                        return DropdownButtonFormField<String>(
                          initialValue: _selectedWorker,
                          decoration: const InputDecoration(
                            hintText: AppStrings.assignWorkerHint,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          items: workerNames
                              .map(
                                (name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedWorker = val;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Worker assignment is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    // Date field
                    CustomTextField(
                      label: AppStrings.dateLabel,
                      hintText: AppStrings.dateHint,
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        onPressed: _pickDate,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Date is required';
                        }
                        if (value.trim().length < 8) {
                          return 'Please select a valid date';
                        }
                        if (!widget.isEditing) {
                          try {
                            final parts = value.trim().split('/');
                            if (parts.length == 3) {
                              final day = int.parse(parts[0]);
                              final month = int.parse(parts[1]);
                              final year = int.parse(parts[2]);
                              final selectedDate = DateTime(year, month, day);
                              final now = DateTime.now();
                              final today = DateTime(now.year, now.month, now.day);
                              if (selectedDate.isBefore(today)) {
                                return 'Date cannot be before today';
                              }
                            }
                          } catch (_) {}
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Primary action button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isEditing) ...[
                                    const Icon(Icons.save_outlined, size: 20, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text(
                                      AppStrings.updateTaskBtn,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      AppStrings.saveTaskBtn,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 14),
                      // Delete task secondary button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _handleDelete,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFFECDD3),
                              width: 1.2,
                            ),
                            backgroundColor: const Color(0xFFFFF1F2),
                            foregroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.primaryRed,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.deleteTaskBtn,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
