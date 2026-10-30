import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

enum OrdersTab { active, completed, canceled }

class MyOrdersController extends GetxController {
  final OrdersTab initialTab;

  MyOrdersController({this.initialTab = OrdersTab.active});

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _orders = <Map<String, dynamic>>[].obs;
  final _providers = <String, Map<String, dynamic>>{}.obs;
  final _courses = <String, Map<String, dynamic>>{}.obs;

  final tab = OrdersTab.active.obs;
  final searchText = ''.obs;
  final typeFilter = ''.obs;
  final hideReviewPrompt = false.obs;

  static const Map<String, String> typeNames = {
    '': 'كل الأنواع',
    'printing': 'طباعة وتجليد',
    'course': 'حجز مقعد تدريبي',
    'session': 'جلسة تدريس خصوصي',
  };

  static OrdersTab tabOf(Map<String, dynamic> order) {
    switch (order['orderStatus']) {
      case 'completed':
        return OrdersTab.completed;
      case 'canceled':
        return OrdersTab.canceled;
      default:
        return OrdersTab.active;
    }
  }

  int countFor(OrdersTab value) => _orders.where((order) => tabOf(order) == value).length;

  Map<String, dynamic> providerOf(Map<String, dynamic> order) =>
      _providers[(order['providerId'] ?? '').toString()] ?? {};

  Map<String, dynamic> courseOf(Map<String, dynamic> order) => _courses[(order['courseId'] ?? '').toString()] ?? {};

  List<Map<String, dynamic>> get orders {
    final query = searchText.value.trim().toLowerCase();
    final list = _orders.where((order) {
      final text = [order['orderNumber'], order['itemTitle'], providerOf(order)['businessName']]
          .join(' ')
          .toLowerCase();
      return tabOf(order) == tab.value &&
          (typeFilter.value.isEmpty || order['orderType'] == typeFilter.value) &&
          (query.isEmpty || text.contains(query));
    }).toList();
    list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
    return list;
  }

  Map<String, dynamic>? get reviewPrompt => hideReviewPrompt.value
      ? null
      : _orders.firstWhereOrNull((order) => order['orderStatus'] == 'completed' && order['isReviewed'] != true);

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

  @override
  void onInit() {
    super.onInit();
    tab.value = initialTab;

    _subscriptions.add(_db
        .collection('orders')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      _orders.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
      _loadDetails();
    }, onError: (Object error) {
      debugPrint('MyOrdersController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل الطلبات';
      isLoading.value = false;
    }));
  }

  Future<void> _loadDetails() async {
    try {
      for (final order in _orders) {
        final providerId = (order['providerId'] ?? '').toString();
        final courseId = (order['courseId'] ?? '').toString();
        if (providerId.isNotEmpty && !_providers.containsKey(providerId)) {
          final doc = await _db.collection('serviceProviders').doc(providerId).get();
          _providers[providerId] = doc.data() ?? {};
        }
        if (courseId.isNotEmpty && !_courses.containsKey(courseId)) {
          final doc = await _db.collection('courses').doc(courseId).get();
          _courses[courseId] = doc.data() ?? {};
        }
      }
    } catch (e) {
      debugPrint('MyOrdersController: $e');
    }
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void changeTab(OrdersTab value) => tab.value = value;

  void changeSearch(String value) => searchText.value = value;

  void changeType(String value) => typeFilter.value = value;

  Future<void> requestReschedule(Map<String, dynamic> order) async {
    try {
      await _db.collection('orders').doc(order['id']).update({
        'rescheduleRequested': true,
        'updatedAt': Timestamp.now(),
      });
      Get.snackbar('تم إرسال الطلب', 'سيتواصل معك المدرس لاختيار موعد جديد');
    } catch (e) {
      debugPrint('MyOrdersController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال طلب إعادة الجدولة');
    }
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