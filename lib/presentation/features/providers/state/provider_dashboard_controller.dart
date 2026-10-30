import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'provider_helpers.dart';

class ProviderDashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  String get providerId => currentProviderId;

  DocumentReference<Map<String, dynamic>> get _providerDoc =>
      _db.collection('serviceProviders').doc(providerId);

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final businessName = ''.obs;
  final headline = ''.obs;
  final city = ''.obs;
  final addressDetails = ''.obs;
  final logoUrl = ''.obs;
  final isVerified = false.obs;
  final isAvailable = true.obs;
  final rating = 0.0.obs;
  final reviewsCount = 0.obs;

  final totalOrders = 0.obs;
  final monthOrders = 0.obs;
  final previousMonthOrders = 0.obs;
  final newOrdersCount = 0.obs;
  final netEarnings = 0.0.obs;
  final activeCourses = 0.obs;
  final pendingReviewCourses = 0.obs;

  final weeklyCounts = List<int>.filled(7, 0).obs;
  final latestOrders = <Map<String, dynamic>>[].obs;
  final acceptingOrderId = ''.obs;

  String get locationText {
    final place = addressDetails.value.isEmpty
        ? city.value
        : '${city.value} - ${addressDetails.value}';
    return headline.value.isEmpty ? place : '$place · ${headline.value}';
  }

  String get ratingText =>
      reviewsCount.value == 0 ? 'جديد' : rating.value.toStringAsFixed(1);

  String get reviewsNote => reviewsCount.value == 0
      ? 'لا توجد تقييمات بعد'
      : 'من ${ProviderFormat.number(reviewsCount.value)} تقييم موثق';

  String get monthGrowthText {
    final current = monthOrders.value;
    final previous = previousMonthOrders.value;
    if (previous == 0) return '+$current هذا الشهر';

    final percent = ((current - previous) / previous * 100).round();
    return '${percent >= 0 ? '+' : ''}$percent% هذا الشهر';
  }

  @override
  void onInit() {
    super.onInit();
    _start();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  Future<void> _start() async {
    try {
      await _createProfileIfMissing();
    } catch (e) {
      _handleError(e);
      return;
    }

    _listenToProvider();
    _listenToOrders();
    _listenToCourses();
    _listenToEarnings();
  }

  void _handleError(Object error) {
    debugPrint('ProviderDashboardController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  Future<void> _createProfileIfMissing() async {
    final providerSnapshot = await _providerDoc.get();
    if (providerSnapshot.exists) return;

    final userSnapshot = await _db.collection('Users').doc(providerId).get();
    final user = userSnapshot.data() ?? {};

    final locationParts = (user['location'] ?? '').toString().split(' - ');
    final city = locationParts.first.trim();
    final address = locationParts.skip(1).join(' - ').trim();

    await _providerDoc.set({
      'uid': providerId,
      'providerType': user['providerType'] ?? '',
      'businessName': user['name'] ?? '',
      'headline': user['field'] ?? '',
      'city': city,
      'addressDetails': address,
      'commercialRegisterOrPortfolio': user['portfolio'] ?? '',
      'whatsappNumber': user['phone'] ?? '',
      'bioDescription': '',
      'latitude': null,
      'longitude': null,
      'licenseNumber': '',
      'verificationStatus': 'pending',
      'averageRating': 0,
      'reviewsCount': 0,
      'logoUrl': '',
      'coverImageUrl': '',
      'isAcceptingOrders': true,
      'workingDays': [],
      'openingTime': '',
      'closingTime': '',
      'defaultCancellationPolicy': 'full_refund_48h',
      'payoutBankName': '',
      'instructors': [],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  void _listenToProvider() {
    final subscription = _providerDoc.snapshots().listen((snapshot) {
      final data = snapshot.data() ?? {};

      businessName.value = data['businessName'] ?? '';
      headline.value = data['headline'] ?? '';
      city.value = data['city'] ?? '';
      addressDetails.value = data['addressDetails'] ?? '';
      logoUrl.value = data['logoUrl'] ?? '';
      isVerified.value = data['verificationStatus'] == 'verified';
      isAvailable.value = data['isAcceptingOrders'] ?? true;
      rating.value = (data['averageRating'] ?? 0).toDouble();
      reviewsCount.value = data['reviewsCount'] ?? 0;

      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToOrders() {
    final subscription = _db
        .collection('orders')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      final orders = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((order) => order['orderStatus'] != 'canceled')
          .toList()
        ..sort((a, b) {
          final first = a['createdAt'] as Timestamp? ?? Timestamp.now();
          final second = b['createdAt'] as Timestamp? ?? Timestamp.now();
          return second.compareTo(first);
        });

      totalOrders.value = orders.length;
      newOrdersCount.value =
          orders.where((order) => order['orderStatus'] == 'pending').length;
      latestOrders.value = orders.take(3).toList();

      _calculatePeriods(orders);
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _calculatePeriods(List<Map<String, dynamic>> orders) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 7));
    final monthStart = now.subtract(const Duration(days: 30));
    final previousMonthStart = now.subtract(const Duration(days: 60));

    final counts = List<int>.filled(7, 0);
    int month = 0;
    int previousMonth = 0;

    for (final order in orders) {
      final createdAt = order['createdAt'] as Timestamp?;
      if (createdAt == null) continue;
      final date = createdAt.toDate();

      if (date.isAfter(weekStart)) counts[(date.weekday + 1) % 7]++;
      if (date.isAfter(monthStart)) {
        month++;
      } else if (date.isAfter(previousMonthStart)) {
        previousMonth++;
      }
    }

    weeklyCounts.value = counts;
    monthOrders.value = month;
    previousMonthOrders.value = previousMonth;
  }

  void _listenToCourses() {
    final subscription = _db
        .collection('courses')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      final courses = result.docs.map((doc) => doc.data()).toList();

      activeCourses.value = courses
          .where((course) => course['status'] == 'published' && course['isActive'] == true)
          .length;
      pendingReviewCourses.value = courses
          .where((course) =>
      course['status'] == 'draft' || course['status'] == 'pending_review')
          .length;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToEarnings() {
    final subscription = _db
        .collection('financialTransactions')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      double total = 0;

      for (final doc in result.docs) {
        final data = doc.data();
        final amount = (data['netProviderAmount'] ?? 0).toDouble();

        if (data['transactionType'] == 'payment_in_platform') total += amount;
        if (data['transactionType'] == 'refund') total -= amount;
      }

      netEarnings.value = total;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  Future<void> changeAvailability(bool value) async {
    try {
      await _providerDoc.update({
        'isAcceptingOrders': value,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('ProviderDashboardController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

  Future<void> acceptOrder(Map<String, dynamic> order) async {
    if (acceptingOrderId.value.isNotEmpty) return;
    acceptingOrderId.value = order['id'];

    try {
      await _db.collection('orders').doc(order['id']).update({
        'orderStatus': 'confirmed',
        'updatedAt': Timestamp.now(),
      });

      final courseId = (order['courseId'] ?? '').toString();
      if (courseId.isNotEmpty) {
        await _db.collection('courses').doc(courseId).update({
          'bookedSeats': FieldValue.increment(1),
          'updatedAt': Timestamp.now(),
        });
      }

      Get.snackbar('تم', 'تم قبول طلب ${order['studentName'] ?? ''}');
    } catch (e) {
      debugPrint('ProviderDashboardController: $e');
      Get.snackbar('خطأ', 'لم يتم قبول الطلب، حاول مرة أخرى');
    } finally {
      acceptingOrderId.value = '';
    }
  }
}