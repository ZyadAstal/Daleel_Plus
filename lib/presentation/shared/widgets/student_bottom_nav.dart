import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/bookings/screens/my_orders_screen.dart';
import '../../features/bookings/screens/saved_screen.dart';
import '../../features/discovery/screens/explore_screen.dart';
import '../../features/discovery/screens/student_home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'app_bottom_nav_bar.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.offAll(() => const StudentHomeScreen());
        break;
      case 1:
        Get.off(() => const ExploreScreen());
        break;
      case 2:
        Get.off(() => const MyOrdersScreen());
        break;
      case 3:
        Get.off(() => const SavedScreen());
        break;
      case 4:
        Get.off(() => const ProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      items: const [
        AppNavItem(icon: Icons.home_outlined, label: 'الرئيسية'),
        AppNavItem(icon: Icons.explore_outlined, label: 'استكشاف'),
        AppNavItem(icon: Icons.receipt_long_outlined, label: 'طلباتي'),
        AppNavItem(icon: Icons.bookmark_border, label: 'المحفوظات'),
        AppNavItem(icon: Icons.person_outline, label: 'حسابي'),
      ],
    );
  }
}