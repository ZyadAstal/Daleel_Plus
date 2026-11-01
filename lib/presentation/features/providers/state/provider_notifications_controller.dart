import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'provider_helpers.dart';

// إشعارات مقدم الخدمة: بنبنيها من طلباته وتقييماته (ما في جدول إشعارات منفصل للمزود)
class ProviderNotificationsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final orders = <Map<String, dynamic>>[].obs;
  final reviews = <Map<String, dynamic>>[].obs;

  // آخر مرة فتح فيها المزود صفحة الإشعارات (محفوظة بملفه بـ serviceProviders)
  final seenAt = Rxn<Timestamp>();
  // قيمة seenAt لحظة فتح الصفحة، عشان نلوّن الإشعارات اللي كانت جديدة
  Timestamp? seenBeforeOpen;

  static Timestamp _time(Map<String, dynamic> item) =>
      (item['updatedAt'] ?? item['createdAt']) as Timestamp? ?? Timestamp(0, 0);

  // الإشعار غير مقروء إذا وصل (createdAt) بعد آخر مرة فتح فيها الصفحة
  // بنستخدم createdAt مش updatedAt، عشان قبول المزود للطلب ما يرجّع النقطة
  bool isUnread(Map<String, dynamic> item, Timestamp? since) {
    final created = item['createdAt'] as Timestamp? ?? Timestamp(0, 0);
    return since == null || created.compareTo(since) > 0;
  }

  // النقطة الحمرا بتظهر بس إذا في إشعار غير مقروء
  int get unreadCount => items.where((item) => isUnread(item, seenAt.value)).length;

  // بننادي عليها لما تنفتح صفحة الإشعارات
  Future<void> markAllSeen() async {
    seenBeforeOpen = seenAt.value;
    final now = Timestamp.now();
    seenAt.value = now;
    try {
      await _db
          .collection('serviceProviders')
          .doc(currentProviderId)
          .set({'notificationsSeenAt': now}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ProviderNotificationsController: $e');
    }
  }

  // كل الإشعارات مرتبة من الأحدث
  List<Map<String, dynamic>> get items {
    final list = <Map<String, dynamic>>[
      for (final order in orders) {...order, 'kind': 'order'},
      for (final review in reviews) {...review, 'kind': 'review'},
    ];
    list.sort((a, b) => _time(b).compareTo(_time(a)));
    return list.take(30).toList();
  }

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(_db
        .collection('orders')
        .where('providerId', isEqualTo: currentProviderId)
        .snapshots()
        .listen((result) {
      orders.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: (Object e) {
      debugPrint('ProviderNotificationsController: $e');
      isLoading.value = false;
    }));

    _subscriptions.add(_db.collection('serviceProviders').doc(currentProviderId).snapshots().listen((doc) {
      seenAt.value = doc.data()?['notificationsSeenAt'] as Timestamp?;
    }, onError: (Object e) => debugPrint('ProviderNotificationsController: $e')));

    _subscriptions.add(_db
        .collection('reviews')
        .where('targetId', isEqualTo: currentProviderId)
        .snapshots()
        .listen((result) {
      reviews.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: (Object e) => debugPrint('ProviderNotificationsController: $e')));
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }
}

// نفس الكنترولر لشريط الأعلى (النقطة الحمرا) ولشاشة الإشعارات
// permanent: بيضل شغال بين التبويبات، وبينحذف عند تسجيل الخروج
ProviderNotificationsController providerNotifications() {
  if (Get.isRegistered<ProviderNotificationsController>()) {
    return Get.find<ProviderNotificationsController>();
  }
  return Get.put(ProviderNotificationsController(), permanent: true);
}
