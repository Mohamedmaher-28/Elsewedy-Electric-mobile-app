import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class DashboardMetrics {
  final int totalWorkers;
  final int totalTasks;
  final int pendingTasks;
  final int completedTasks;

  const DashboardMetrics({
    this.totalWorkers = 0,
    this.totalTasks = 0,
    this.pendingTasks = 0,
    this.completedTasks = 0,
  });
}

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get workersCollection =>
      _firestore.collection('workers');

  static CollectionReference<Map<String, dynamic>> get tasksCollection =>
      _firestore.collection('tasks');

  // --- Authentication ---
  static User? get currentUser => _auth.currentUser;
  static String currentWorkerName = '';
  static String currentRole = '';

  static Future<String?> signIn({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanUsernameLower = cleanUsername.toLowerCase();
    final cleanPassword = password.trim();

    // 1. Check for Admin Login (admin@123 / admin@123)
    if (cleanUsernameLower == 'admin@123') {
      if (cleanPassword == 'admin@123') {
        currentRole = 'admin';
        currentWorkerName = 'Admin';
        return 'admin';
      } else {
        // Admin password mismatch
        return null;
      }
    }

    // 2. Check in Firestore Workers collection
    try {
      final snapshot = await workersCollection.get();
      Worker? matchingWorker;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final docUsername =
            (data['username'] as String? ?? '').trim().toLowerCase();
        if (docUsername == cleanUsernameLower) {
          matchingWorker = Worker.fromMap(data, doc.id);
          break;
        }
      }

      if (matchingWorker != null) {
        if (matchingWorker.password.isNotEmpty) {
          if (matchingWorker.password == cleanPassword) {
            currentRole = 'worker';
            currentWorkerName = matchingWorker.fullName;
            return 'worker';
          } else {
            // Password mismatch for this worker
            return null;
          }
        } else if (cleanPassword.isNotEmpty) {
          // If worker record did not have a password yet (from earlier version),
          // securely save this password to Firestore now
          await workersCollection
              .doc(matchingWorker.id)
              .update({'password': cleanPassword});
          currentRole = 'worker';
          currentWorkerName = matchingWorker.fullName;
          return 'worker';
        }
      }
    } catch (e) {
      debugPrint('Firestore worker lookup error: $e');
    }

    // 3. Fallback: Check Firebase Auth
    final String email = cleanUsernameLower.contains('@') &&
            cleanUsernameLower.contains('.')
        ? cleanUsernameLower
        : '${cleanUsernameLower.replaceAll('@', '_')}@egytech.com';

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: cleanPassword,
      );
      if (cred.user != null) {
        if (cleanUsernameLower.contains('admin')) {
          currentRole = 'admin';
          currentWorkerName = 'Admin';
          return 'admin';
        }
        currentRole = 'worker';
        currentWorkerName = cleanUsername;
        return 'worker';
      }
    } catch (e) {
      debugPrint('Firebase Auth sign in notice: $e');
    }

    // Credentials did not match
    return null;
  }

  static Future<void> signOut() async {
    currentWorkerName = '';
    currentRole = '';
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // --- Workers ---
  static Stream<List<Worker>> getWorkersStream() {
    return workersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Worker.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Future<List<Worker>> getWorkers() async {
    final snapshot = await workersCollection.get();
    return snapshot.docs.map((doc) {
      return Worker.fromMap(doc.data(), doc.id);
    }).toList();
  }

  static Future<void> addWorker(Worker worker) async {
    await workersCollection.add(worker.toMap());

    // Also register in Firebase Auth for seamless cloud sync
    try {
      final cleanUsername = worker.username.trim().toLowerCase();
      final email = cleanUsername.contains('@') && cleanUsername.contains('.')
          ? cleanUsername
          : '${cleanUsername.replaceAll('@', '_')}@egytech.com';
      if (worker.password.isNotEmpty) {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: worker.password,
        );
      }
    } catch (e) {
      debugPrint('Worker Firebase Auth creation note: $e');
    }
  }

  static Future<void> updateWorker(Worker worker) async {
    await workersCollection.doc(worker.id).update(worker.toMap());
  }

  static Future<void> deleteWorker(String id) async {
    await workersCollection.doc(id).delete();
  }

  // --- Tasks ---
  static Stream<List<TaskItem>> getTasksStream() {
    return tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  static Stream<List<TaskItem>> getWorkerTasksStream({String? workerName}) {
    return tasksCollection.snapshots().map((snapshot) {
      final all = snapshot.docs.map((doc) {
        return TaskItem.fromMap(doc.data(), doc.id);
      }).toList();

      if (workerName == null || workerName.trim().isEmpty) {
        return <TaskItem>[];
      }

      final cleanName = workerName.trim().toLowerCase();
      final filtered = all
          .where((t) => t.assignedWorker.trim().toLowerCase() == cleanName)
          .toList();

      return filtered;
    });
  }

  static Future<List<TaskItem>> getTasks() async {
    final snapshot = await tasksCollection.get();
    return snapshot.docs.map((doc) {
      return TaskItem.fromMap(doc.data(), doc.id);
    }).toList();
  }

  static Future<void> addTask(TaskItem task) async {
    await tasksCollection.add(task.toMap());
  }

  static Future<void> updateTask(TaskItem task) async {
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  static Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await tasksCollection.doc(taskId).update({'status': newStatus});
  }

  static Future<void> deleteTask(String id) async {
    await tasksCollection.doc(id).delete();
  }

  // --- Dashboard Metrics ---
  static Stream<DashboardMetrics> getDashboardMetricsStream() {
    return _firestore.collection('tasks').snapshots().asyncMap((taskSnap) async {
      final workerSnap = await _firestore.collection('workers').get();
      final totalWorkers = workerSnap.docs.length;
      final totalTasks = taskSnap.docs.length;
      int pending = 0;
      int completed = 0;

      for (var doc in taskSnap.docs) {
        final status = (doc.data()['status'] as String? ?? '').toLowerCase();
        if (status == 'pending') {
          pending++;
        } else if (status == 'completed') {
          completed++;
        }
      }

      return DashboardMetrics(
        totalWorkers: totalWorkers,
        totalTasks: totalTasks,
        pendingTasks: pending,
        completedTasks: completed,
      );
    });
  }
}
