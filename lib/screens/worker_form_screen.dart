import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/models/models.dart';
import '../core/services/firebase_service.dart';
import '../core/widgets/custom_delete_dialog.dart';
import '../core/widgets/custom_header_bar.dart';
import '../features/auth/widgets/custom_text_field.dart';

class WorkerFormScreen extends StatefulWidget {
  final Worker? workerToEdit;

  const WorkerFormScreen({
    super.key,
    this.workerToEdit,
  });

  bool get isEditing => workerToEdit != null;

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;

  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final worker = widget.workerToEdit;
    _nameController = TextEditingController(text: worker?.fullName ?? '');
    _usernameController = TextEditingController(text: worker?.username ?? '');
    _passwordController =
        TextEditingController(text: worker?.password ?? '');
    _phoneController = TextEditingController(text: worker?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid ||
        name.isEmpty ||
        username.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields correctly before saving.',
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final worker = Worker(
      id: widget.workerToEdit?.id ?? '',
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      if (widget.isEditing) {
        await FirebaseService.updateWorker(worker);
      } else {
        await FirebaseService.addWorker(worker);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Worker profile updated successfully!'
                : 'Worker added successfully!',
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save worker. Please try again.'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleDelete() {
    CustomDeleteDialog.show(
      context,
      title: 'Delete Worker',
      message: 'Are you sure you want to delete ${widget.workerToEdit?.fullName}?',
      onConfirm: () async {
        Navigator.pop(context); // Close dialog
        try {
          if (widget.workerToEdit != null) {
            await FirebaseService.deleteWorker(widget.workerToEdit!.id);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Worker deleted successfully!'),
                backgroundColor: AppColors.primaryRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(); // Return from form
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting worker: $e'),
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
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeaderBar(
            title: isEditing ? AppStrings.editWorker : AppStrings.addWorker,
            subtitle:
                isEditing ? AppStrings.editWorkerSub : AppStrings.addWorkerSub,
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: AppStrings.fullNameLabel,
                      hintText: AppStrings.fullNameHint,
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full name is required';
                        }
                        final trimmed = value.trim();
                        if (trimmed.length < 3) {
                          return 'Full name must be at least 3 characters';
                        }
                        if (trimmed.length > 50) {
                          return 'Full name must not exceed 50 characters';
                        }
                        if (!RegExp(r"^[a-zA-Z\u0600-\u06FF\s\.\-']+$").hasMatch(trimmed)) {
                          return 'Full name must contain only letters and spaces';
                        }
                        if (trimmed.split(RegExp(r'\s+')).length < 2) {
                          return 'Please enter at least first and last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.usernameSystemLabel,
                      hintText: AppStrings.usernameSystemHint,
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username / System ID is required';
                        }
                        if (value.contains(' ')) {
                          return 'Username must not contain spaces';
                        }
                        if (value.trim().length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        if (value.trim().length > 30) {
                          return 'Username must not exceed 30 characters';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9._@-]+$').hasMatch(value.trim())) {
                          return 'Username can contain letters, numbers, @, dots, and underscores';
                        }
                        if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                          return 'Username must contain at least one letter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.passwordLabel,
                      hintText: AppStrings.passwordSystemHint,
                      controller: _passwordController,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        if (value.contains(' ')) {
                          return 'Password must not contain spaces';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        if (value.length > 50) {
                          return 'Password must not exceed 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      label: AppStrings.phoneNumberLabel,
                      hintText: AppStrings.phoneNumberHint,
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      maxLength: 11,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleSubmit(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number is required';
                        }
                        final digits = value.replaceAll(RegExp(r'\D'), '');
                        if (digits.length != 11) {
                          return 'Phone number must be exactly 11 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Main action button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing
                                        ? Icons.save_outlined
                                        : Icons.person_add_alt_1_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEditing
                                        ? AppStrings.updateWorkerBtn
                                        : AppStrings.addWorkerBtn,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 14),
                      // Delete worker secondary button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _handleDelete,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFFECDD3),
                              width: 1.2,
                            ),
                            backgroundColor: const Color(0xFFFFF1F2),
                            foregroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.primaryRed,
                              ),
                              SizedBox(width: 8),
                              Text(
                                AppStrings.deleteWorkerBtn,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
