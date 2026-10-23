import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

class StatusIllustration extends StatelessWidget {
  final String? assetPath; // Local Asset Image Path (e.g., assets/images/not_found.png)
  final IconData mainIcon;
  final Color iconColor;
  final Color circleBgColor;
  final IconData? badgeIcon;
  final Color? badgeBgColor;
  final String? centerText;

  const StatusIllustration({
    super.key,
    this.assetPath,
    required this.mainIcon,
    this.iconColor = AppColors.primary,
    this.circleBgColor = AppColors.surfaceSubdued,
    this.badgeIcon,
    this.badgeBgColor,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidAsset = assetPath != null && assetPath!.trim().isNotEmpty;

    // 1. If Local Asset Image Path exists
    if (hasValidAsset) {
      return SizedBox(
        width: 220,
        height: 220,
        child: Image.asset(
          assetPath!,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildCodeIllustration(),
        ),
      );
    }

    // 2. Fallback Code Illustration
    return _buildCodeIllustration();
  }

  Widget _buildCodeIllustration() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: circleBgColor,
              shape: BoxShape.circle,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mainIcon, size: 54, color: iconColor),
              if (centerText != null) ...[
                const SizedBox(height: 4),
                Text(
                  centerText!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ],
          ),
          if (badgeIcon != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeBgColor ?? AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Icon(badgeIcon, size: 14, color: AppColors.white),
              ),
            ),
        ],
      ),
    );
  }
}
