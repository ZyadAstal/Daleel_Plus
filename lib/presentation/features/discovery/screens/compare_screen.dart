import 'package:flutter/material.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/student_top_bar.dart';
import '../state/search_controller.dart';

class CompareScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const CompareScreen({super.key, required this.items});

  static num _price(Map<String, dynamic> item) => item['price'] ?? 0;

  static num _hours(Map<String, dynamic> item) => item['raw']['totalHours'] ?? 0;

  static String _name(Map<String, dynamic> item) {
    final name = (item['providerName'] ?? '').toString();
    return item['type'] == 'tutor' || name.isEmpty ? (item['title'] ?? '').toString() : name;
  }

  static String _raw(Map<String, dynamic> item, String key) => (item['raw'][key] ?? '').toString();

  String _recommendation(Map<String, dynamic> cheap, Map<String, dynamic> other) {
    final diff = _price(other) - _price(cheap);
    if (diff <= 0) {
      final best = (cheap['rating'] as num) >= (other['rating'] as num) ? cheap : other;
      return 'الخياران بنفس السعر تقريبًا، و${_name(best)} يحصل على تقييم أعلى من الطلاب.';
    }

    final percent = (diff / _price(other) * 100).round();
    final extraHours = _hours(cheap) - _hours(other);
    final hoursText = extraHours > 0 ? ' ساعات تدريبية إضافية (+$extraHours ساعة)' : '';
    final ratingText = (cheap['rating'] as num) >= (other['rating'] as num) ? ' مع تقييم أعلى من الطلاب.' : '.';
    return '${_name(cheap)} توفر$hoursText بسعر أوفر بنسبة $percent%$ratingText';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]..sort((a, b) => _price(a).compareTo(_price(b)));
    final cheap = sorted.first;
    final other = sorted.last;
    final priceDiff = _price(other) - _price(cheap);
    final maxHours = _hours(cheap) > _hours(other) ? _hours(cheap) : _hours(other);

    final rows = <Widget>[
      _CompareRow(
        icon: Icons.payments_outlined,
        title: 'التكلفة والرسوم الإجمالية',
        badge: priceDiff > 0 ? 'فارق ${DiscoverySearchController.money(priceDiff)} ₪' : null,
        cells: [
          _Cell(
            value: '${DiscoverySearchController.money(_price(cheap))} ₪',
            note: priceDiff > 0 ? 'الخيار الأفضل سعرا' : '',
            isBest: priceDiff > 0,
          ),
          _Cell(value: '${DiscoverySearchController.money(_price(other))} ₪', note: other['priceUnit'] ?? ''),
        ],
      ),
      if (_hours(cheap) > 0 || _hours(other) > 0)
        _CompareRow(
          icon: Icons.schedule,
          title: 'الساعات التدريبية الفعلية',
          trailing: 'محتوى أعمق',
          cells: [cheap, other]
              .map((item) => _Cell(
            value: _hours(item) > 0 ? '${_hours(item)} ساعة' : '-',
            note: _raw(item, 'durationLabel'),
            isBest: _hours(cheap) != _hours(other) && _hours(item) == maxHours,
            highlightText: true,
          ))
              .toList(),
        ),
      _CompareRow(
        icon: Icons.location_on_outlined,
        title: 'طريقة الحضور والموقع',
        cells: [cheap, other]
            .map((item) => _Cell(
          value: DiscoverySearchController.modeLabels[(item['modes'] as List).first] ?? '-',
          note: item['area'] ?? '',
          icon: Icons.apartment_outlined,
        ))
            .toList(),
      ),
      _CompareRow(
        icon: Icons.verified_outlined,
        title: 'الشهادة والاعتمادات الرسمية',
        cells: [cheap, other]
            .map((item) => _Cell(
          value: _raw(item, 'certificateLabel').isNotEmpty
              ? _raw(item, 'certificateLabel')
              : (item['hasCertificate'] == true ? 'شهادة معتمدة' : 'شهادة إتمام'),
          note: _raw(item, 'certificateNote'),
          icon: Icons.workspace_premium_outlined,
        ))
            .toList(),
      ),
      _CompareRow(
        icon: Icons.star_border_rounded,
        title: 'تقييم الطلاب وخبرة الخريجين',
        cells: [cheap, other]
            .map((item) => _Cell(
          value: (item['rating'] as num) > 0 ? '★ ${DiscoverySearchController.ratingText(item['rating'])}' : '-',
          note: '${item['ratingsCount'] ?? 0} تقييم موثق',
        ))
            .toList(),
      ),
      if (cheap['raw']['facilities'] != null || other['raw']['facilities'] != null)
        _CompareRow(
          icon: Icons.bolt,
          title: 'تجهيزات القاعات واستمرارية الطاقة',
          cells: [cheap, other].map((item) {
            final facilities = (item['raw']['facilities'] ?? []) as List;
            return _Cell(
              value: facilities.isEmpty ? '-' : (facilities.first['title'] ?? '').toString(),
              note: facilities.isEmpty ? '' : (facilities.first['subtitle'] ?? '').toString(),
              icon: Icons.wifi,
            );
          }).toList(),
        ),
      if (_raw(cheap, 'graduationProject').isNotEmpty || _raw(other, 'graduationProject').isNotEmpty)
        _CompareRow(
          icon: Icons.work_outline,
          title: 'مشروع التخرج والتأهيل لسوق العمل',
          cells: [cheap, other]
              .map((item) => _Cell(
            value: _raw(item, 'graduationProject').isEmpty ? '-' : _raw(item, 'graduationProject'),
            note: _raw(item, 'graduationNote'),
            icon: Icons.folder_open_outlined,
          ))
              .toList(),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: const StudentTopBar(title: 'مقارنة خدمات'),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.space24),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '✨ أداة المقارنة المباشرة',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'مقارنة تفصيلية بين خدمتين مختارتين',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'قارن الأسعار، الميزات، والموقع الجغرافي لاختيار الأنسب لميزانيتك ومسارك الأكاديمي.',
            style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.space16),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(child: _HeaderCard(item: cheap, badge: priceDiff > 0 ? 'الأكثر توفيرا' : '', isBest: true)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HeaderCard(
                      item: other,
                      badge: DiscoverySearchController.modeLabels[(other['modes'] as List).first] ?? '',
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.scaffoldBg, width: 3),
                ),
                child: const Text(
                  'vs',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.space16),
          Container(
            padding: const EdgeInsets.all(AppSizes.space16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'توصية دليل+ الذكية',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _recommendation(cheap, other),
                        style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.space24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'جدول المقارنة المنهجي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Text(
                '${rows.length} معايير تقييم',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
          const SizedBox(height: AppSizes.space8),
          const Center(
            child: Text(
              'اختر مقعدك وابدأ التسجيل مباشرة',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _BookButton(item: cheap, isPrimary: true)),
              const SizedBox(width: 12),
              Expanded(child: _BookButton(item: other, isPrimary: false)),
            ],
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
    ],
  );
}

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String badge;
  final bool isBest;

  const _HeaderCard({required this.item, required this.badge, this.isBest = false});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (item['imageUrl'] ?? '').toString();
    final num oldPrice = item['oldPrice'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceSubdued,
            backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
            child: imageUrl.isEmpty ? const Icon(Icons.school_outlined, color: AppColors.primary) : null,
          ),
          const SizedBox(height: AppSizes.space8),
          if (badge.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isBest ? AppColors.success : AppColors.secondary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isBest ? AppColors.success : AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            CompareScreen._name(item),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          Text(
            item['title'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            '${DiscoverySearchController.money(CompareScreen._price(item))} ₪',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isBest ? AppColors.success : AppColors.textPrimary,
            ),
          ),
          Text(
            oldPrice > 0 ? 'بدل ${DiscoverySearchController.money(oldPrice)} ₪' : '/ ${item['priceUnit']}',
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Cell {
  final String value;
  final String note;
  final bool isBest;
  final bool highlightText;
  final IconData? icon;

  const _Cell({
    required this.value,
    this.note = '',
    this.isBest = false,
    this.highlightText = false,
    this.icon,
  });
}

class _CompareRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final String? trailing;
  final List<_Cell> cells;

  const _CompareRow({required this.icon, required this.title, required this.cells, this.badge, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSizes.space16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSizes.space8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success),
                  ),
                ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _CellBox(cell: cells[0])),
                const SizedBox(width: 10),
                Expanded(child: _CellBox(cell: cells[1])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CellBox extends StatelessWidget {
  final _Cell cell;

  const _CellBox({required this.cell});

  @override
  Widget build(BuildContext context) {
    final isGreen = cell.isBest && !cell.highlightText;
    Color valueColor = AppColors.textPrimary;
    if (cell.isBest) valueColor = cell.highlightText ? AppColors.primary : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGreen ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceSubdued,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cell.icon != null) ...[
            Icon(cell.icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
          ],
          Text(
            cell.value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: valueColor),
          ),
          if (cell.note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              cell.note,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isGreen ? FontWeight.w700 : FontWeight.w400,
                color: isGreen ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isPrimary;

  const _BookButton({required this.item, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DiscoverySearchController.openItem(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            Text(
              'احجز في ${CompareScreen._name(item)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPrimary ? AppColors.white : AppColors.primary,
              ),
            ),
            Text(
              '(${DiscoverySearchController.money(CompareScreen._price(item))} ₪)',
              style: TextStyle(fontSize: 11, color: isPrimary ? AppColors.white : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}