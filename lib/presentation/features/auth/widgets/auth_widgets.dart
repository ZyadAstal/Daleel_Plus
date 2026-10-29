import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';

class MobilePage extends StatelessWidget {
  const MobilePage({
    super.key,
    required this.child,
    this.color = AppColors.white,
  });
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: color,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: AppSizes.space4 * 110),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 360,
            ),
            curve: Curves.easeOutCubic,
            child: child,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = AppSizes.space8 * 11});
  final double size;
  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: size,
    height: size,
    filterQuality: FilterQuality.high,
  );
}

class AppSnackbar {
  static void show(String message) {
    Get.snackbar(
      'تنبيه',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.white,
      colorText: AppColors.textPrimary,
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      borderWidth: 1,
      borderRadius: 16,
      margin: EdgeInsets.all(AppSizes.space16),
      padding: EdgeInsets.all(AppSizes.space16),
      maxWidth: AppSizes.space4 * 110,
      icon: Icon(Icons.info_outline, color: AppColors.primary),
      shouldIconPulse: false,
      titleText: Text(
        'تنبيه',
        textAlign: TextAlign.start,
        style: AppTextStyles.label.copyWith(
          fontFamily: 'Cairo',

          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      messageText: Text(
        message,
        textAlign: TextAlign.start,
        style: AppTextStyles.caption.copyWith(
          fontFamily: 'Cairo',

          color: AppColors.textPrimary,
        ),
      ),
      duration: Duration(seconds: 4),
      animationDuration: Duration(
        milliseconds:
            Get.context != null && MediaQuery.disableAnimationsOf(Get.context!)
            ? 0
            : 200,
      ),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    );
  }
}
