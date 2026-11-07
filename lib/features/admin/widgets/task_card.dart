import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/models.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = const Color(0xFFB91C1C);
        fg = Colors.white;
        label = 'Pending';
        break;
      case 'completed':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        label = 'Completed';
        break;
      case 'in progress':
      default:
        bg = const Color(0xFFE2E8F0);
        fg = const Color(0xFF475569);
        label = 'In Progress';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildStatusBadge(task.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Assigned: ${task.assignedWorker}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 15,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                task.date,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.edit_square,
                      color: Color(0xFF334155),
                      size: 19,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFC8102E),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
