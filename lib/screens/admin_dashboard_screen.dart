import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/user_profile_header.dart';
import '../features/admin/widgets/metric_card.dart';
import '../features/admin/widgets/operation_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToWorkers;
  final VoidCallback onNavigateToTasks;
  final VoidCallback onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigateToWorkers,
    required this.onNavigateToTasks,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          UserProfileHeader(
            initials: 'MM',
            name: AppStrings.defaultAdminName,
            onLogout: onLogout,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.workforcePerformance,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Live Metrics from Firebase
                  StreamBuilder<DashboardMetrics>(
                    stream: FirebaseService.getDashboardMetricsStream(),
                    builder: (context, snapshot) {
                      final metrics = snapshot.data ?? const DashboardMetrics();

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MetricCard(
                                  title: AppStrings.totalWorkers,
                                  value: '${metrics.totalWorkers}',
                                  icon: Icons.people_outline_rounded,
                                  iconColor: const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: MetricCard(
                                  title: AppStrings.totalTasks,
                                  value: '${metrics.totalTasks}',
                                  icon: Icons.work_outline_rounded,
                                  iconColor: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: MetricCard(
                                  title: AppStrings.pendingTasks,
                                  value: '${metrics.pendingTasks}',
                                  icon: Icons.access_time_rounded,
                                  iconColor: const Color(0xFFF59E0B),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: MetricCard(
                                  title: AppStrings.completedTasks,
                                  value: '${metrics.completedTasks}',
                                  icon: Icons.check_circle_outline_rounded,
                                  iconColor: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    AppStrings.directoryAndOperations,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OperationCard(
                    title: AppStrings.manageWorkers,
                    subtitle: AppStrings.manageWorkersSub,
                    icon: Icons.people_alt_outlined,
                    iconBgColor: const Color(0xFFFFECEF),
                    iconColor: AppColors.primaryRed,
                    onTap: onNavigateToWorkers,
                  ),
                  const SizedBox(height: 14),
                  OperationCard(
                    title: AppStrings.manageTaskMatrix,
                    subtitle: AppStrings.manageTaskMatrixSub,
                    icon: Icons.business_center_outlined,
                    iconBgColor: const Color(0xFFF1F5F9),
                    iconColor: const Color(0xFF334155),
                    onTap: onNavigateToTasks,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
