import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class AuthErrorBanner extends StatelessWidget {
  final bool isVisible;
  final String title;
  final String message;

  const AuthErrorBanner({
    super.key,
    required this.isVisible,
    this.title = AppStrings.authFailedTitle,
    this.message = AppStrings.authFailedMessage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isVisible
          ? Container(
              key: const ValueKey('auth_error_banner_visible'),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.errorBorder,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 10),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.errorTextDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.errorTextLight,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(
              key: ValueKey('auth_error_banner_hidden'),
            ),
    );
  }
}
