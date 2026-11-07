class Worker {
  final String id;
  final String fullName;
  final String username;
  final String password;
  final String phone;
  final String initials;

  Worker({
    required this.id,
    required this.fullName,
    required this.username,
    this.password = '',
    required this.phone,
    String? initials,
  }) : initials = initials ?? _getInitials(fullName);

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'MM';
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'username': username,
      'password': password,
      'phone': phone,
      'initials': initials,
    };
  }

  factory Worker.fromMap(Map<String, dynamic> map, String id) {
    return Worker(
      id: id,
      fullName: map['fullName'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      initials: map['initials'] as String?,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String assignedWorker;
  final String date;
  final String priority; // High, Medium, Low
  String status; // In Progress, Pending, Completed

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.assignedWorker,
    required this.date,
    this.priority = 'High',
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'assignedWorker': assignedWorker,
      'date': date,
      'priority': priority,
      'status': status,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map, String id) {
    return TaskItem(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      assignedWorker: map['assignedWorker'] as String? ?? '',
      date: map['date'] as String? ?? '',
      priority: map['priority'] as String? ?? 'High',
      status: map['status'] as String? ?? 'Pending',
    );
  }
}
