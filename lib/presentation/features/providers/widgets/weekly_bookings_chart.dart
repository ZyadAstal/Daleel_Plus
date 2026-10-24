import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';

class WeeklyBookingsChart extends StatelessWidget {
  final List<int> counts;

  const WeeklyBookingsChart({super.key, required this.counts});

  static const double _maxBarHeight = 96;
  static const double _emptyBarHeight = 8;
  static const int _minScale = 10;

  static const List<String> _shortDays = [
    'سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة',
  ];

  static const List<String> _fullDays = [
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
  ];

  int get _maxCount => counts.reduce((a, b) => a > b ? a : b);

  Set<int> get _topDays {
    final ranked = List.generate(counts.length, (i) => i)
        .where((i) => counts[i] > 0)
        .toList()
      ..sort((a, b) => counts[b].compareTo(counts[a]));
    return ranked.take(2).toSet();
  }

  String get _peakText {
    final days = _topDays.toList()..sort();
    if (days.isEmpty) return 'لا توجد حجوزات خلال هذا الأسبوع';
    if (days.length == 1) return 'ذروة التسجيل يوم ${_fullDays[days.first]}';
    return 'ذروة التسجيل يومي ${_fullDays[days[0]]} و${_fullDays[days[1]]}';
  }

  @override
  Widget build(BuildContext context) {
    final maxCount = _maxCount;
    final scale = maxCount < _minScale ? _minScale : maxCount;
    final topDays = _topDays;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: AppSizes.space16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(counts.length, (index) {
              final count = counts[index];
              final isTop = topDays.contains(index);
              final barHeight =
              count == 0 ? _emptyBarHeight : _maxBarHeight * count / scale;

              return Expanded(
                child: Column(
                  children: [
                    if (count == maxCount && count > 0)
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: AppSizes.space4),
                    Container(
                      height: barHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isTop ? AppColors.primary : AppColors.surfaceSubdued,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.space8),
                    Text(
                      _shortDays[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isTop ? FontWeight.w700 : FontWeight.w400,
                        color: isTop ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نشاط الحجوزات الأسبوعي',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                _peakText,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubdued,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'هذا الأسبوع',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}