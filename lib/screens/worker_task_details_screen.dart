import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/services/sound_service.dart';
import '../core/widgets/custom_header_bar.dart';

class WorkerTaskDetailsScreen extends StatefulWidget {
  final TaskItem task;

  const WorkerTaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<WorkerTaskDetailsScreen> createState() =>
      _WorkerTaskDetailsScreenState();
}

class _WorkerTaskDetailsScreenState extends State<WorkerTaskDetailsScreen> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.task.status;
  }

  void _handleSaveUpdate() async {
    final bool isCompleted = _selectedStatus.toLowerCase() == 'completed';

    setState(() {
      widget.task.status = _selectedStatus;
    });

    if (isCompleted) {
      SoundService.playNotificationSound();
    }

    try {
      if (widget.task.id.isNotEmpty) {
        await FirebaseService.updateTaskStatus(widget.task.id, _selectedStatus);
      }
    } catch (e) {
      debugPrint('Error updating task in Firebase: $e');
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task status updated to $_selectedStatus!'),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildStatusOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color bg;
    Color fg;
    BorderSide border;

    if (isSelected) {
      bg = const Color(0xFFB91C1C);
      fg = Colors.white;
      border = BorderSide.none;
    } else if (label == 'Completed') {
      bg = Colors.white;
      fg = const Color(0xFF059669);
      border = const BorderSide(color: Color(0xFFD1FAE5), width: 1.4);
    } else {
      bg = Colors.white;
      fg = const Color(0xFF334155);
      border = const BorderSide(color: Color(0xFFE2E8F0), width: 1.4);
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: border != BorderSide.none
                ? Border.fromBorderSide(border)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedIndicator(String status) {
    Color dotColor = const Color(0xFFE11D48);
    Color pillBg = const Color(0xFFFFECEF);

    if (status.toLowerCase() == 'completed') {
      dotColor = const Color(0xFF10B981);
      pillBg = const Color(0xFFD1FAE5);
    } else if (status.toLowerCase() == 'in progress') {
      dotColor = const Color(0xFF475569);
      pillBg = const Color(0xFFF1F5F9);
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dotColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Selected status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomHeaderBar(
            title: AppStrings.editTask,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.task.priority,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Title
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1.25,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    widget.task.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Due date row
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFFB91C1C),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Due date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.task.date,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Current status row (dynamically updates color)
                        Builder(
                          builder: (context) {
                            Color statusColor = const Color(0xFFB91C1C);
                            Color statusBg = const Color(0xFFFFECEF);
                            IconData statusIcon = Icons.bolt_outlined;

                            switch (_selectedStatus.toLowerCase()) {
                              case 'completed':
                                statusColor = const Color(0xFF059669);
                                statusBg = const Color(0xFFD1FAE5);
                                statusIcon = Icons.check_circle_outline_rounded;
                                break;
                              case 'in progress':
                                statusColor = const Color(0xFF475569);
                                statusBg = const Color(0xFFF1F5F9);
                                statusIcon = Icons.timelapse_rounded;
                                break;
                              case 'pending':
                              default:
                                statusColor = const Color(0xFFB91C1C);
                                statusBg = const Color(0xFFFFECEF);
                                statusIcon = Icons.bolt_outlined;
                                break;
                            }

                            return Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      statusIcon,
                                      color: statusColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current status',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedStatus,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Update Status Section
                  const Text(
                    AppStrings.updateStatus,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 3 status buttons
                  Row(
                    children: [
                      _buildStatusOptionButton(
                        label: 'In progress',
                        isSelected:
                            _selectedStatus.toLowerCase() == 'in progress',
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'In progress';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildStatusOptionButton(
                        label: 'Pending',
                        isSelected: _selectedStatus.toLowerCase() == 'pending',
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'Pending';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildStatusOptionButton(
                        label: 'Completed',
                        isSelected:
                            _selectedStatus.toLowerCase() == 'completed',
                        onTap: () {
                          setState(() {
                            _selectedStatus = 'Completed';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSelectedIndicator(_selectedStatus),
                  const SizedBox(height: 20),
                  const Text(
                    'Changes will be recorded with your worker ID and timestamp.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save update button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleSaveUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB91C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.saveUpdateBtn,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
