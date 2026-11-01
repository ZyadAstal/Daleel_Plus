import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

// عدد إشعارات الطالب غير المقروءة، للنقطة الحمرا على الجرس
class NotificationsBadgeController extends GetxController {
  final unreadCount = 0.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      unreadCount.value = result.docs.where((doc) => doc.data()['isRead'] != true).length;
    }, onError: (Object e) => debugPrint('NotificationsBadgeController: $e'));
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// permanent: بيضل شغال بين الشاشات، وبينحذف عند تسجيل الخروج
NotificationsBadgeController notificationsBadge() {
  if (Get.isRegistered<NotificationsBadgeController>()) {
    return Get.find<NotificationsBadgeController>();
  }
  return Get.put(NotificationsBadgeController(), permanent: true);
}
