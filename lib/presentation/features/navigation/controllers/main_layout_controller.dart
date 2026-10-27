import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../discovery/screens/home_screen.dart';
import '../../discovery/screens/explore_screen.dart';

class MainLayoutController extends GetxController {
  final String? initialUid;
  var currentIndex = 0.obs;

  late final List<Widget> screens;

  MainLayoutController({this.initialUid}) {
    screens = [
      HomeScreen(targetUid: initialUid),
      ExploreScreen(),
      Container(), // طلباتي
      Container(), // المحفوظات
      Container(), // حسابي
    ];
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
