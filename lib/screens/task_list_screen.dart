import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/custom_delete_dialog.dart';
import '../core/widgets/custom_header_bar.dart';
import '../features/admin/widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final bool showBackButton;

  const TaskListScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEdit(TaskItem task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(taskToEdit: task),
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TaskFormScreen(),
      ),
    );
  }

  void _handleDelete(TaskItem task) {
    CustomDeleteDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task.title}"?',
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        try {
          await FirebaseService.deleteTask(task.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${task.title} deleted.'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete task: $e'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeaderBar(
            title: AppStrings.taskMatrix,
            subtitle: AppStrings.taskMatrixSub,
            showBackButton: widget.showBackButton,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          // Search Bar outside the scrolling list to preserve keyboard focus
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.2,
                ),
              ),
              child: TextField(
                key: const ValueKey('task_search_bar'),
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: AppStrings.searchTasksHint,
                  hintStyle: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textHint,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<TaskItem>>(
                  stream: FirebaseService.getTasksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryRed,
                        ),
                      );
                    }

                    final allTasks = snapshot.data ?? [];
                    final filteredTasks = _searchQuery.trim().isEmpty
                        ? allTasks
                        : allTasks
                            .where((t) =>
                                t.title
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                t.assignedWorker
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()) ||
                                t.status
                                    .toLowerCase()
                                    .contains(_searchQuery.toLowerCase()))
                            .toList();

                    if (filteredTasks.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No tasks found.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTasks.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return TaskCard(
                          task: task,
                          onEdit: () => _navigateToEdit(task),
                          onDelete: () => _handleDelete(task),
                        );
                      },
                    );
                  },
                ),
                // FAB for Adding Task
                Positioned(
                  bottom: 24,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _navigateToAdd,
                    backgroundColor: AppColors.primaryRed,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
