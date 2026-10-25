import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/auth/state/email_verification_controller.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<EmailVerificationController>(
    init: EmailVerificationController(),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) => _render(context, c),
  );

  Widget _render(
    BuildContext context,
    EmailVerificationController c,
  ) => MobilePage(
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSizes.space24,
        AppSizes.space4 * 14,
        AppSizes.space24,
        AppSizes.space4 * 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: SizedBox(
              width: AppSizes.space4 * 23,
              height: AppSizes.space4 * 23,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: AppSizes.bottomNavHeight,
                    height: AppSizes.bottomNavHeight,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubdued,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: AppSizes.space4 * 14,
                        height: AppSizes.space4 * 14,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mark_email_read_rounded,
                          color: AppColors.primary,
                          size: AppSizes.space4 * 8,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSizes.space4,
                    bottom: AppSizes.space8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primary,
                        size: AppSizes.space4 * 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.space4 * 5),
          Text(
            'تحقق من بريدك الإلكتروني',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.space4 * 3),
          Text(
            c.sent
                ? 'أرسلنا رابط تأكيد إلى بريدك الإلكتروني. افتح الرابط وسنتابع تلقائيًا بعد تأكيد بريدك.'
                : 'سنرسل رابطًا لتأكيد ملكيتك للبريد الإلكتروني قبل الدخول إلى حسابك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSizes.space16),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.space16,
                vertical: AppSizes.space8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubdued,
                borderRadius: BorderRadius.circular(AppSizes.space24),
              ),
              child: Text(
                c.service.currentUser?.email ?? '',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(height: AppSizes.space24),
          Text(
            'تحقق أيضًا من مجلد الرسائل غير المرغوبة. إذا كان البريد غير صحيح، سجّل الخروج واستخدم البريد الصحيح.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.space24),
          AppPrimaryButton(
            text: 'تأكيد ومتابعة',
            isLoading: c.busy,
            onPressed: c.busy ? null : c.check,
          ),
          SizedBox(height: AppSizes.space16),
          if (c.remaining > 0)
            Text(
              'إعادة الإرسال خلال 00:${c.remaining.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          TextButton(
            onPressed: c.busy || c.remaining > 0 ? null : c.send,
            child: Text(
              'أعد إرسال رابط التحقق',
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: c.busy ? null : c.signOut,
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    ),
  );
}
