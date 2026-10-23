import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';

class StatusPageLayout extends StatelessWidget {
  final Widget? topPillWidget;
  final Widget illustration;
  final String title;
  final String description;
  final Widget? middleCard;
  final Widget actionButtons;

  const StatusPageLayout({
    super.key,
    this.topPillWidget,
    required this.illustration,
    required this.title,
    required this.description,
    this.middleCard,
    required this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // Top Pill Status Tag
                    if (topPillWidget != null) ...[
                      topPillWidget!,
                      const SizedBox(height: 24),
                    ],

                    // Illustration
                    illustration,

                    const SizedBox(height: 20),

                    // Main Heading
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle / Description
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Middle Custom Card
                    if (middleCard != null) ...[
                      middleCard!,
                      const SizedBox(height: 24),
                    ],

                    // Bottom Action Buttons
                    actionButtons,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
