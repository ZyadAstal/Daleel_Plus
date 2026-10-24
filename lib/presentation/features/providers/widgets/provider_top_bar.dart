import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';

class ProviderTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool? isVerified;
  final bool? isAvailable;

  const ProviderTopBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.isVerified,
    this.isAvailable,
  });

  bool get _hasStatus => isVerified != null && isAvailable != null;

  bool get _isActive => (isVerified ?? false) && (isAvailable ?? false);

  String get _statusText {
    final verified = isVerified! ? 'مزود معتمد' : 'بانتظار التوثيق';
    final available = isAvailable! ? 'نشط' : 'غير متاح';
    return '$verified · $available';
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBg,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppSizes.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.space16),
          child: Row(
            children: [
              showBack ? _backButton() : _storeIcon(),
              const SizedBox(width: 12),
              Expanded(child: _titleBlock()),
              _notificationIcon(),
              const SizedBox(width: AppSizes.space16),
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_outline, color: AppColors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return IconButton(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
    );
  }

  Widget _storeIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceSubdued,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 20),
    );
  }

  Widget _titleBlock() {
    final statusColor = _isActive ? AppColors.success : AppColors.textHint;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (_hasStatus)
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _isActive ? AppColors.success : AppColors.textHint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(_statusText, style: TextStyle(fontSize: 11, color: statusColor)),
            ],
          ),
      ],
    );
  }

  Widget _notificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 24),
        Positioned(
          top: -1,
          right: -1,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}