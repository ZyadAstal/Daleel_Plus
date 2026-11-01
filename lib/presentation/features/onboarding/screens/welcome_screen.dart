import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
import 'package:daleel_plus/presentation/shared/theme/app_text_styles.dart';
import 'package:daleel_plus/presentation/shared/constants/app_sizes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:daleel_plus/presentation/shared/constants/app_colors.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';
import 'package:daleel_plus/presentation/features/onboarding/state/onboarding_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  static const _purple = LinearGradient(
    colors: [Color(0xFF9B87F5), AppColors.primary],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void initState() {
    super.initState();
    _progress.forward().then((_) {
      if (mounted) Get.off<void>(() => OnboardingScreen());
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MobilePage(
    color: AppColors.scaffoldBg,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.space4 * 7,
              vertical: AppSizes.space4 * 7,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: AppSizes.space4 * 9),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppSizes.space4 * 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: 0.09803921568627451,
                            ),
                            blurRadius: AppSizes.space4 * 8,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(AppSizes.space8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.space4 * 4),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: AppSizes.space4 * 27,
                          height: AppSizes.space4 * 27,
                          filterQuality: FilterQuality.high,
                        ),
                      ),                    ),
                    SizedBox(height: AppSizes.space4 * 5),
                    Text(
                      'دليل +',
                      style: AppTextStyles.display.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+ D A L E E L ',
                      style: AppTextStyles.caption.copyWith(
                        letterSpacing: AppSizes.space4,
                      ),
                    ),
                    SizedBox(height: AppSizes.space4 * 9),
                    Text(
                      'كل ما تحتاجه كطالب... في مكان واحد',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge,
                    ),
                    SizedBox(height: AppSizes.space4 * 3),
                    Text(
                      'خدمات موثوقة  •  فرص مميزة  •  مجتمع طلابي',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppSizes.space4 * 18),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _progress.value >= 1 ? 'جاهز للبدء!' : 'جاري التحميل...',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) => _purple.createShader(bounds),
                              child: Text(
                                '${(_progress.value * 100).round()}%',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.space4 * 3),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 4,
                            color: AppColors.surfaceSubdued,
                            alignment: AlignmentDirectional.centerStart,
                            child: FractionallySizedBox(
                              widthFactor: _progress.value,
                              child: Container(
                                decoration: const BoxDecoration(gradient: _purple),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSizes.space4 * 3),
                        Text(
                          'منصتك لجميع الخدمات الطلابية',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSizes.space4 * 5),
                        Text(
                          'تعلّم، اكتشف، وتواصل... مستقبلك يبدأ هنا',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => GetBuilder<OnboardingController>(
    init: OnboardingController(),
    global: false,
    dispose: (state) => state.controller?.onDelete(),
    builder: (c) => _render(context, c),
  );

  Widget _render(BuildContext context, OnboardingController c) => MobilePage(
    color: AppColors.scaffoldBg,
    child: Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: c.finishing ? null : c.finish,
            child: Text(
              'تخطّي',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: c.controller,
            itemCount: c.pages.length,
            onPageChanged: (value) => c.change(() => c.index = value),
            itemBuilder: (context, index) {
              final page = c.pages[index];
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.space24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSizes.space24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.09),
                              blurRadius: 18,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.space24),
                          child: Image.asset(
                            'assets/images/${page.image}.png',
                            height: (constraints.maxHeight * 0.43).clamp(
                              100.0,
                              300.0,
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.space16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.space4 * 3,
                          vertical: AppSizes.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubdued,
                          borderRadius: BorderRadius.circular(
                            AppSizes.space4 * 5,
                          ),
                        ),
                        child: Text(
                          page.badge,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSizes.space16),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizes.space4 * 3),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSizes.space24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: page.tags
                            .map(
                              (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.space4 * 3,
                              vertical: AppSizes.space8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubdued,
                              borderRadius: BorderRadius.circular(
                                AppSizes.space8,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.space24,
            AppSizes.space4 * 5,
            AppSizes.space24,
            AppSizes.space4 * 7,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: index == c.index
                        ? AppSizes.space24
                        : AppSizes.space8,
                    height: AppSizes.space8,
                    margin: EdgeInsets.symmetric(horizontal: AppSizes.space4),
                    decoration: BoxDecoration(
                      color: index == c.index
                          ? AppColors.primary
                          : AppColors.border,
                      borderRadius: BorderRadius.circular(AppSizes.space8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.space4 * 5),
              AppPrimaryButton(
                text: c.index == 2 ? 'ابدأ الآن' : 'التالي',
                onPressed: c.finishing
                    ? null
                    : () {
                  if (c.index == 2) {
                    c.finish();
                  } else {
                    c.controller.nextPage(
                      duration: Duration(
                        milliseconds:
                        MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 420,
                      ),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}