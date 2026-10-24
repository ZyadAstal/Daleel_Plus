import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';

class StudentRequestCard extends StatelessWidget {
  final String studentName;
  final String avatarUrl;
  final String serviceName;
  final String price;
  final Color priceColor;
  final String statusText;
  final Color statusColor;
  final Color statusBackground;
  final IconData infoIcon;
  final String info;
  final String extraText;
  final Color extraColor;
  final bool isHighlighted;
  final Widget? bottom;

  const StudentRequestCard({
    super.key,
    required this.studentName,
    this.avatarUrl = '',
    required this.serviceName,
    required this.price,
    this.priceColor = AppColors.primary,
    required this.statusText,
    required this.statusColor,
    required this.statusBackground,
    this.infoIcon = Icons.access_time,
    required this.info,
    this.extraText = '',
    this.extraColor = AppColors.textSecondary,
    this.isHighlighted = false,
    this.bottom,
  });

  String get _initials {
    final name = studentName.trim();
    return name.length < 2 ? name : name.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.space16),
      padding: EdgeInsetsDirectional.only(start: isHighlighted ? 4 : 0),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Column(
          children: [
            _headerRow(),
            const SizedBox(height: AppSizes.space16),
            _infoRow(),
            if (bottom != null) ...[
              const SizedBox(height: AppSizes.space16),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.surfaceSubdued,
          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? Text(
            _initials,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSizes.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                serviceName,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.space8),
        Text(
          price,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: priceColor),
        ),
      ],
    );
  }

  Widget _infoRow() {
    return Row(
      children: [
        Icon(infoIcon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.space4),
        Expanded(
          child: Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ),
        Text(
          extraText,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: extraColor),
        ),
      ],
    );
  }
}