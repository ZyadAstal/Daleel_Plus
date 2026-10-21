import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_text_styles.dart';

// الزر الرئيسي: ارتفاع 54، شكل كبسولة، ظل بنفسجي
// isSecondary: true يعطي الزر الفاتح (مثل: العودة للرئيسية، حفظ كمسودة)
//
// الاستخدام:
// AppPrimaryButton(text: 'التالي', icon: Icons.arrow_back, onPressed: () {})
// AppPrimaryButton(text: 'حفظ كمسودة', isSecondary: true, onPressed: () {})
class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = isSecondary ? AppColors.surfaceSubdued : AppColors.primary;
    Color textColor = isSecondary ? AppColors.primary : AppColors.white;

    return Container(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        // الظل للزر الرئيسي فقط
        boxShadow: isSecondary
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text),
                  if (icon != null) ...[
                    const SizedBox(width: AppSizes.space8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}
