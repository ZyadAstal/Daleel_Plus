import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

class StatusActionButtons extends StatelessWidget {
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimaryPressed;

  final String secondaryLabel;
  final IconData secondaryIcon;
  final VoidCallback onSecondaryPressed;

  const StatusActionButtons({
    super.key,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    required this.secondaryLabel,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onPrimaryPressed,
            icon: Icon(primaryIcon, size: 20),
            label: Text(primaryLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton.icon(
            onPressed: onSecondaryPressed,
            icon: Icon(secondaryIcon, size: 20, color: AppColors.primary),
            label: Text(
              secondaryLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceSubdued,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
