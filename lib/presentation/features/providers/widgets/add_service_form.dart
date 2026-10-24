import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/widgets.dart';
import 'confirm_dialog.dart';

class FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSizes.space24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubdued,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          ...children,
        ],
      ),
    );
  }
}

class FormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final Widget? trailing;

  const FormLabel(this.text, {super.key, this.isRequired = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.space8),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                children: [
                  if (isRequired)
                    const TextSpan(text: ' *', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final String? suffixText;
  final int maxLines;
  final TextInputType? keyboardType;
  final Color? textColor;

  const FormInput({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.suffixText,
    this.maxLines = 1,
    this.keyboardType,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        fontWeight: suffixText != null ? FontWeight.w700 : FontWeight.w400,
        color: textColor ?? AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceSubdued,
        prefixIcon: icon == null ? null : Icon(icon, size: 20, color: AppColors.textSecondary),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          fontSize: 12,
          color: textColor ?? AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.space16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ChoiceButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ChoiceButton({
    super.key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.white : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: color),
              const SizedBox(height: AppSizes.space4),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class FormCheckRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isChecked;
  final VoidCallback onTap;

  const FormCheckRow({
    super.key,
    required this.label,
    required this.icon,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.space8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubdued,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class FormToggleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FormToggleCard({
    super.key,
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

void confirmCloseAddService(int openedSteps) {
  showConfirmDialog(
    title: 'إلغاء إضافة الخدمة',
    message: 'لن يتم حفظ البيانات التي أدخلتها. هل تريد الخروج؟',
    confirmText: 'خروج',
    icon: Icons.close,
    onConfirm: () => Get.close(openedSteps),
  );
}

void showUrlDialog({
  required String title,
  required String hint,
  required String initialValue,
  required ValueChanged<String> onSave,
}) {
  final controller = TextEditingController(text: initialValue);

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.space16),
            Directionality(
              textDirection: TextDirection.ltr,
              child: FormInput(
                controller: controller,
                hint: hint,
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(height: AppSizes.space24),
            AppPrimaryButton(
              text: 'حفظ',
              onPressed: () {
                onSave(controller.text.trim());
                Get.back();
              },
            ),
          ],
        ),
      ),
    ),
  );
}