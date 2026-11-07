import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/services/biometric_service.dart';
import '../core/services/firebase_service.dart';
import '../features/auth/widgets/auth_error_banner.dart';
import '../features/auth/widgets/custom_text_field.dart';
import '../features/auth/widgets/sign_in_button.dart';
import 'admin_main_screen.dart';
import 'worker_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasAuthError = false;

  void _clearErrorOnInput() {
    if (_hasAuthError) {
      setState(() {
        _hasAuthError = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleSignIn() async {
    FocusScope.of(context).unfocus();
    _clearErrorOnInput();

    // Validate required fields
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final role = await FirebaseService.signIn(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (role != null) {
        await BiometricService.saveSuccessfulLogin(
          role: role,
          workerName: FirebaseService.currentWorkerName,
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasAuthError = false;
        });
        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => WorkerProfileScreen(
                workerName: FirebaseService.currentWorkerName.isNotEmpty
                    ? FirebaseService.currentWorkerName
                    : AppStrings.defaultWorkerName,
              ),
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('SignIn error: $e');
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasAuthError = true;
    });
  }

  Future<void> _handleBiometricLogin() async {
    FocusScope.of(context).unfocus();
    _clearErrorOnInput();

    // Check if a previous successful login with username & password exists
    final bool hasSaved = await BiometricService.hasSavedLogin();
    if (!hasSaved) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fingerprint data saved. Please login with username and password first.',
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Attempt phone fingerprint scan via native OS biometric prompt
    final bool didAuthenticate =
        await BiometricService.authenticateWithFingerprint();

    if (!mounted) return;

    if (didAuthenticate) {
      // Read the role and worker name of the last login with username & password
      final lastRole = await BiometricService.getLastLoginRole();
      final lastWorkerName = await BiometricService.getLastWorkerName();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasAuthError = false;
      });

      if (lastRole == 'worker') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WorkerProfileScreen(
              workerName: (lastWorkerName != null && lastWorkerName.isNotEmpty)
                  ? lastWorkerName
                  : AppStrings.defaultWorkerName,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _hasAuthError = true;
      });

      // If biometric hardware is un-enrolled (e.g. PC or simulator), provide simulator helper
      final bool canCheck = await BiometricService.canCheckBiometrics();
      if (!canCheck && mounted) {
        _showBiometricSimulationSheet();
      }
    }
  }

  void _showBiometricSimulationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 54,
                color: AppColors.primaryRed,
              ),
              const SizedBox(height: 16),
              const Text(
                'Biometric Simulator',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Biometric hardware not detected or not enrolled. Simulate last login role:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await BiometricService.saveLastLoginRole('admin');
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const AdminMainScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text('Admin Login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await BiometricService.saveLastLoginRole('worker');
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const WorkerProfileScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text('Worker Login'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Elsewedy Electric Logo (Enlarged)
                Center(
                  child: Image.asset(
                    AppAssets.logo,
                    height: 195,
                    width: 340,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ELSEWEDY',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            height: 4,
                            width: 230,
                            color: AppColors.textDark,
                          ),
                          const Text(
                            'ELECTRIC',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.5,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 4.5,
                            width: 180,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Error Banner (only visible after incorrect login attempt)
                AuthErrorBanner(
                  isVisible: _hasAuthError,
                  title: AppStrings.authFailedTitle,
                  message: AppStrings.authFailedMessage,
                ),

                // Username / Employee ID Input
                CustomTextField(
                  label: AppStrings.usernameLabel,
                  hintText: AppStrings.usernameHint,
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _clearErrorOnInput(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username / Employee ID is required';
                    }
                    if (value.contains(' ')) {
                      return 'Username must not contain spaces';
                    }
                    if (value.trim().length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value.trim().length > 50) {
                      return 'Username must not exceed 50 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Input
                CustomTextField(
                  label: AppStrings.passwordLabel,
                  hintText: AppStrings.passwordHint,
                  controller: _passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: _togglePasswordVisibility,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleSignIn(),
                  onChanged: (_) => _clearErrorOnInput(),
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

                const SizedBox(height: 28),

                // Sign In Button
                SignInButton(
                  onPressed: _handleSignIn,
                  isLoading: _isLoading,
                  label: AppStrings.signIn,
                ),

                const SizedBox(height: 24),

                // "Or" Divider with red lines
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: AppColors.dividerLine,
                        thickness: 1.2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        AppStrings.orDivider,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: AppColors.dividerLine,
                        thickness: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Biometric Login Button
                InkWell(
                  onTap: _isLoading ? null : _handleBiometricLogin,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          color: AppColors.primaryRed,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.loginWithBiometrics,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                            letterSpacing: 0.1,
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
      ),
    );
  }
}
