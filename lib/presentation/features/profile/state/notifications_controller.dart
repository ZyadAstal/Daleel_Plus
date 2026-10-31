import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../printing/state/print_centers_controller.dart';

class NotificationsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final notifications = <Map<String, dynamic>>[].obs;
  final settings = <String, dynamic>{}.obs;

  int get unreadCount =>
      notifications.where((item) => item['isRead'] != true).length;

  static DateTime date(Map<String, dynamic> item) {
    final value = item['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime(2000);
  }

  List<Map<String, dynamic>> get today => notifications
      .where((item) => DateTime.now().difference(date(item)).inHours < 24)
      .toList();

  List<Map<String, dynamic>> get thisWeek => notifications.where((item) {
    final hours = DateTime.now().difference(date(item)).inHours;
    return hours >= 24 && hours < 24 * 7;
  }).toList();

  List<Map<String, dynamic>> get older => notifications
      .where((item) => DateTime.now().difference(date(item)).inDays >= 7)
      .toList();

  static String timeAgo(Map<String, dynamic> item) {
    final diff = DateTime.now().difference(date(item));
    if (diff.inMinutes < 60)
      return 'منذ ${diff.inMinutes < 1 ? 1 : diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} أيام';
  }

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(
      _db
          .collection('notifications')
          .where('studentId', isEqualTo: currentStudentId)
          .snapshots()
          .listen(
            (result) {
              final list = result.docs
                  .map((doc) => {...doc.data(), 'id': doc.id})
                  .toList();
              list.sort((a, b) => date(b).compareTo(date(a)));
              notifications.value = list;
              isLoading.value = false;
            },
            onError: (Object error) {
              debugPrint('NotificationsController: $error');
              errorMessage.value = 'حدث خطأ أثناء تحميل الإشعارات';
              isLoading.value = false;
            },
          ),
    );

    _subscriptions.add(
      _db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
        settings.value = Map<String, dynamic>.from(
          (doc.data()?['settings'] ?? {}) as Map,
        );
      }, onError: (Object e) => debugPrint('NotificationsController: $e')),
    );
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  Future<void> markRead(Map<String, dynamic> item) async {
    if (item['isRead'] == true) return;
    await _db.collection('notifications').doc(item['id']).update({
      'isRead': true,
    });
  }

  Future<void> markAllRead() async {
    final batch = _db.batch();
    for (final item in notifications.where((item) => item['isRead'] != true)) {
      batch.update(_db.collection('notifications').doc(item['id']), {
        'isRead': true,
      });
    }
    await batch.commit();
  }

  Future<void> confirmAction(Map<String, dynamic> item) async {
    await _db.collection('notifications').doc(item['id']).update({
      'actionDone': true,
      'isRead': true,
    });
    Get.snackbar('تم التأكيد', 'تم إبلاغ الجهة بتأكيدك');
  }

  Future<void> requestChange(Map<String, dynamic> item) async {
    await _db.collection('notifications').doc(item['id']).update({
      'changeRequested': true,
      'isRead': true,
    });
    Get.snackbar('تم إرسال الطلب', 'سيتم التواصل معك لاقتراح موعد آخر');
  }

  Future<void> copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    Get.snackbar('تم نسخ الرمز', code);
  }

  Future<void> openMap(Map<String, dynamic> item) async {
    final url = (item['mapUrl'] ?? '').toString();
    await launchUrl(
      url.isEmpty
          ? Uri.https('www.google.com', '/maps/search/', {
              'api': '1',
              'query': '${item['locationText'] ?? ''}',
            })
          : Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> addToCalendar(Map<String, dynamic> item) async {
    final value = item['eventAt'];
    if (value is! Timestamp) return;
    String format(DateTime date) {
      final utc = date.toUtc();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${utc.year}${two(utc.month)}${two(utc.day)}T${two(utc.hour)}${two(utc.minute)}00Z';
    }

    final start = value.toDate();
    await launchUrl(
      Uri.https('calendar.google.com', '/calendar/render', {
        'action': 'TEMPLATE',
        'text': (item['title'] ?? '').toString(),
        'dates':
            '${format(start)}/${format(start.add(const Duration(hours: 2)))}',
        'location': (item['locationText'] ?? '').toString(),
      }),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> toggleSetting(String key, bool value) async {
    await _db.collection('Users').doc(currentStudentId).set({
      'settings': {key: value},
    }, SetOptions(merge: true));
  }

  void retry() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    errorMessage.value = '';
    isLoading.value = true;
    onInit();
  }
}
