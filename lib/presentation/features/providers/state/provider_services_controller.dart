import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'provider_helpers.dart';

enum ServiceFilter { all, active, full, paused }

class ProviderServicesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  String get providerId => currentProviderId;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final isVerified = false.obs;
  final isAvailable = true.obs;

  final courses = <Map<String, dynamic>>[].obs;
  final weeklyOrdersByCourse = <String, int>{}.obs;

  final selectedFilter = ServiceFilter.all.obs;
  final searchText = ''.obs;

  static bool isHourly(Map<String, dynamic> course) => course['pricingUnit'] == 'hour';

  static bool isFull(Map<String, dynamic> course) {
    final maxSeats = (course['maxSeats'] as num? ?? 0).toInt();
    final bookedSeats = (course['bookedSeats'] as num? ?? 0).toInt();
    return !isHourly(course) && maxSeats > 0 && bookedSeats >= maxSeats;
  }

  static bool isActive(Map<String, dynamic> course) => course['isActive'] ?? true;

  bool _matchesFilter(Map<String, dynamic> course, ServiceFilter filter) {
    switch (filter) {
      case ServiceFilter.all:
        return true;
      case ServiceFilter.active:
        return isActive(course) && !isFull(course);
      case ServiceFilter.full:
        return isActive(course) && isFull(course);
      case ServiceFilter.paused:
        return !isActive(course);
    }
  }

  int countFor(ServiceFilter filter) =>
      courses.where((course) => _matchesFilter(course, filter)).length;

  List<Map<String, dynamic>> get visibleCourses {
    final query = searchText.value.trim();

    return courses.where((course) {
      final title = (course['title'] ?? '').toString();
      return _matchesFilter(course, selectedFilter.value) &&
          (query.isEmpty || title.contains(query));
    }).toList();
  }

  Map<String, dynamic>? get mostRequestedCourse {
    if (weeklyOrdersByCourse.isEmpty) return null;

    final top = weeklyOrdersByCourse.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return courses.firstWhereOrNull((course) => course['id'] == top.key);
  }

  int get mostRequestedCount {
    final course = mostRequestedCourse;
    return course == null ? 0 : weeklyOrdersByCourse[course['id']] ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    _listenToProvider();
    _listenToCourses();
    _listenToWeeklyOrders();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('ProviderServicesController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToProvider() {
    final subscription = _db
        .collection('serviceProviders')
        .doc(providerId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data() ?? {};
      isVerified.value = data['verificationStatus'] == 'verified';
      isAvailable.value = data['isAcceptingOrders'] ?? true;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToCourses() {
    final subscription = _db
        .collection('courses')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      courses.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList()
        ..sort((a, b) {
          final first = a['createdAt'] as Timestamp? ?? Timestamp.now();
          final second = b['createdAt'] as Timestamp? ?? Timestamp.now();
          return second.compareTo(first);
        });
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToWeeklyOrders() {
    final subscription = _db
        .collection('orders')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      final weekStart = DateTime.now().subtract(const Duration(days: 7));
      final counts = <String, int>{};

      for (final doc in result.docs) {
        final order = doc.data();
        final courseId = (order['courseId'] ?? '').toString();
        final createdAt = (order['createdAt'] as Timestamp?)?.toDate();

        if (courseId.isEmpty || order['orderStatus'] == 'canceled') continue;
        if (createdAt == null || createdAt.isBefore(weekStart)) continue;

        counts[courseId] = (counts[courseId] ?? 0) + 1;
      }

      weeklyOrdersByCourse.value = counts;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void changeFilter(ServiceFilter filter) => selectedFilter.value = filter;

  void changeSearch(String value) => searchText.value = value;

  Future<void> changeActive(Map<String, dynamic> course, bool value) async {
    try {
      await _db.collection('courses').doc(course['id']).update({
        'isActive': value,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('ProviderServicesController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

  Future<void> deleteCourse(Map<String, dynamic> course) async {
    try {
      await _db.collection('courses').doc(course['id']).delete();
      Get.snackbar('تم', 'تم حذف ${course['title'] ?? 'الخدمة'}');
    } catch (e) {
      debugPrint('ProviderServicesController: $e');
      Get.snackbar('خطأ', 'لم يتم حذف الخدمة، حاول مرة أخرى');
    }
  }
}