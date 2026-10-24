import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/widgets.dart';
import '../screens/provider_dashboard_screen.dart';
import '../screens/provider_profile_screen.dart';
import '../screens/provider_requests_screen.dart';
import '../screens/provider_services_screen.dart';

class ProviderBottomNav extends StatelessWidget {
  final int currentIndex;

  const ProviderBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.off(() => const ProviderDashboardScreen());
        break;
      case 1:
        Get.off(() => const ProviderServicesScreen());
        break;
      case 2:
        Get.off(() => const ProviderRequestsScreen());
        break;
      case 3:
        Get.off(() => const ProviderProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomNavBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      items: const [
        AppNavItem(icon: Icons.grid_view_rounded, label: 'الرئيسية'),
        AppNavItem(icon: Icons.inventory_2_outlined, label: 'الخدمات'),
        AppNavItem(icon: Icons.inbox_outlined, label: 'الطلبات'),
        AppNavItem(icon: Icons.account_circle_outlined, label: 'الملف'),
      ],
    );
  }
}