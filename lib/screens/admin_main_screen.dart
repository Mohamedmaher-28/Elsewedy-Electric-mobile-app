import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/firebase_service.dart';
import 'admin_dashboard_screen.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';
import 'worker_list_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final int initialIndex;

  const AdminMainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleLogout() async {
    await FirebaseService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AdminDashboardScreen(
        onNavigateToWorkers: () => setState(() => _currentIndex = 1),
        onNavigateToTasks: () => setState(() => _currentIndex = 2),
        onLogout: _handleLogout,
      ),
      const WorkerListScreen(showBackButton: false),
      const TaskListScreen(showBackButton: false),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1.2),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.transparent,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryRed,
                  );
                }
                return const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textHint,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: AppColors.primaryRed,
                    size: 24,
                  );
                }
                return const IconThemeData(
                  color: AppColors.textHint,
                  size: 24,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Colors.white,
              elevation: 0,
              height: 64,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  label: 'Workers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.business_center_outlined),
                  label: 'Tasks',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
