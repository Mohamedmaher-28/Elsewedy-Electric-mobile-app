import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/custom_delete_dialog.dart';
import '../core/widgets/custom_header_bar.dart';
import '../features/admin/widgets/worker_card.dart';
import 'worker_form_screen.dart';

class WorkerListScreen extends StatefulWidget {
  final bool showBackButton;

  const WorkerListScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToEdit(Worker worker) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkerFormScreen(workerToEdit: worker),
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WorkerFormScreen(),
      ),
    );
  }

  void _handleDelete(Worker worker) {
    CustomDeleteDialog.show(
      context,
      title: 'Delete Worker',
      message: 'Are you sure you want to delete ${worker.fullName}?',
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        try {
          await FirebaseService.deleteWorker(worker.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${worker.fullName} deleted.'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete worker: $e'),
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
            title: AppStrings.workerDirectory,
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
                key: const ValueKey('worker_search_bar'),
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
                  hintText: AppStrings.searchWorkersHint,
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
                StreamBuilder<List<Worker>>(
                  stream: FirebaseService.getWorkersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryRed,
                        ),
                      );
                    }

                    final allWorkers = snapshot.data ?? [];
                    final filteredWorkers = _searchQuery.trim().isEmpty
                        ? allWorkers
                        : allWorkers
                            .where((w) => w.fullName
                                .toLowerCase()
                                .contains(_searchQuery.trim().toLowerCase()))
                            .toList();

                    if (filteredWorkers.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No workers found.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredWorkers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        return WorkerCard(
                          worker: worker,
                          onEdit: () => _navigateToEdit(worker),
                          onDelete: () => _handleDelete(worker),
                        );
                      },
                    );
                  },
                ),
                // FAB for Adding Worker
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
