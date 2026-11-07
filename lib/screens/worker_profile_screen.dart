import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/user_profile_header.dart';
import '../features/worker/widgets/worker_task_card.dart';
import 'login_screen.dart';
import 'worker_task_details_screen.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String workerName;

  const WorkerProfileScreen({
    super.key,
    this.workerName = AppStrings.defaultWorkerName,
  });

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  void _handleLogout() async {
    await FirebaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToTaskDetails(TaskItem task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerTaskDetailsScreen(task: task),
      ),
    );
    setState(() {}); // Refresh statuses after returning
  }

  String get _initials {
    final parts = widget.workerName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'MM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          UserProfileHeader(
            initials: _initials,
            name: widget.workerName,
            onLogout: _handleLogout,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: StreamBuilder<List<TaskItem>>(
              stream: FirebaseService.getWorkerTasksStream(
                workerName: widget.workerName,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryRed,
                    ),
                  );
                }

                final tasks = snapshot.data ?? [];

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.assignedWork,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF334155),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.myTasks,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${tasks.length} assigned',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (tasks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text(
                              'No tasks assigned at the moment.',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                        )
                      else
                        ...tasks.map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: WorkerTaskCard(
                              task: task,
                              onTap: () => _navigateToTaskDetails(task),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
