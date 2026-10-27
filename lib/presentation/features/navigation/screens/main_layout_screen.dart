import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_layout_controller.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainLayoutScreen extends StatelessWidget {
  final String? targetUid;

  MainLayoutScreen({Key? key, this.targetUid}) : super(key: key) {
    Get.put(MainLayoutController(initialUid: targetUid));
  }

  @override
  Widget build(BuildContext context) {
    final MainLayoutController controller = Get.find<MainLayoutController>();

    return Scaffold(
      body: Obx(() => controller.screens[controller.currentIndex.value]),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
