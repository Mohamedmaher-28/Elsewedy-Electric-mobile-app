import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryRed = Color(0xFFC8102E);
  static const Color primaryRedDark = Color(0xFFA60D25);
  static const Color primaryRedLight = Color(0xFFE53935);
  static const Color primaryRedSoft = Color(0xFFFFECEF);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Input Field Colors
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBorderFocused = Color(0xFFC8102E);
  static const Color inputFill = Colors.white;

  // Error Banner Colors
  static const Color errorBackground = Color(0xFFFFF1F2);
  static const Color errorBorder = Color(0xFFFECDD3);
  static const Color errorTextDark = Color(0xFF9F1239);
  static const Color errorTextLight = Color(0xFFBE123C);

  // Divider & Border Colors
  static const Color dividerLine = Color(0xFFFDA4AF);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  // Status Colors
  static const Color statusPendingBg = Color(0xFFFFE4E6);
  static const Color statusPendingText = Color(0xFFE11D48);
  static const Color statusCompletedBg = Color(0xFFD1FAE5);
  static const Color statusCompletedText = Color(0xFF059669);
  static const Color statusInProgressBg = Color(0xFFF1F5F9);
  static const Color statusInProgressText = Color(0xFF475569);
  static const Color statusBadgeRedBg = Color(0xFFB91C1C);

  // Priority Colors
  static const Color priorityHighBg = Color(0xFFFFE4E6);
  static const Color priorityHighText = Color(0xFFE11D48);
}

class AppAssets {
  static const String logo = 'Assets/logo.png';
  static const String appLogo = 'Assets/app_logo.png';
}

class AppStrings {
  static const String appName = 'Egy Tech';

  // Auth Strings
  static const String authFailedTitle = 'Authentication Failed';
  static const String authFailedMessage =
      'The username or password or biometric you entered is incorrect.';
  static const String usernameLabel = 'Username / Employee ID';
  static const String usernameHint = 'e.g., mo7amed_____maher';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String signIn = 'Sign In';
  static const String orDivider = 'Or';
  static const String loginWithBiometrics = 'Login with Biometrics';

  // Admin Dashboard Strings
  static const String loggedInAs = 'Logged in as';
  static const String defaultAdminName = 'Mohamed Maher';
  static const String logout = 'Logout';
  static const String workforcePerformance = 'WORKFORCE PERFORMANCE';
  static const String totalWorkers = 'Total Workers';
  static const String totalTasks = 'Total Tasks';
  static const String pendingTasks = 'Pending Tasks';
  static const String completedTasks = 'Completed Tasks';
  static const String directoryAndOperations = 'DIRECTORY & OPERATIONS';
  static const String manageWorkers = 'Manage Workers';
  static const String manageWorkersSub = 'Add, edit, or remove field operatives';
  static const String manageTaskMatrix = 'Manage Task Matrix';
  static const String manageTaskMatrixSub = 'Assign and monitor grid operations';

  // Worker Directory Strings
  static const String workerDirectory = 'Worker Directory';
  static const String searchWorkersHint = 'Search workers by name...';

  // Worker Form Strings
  static const String addWorker = 'Add Worker';
  static const String addWorkerSub = 'Register new field personnel';
  static const String editWorker = 'Edit Worker';
  static const String editWorkerSub = 'Modify operative profile';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'e.g., Amr Abdel-Rahman';
  static const String usernameSystemLabel = 'Username / System ID';
  static const String usernameSystemHint = 'e.g., amr.rahman';
  static const String passwordSystemHint = 'Define temporary key';
  static const String phoneNumberLabel = 'Phone Number';
  static const String phoneNumberHint = 'e.g., 01129115112';
  static const String addWorkerBtn = 'Add Worker to Directory';
  static const String updateWorkerBtn = 'Update Worker Profile';
  static const String deleteWorkerBtn = 'Delete Worker';

  // Task Matrix Strings
  static const String taskMatrix = 'Task Matrix';
  static const String taskMatrixSub = 'Monitor active electrical grids';
  static const String searchTasksHint = 'Search industrial tasks...';

  // Task Form Strings
  static const String addNewTask = 'Add New Task';
  static const String editTask = 'Edit Task';
  static const String taskTitleLabel = 'Task Title';
  static const String taskTitleHint = 'Enter task title...';
  static const String taskDescriptionLabel = 'Task Description';
  static const String taskDescriptionHint = 'Describe the task in detail...';
  static const String priorityLabel = 'Priority';
  static const String priorityHint = 'Select priority...';
  static const String assignWorkerLabel = 'Assign Worker';
  static const String assignWorkerHint = 'Choose team member...';
  static const String dateLabel = 'Date';
  static const String dateHint = 'Select date...';
  static const String saveTaskBtn = 'Save Task';
  static const String updateTaskBtn = 'Update Task';
  static const String deleteTaskBtn = 'Delete Task';

  // Worker Profile & Task Details Strings
  static const String defaultWorkerName = 'Moustafa Maher';
  static const String assignedWork = 'ASSIGNED WORK';
  static const String myTasks = 'My tasks';
  static const String updateStatus = 'UPDATE STATUS';
  static const String saveUpdateBtn = 'Save update';
}
