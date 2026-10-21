import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

// عنصر واحد في شريط التنقل
class AppNavItem {
  final IconData icon;
  final String label;

  const AppNavItem({required this.icon, required this.label});
}

// شريط التنقل السفلي: ارتفاع 80، أيقونة 20، نص 12، مسافة 4 بينهما
// يشتغل للطالب (5 عناصر) ولمزود الخدمة (4 عناصر)
//
// الاستخدام:
// AppBottomNavBar(
//   currentIndex: 0,
//   onTap: (i) {},
//   items: const [
//     AppNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
//     AppNavItem(icon: Icons.explore_outlined, label: 'استكشاف'),
//   ],
// )
class AppBottomNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          bool isSelected = index == currentIndex;
          Color color = isSelected ? AppColors.primary : AppColors.textHint;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceSubdued : null,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(items[index].icon, size: AppSizes.navIconSize, color: color),
                  ),
                  const SizedBox(height: AppSizes.space4),
                  Text(
                    items[index].label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
