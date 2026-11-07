import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomHeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;

  const CustomHeaderBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 18, right: 10, top: 12, bottom: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBackButton) ...[
              InkWell(
                onTap: onBack ?? () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryRed,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                AppAssets.logo,
                height: 58,
                width: 145,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ELSEWEDY',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        height: 2.5,
                        width: 82,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: AppColors.primaryRed,
                      ),
                      const Text(
                        'ELECTRIC',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
