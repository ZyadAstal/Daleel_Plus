import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_gate.dart';
import 'provider_helpers.dart';

class ProviderProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  String get providerId => currentProviderId;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final provider = <String, dynamic>{}.obs;
  final studentsCount = 0.obs;
  final completedOrders = 0.obs;
  final publishedCourses = <Map<String, dynamic>>[].obs;
  final availableBalance = 0.0.obs;
  final lastPayoutDate = Rxn<DateTime>();

  String field(String key) => (provider[key] ?? '').toString();

  bool get isVerified => provider['verificationStatus'] == 'verified';
  bool get isAvailable => provider['isAcceptingOrders'] ?? true;
  double get rating => (provider['averageRating'] ?? 0).toDouble();
  int get reviewsCount => provider['reviewsCount'] ?? 0;

  List<Map<String, dynamic>> get instructors {
    final List list = provider['instructors'] ?? [];
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  String get location {
    final city = field('city');
    final address = field('addressDetails');
    return address.isEmpty ? city : '$city - $address';
  }

  String get ratingText => reviewsCount == 0
      ? 'لا توجد تقييمات بعد'
      : '(${ProviderFormat.number(reviewsCount)} تقييم طالب)';

  String get satisfactionText =>
      reviewsCount == 0 ? '—' : '${(rating / 5 * 100).round()}%';

  String get workingHoursText {
    final List days = provider['workingDays'] ?? [];
    if (days.isEmpty) return 'لم تُحدد بعد';

    final from = ProviderFormat.dayName(days.first);
    final to = ProviderFormat.dayName(days.last);
    final opening = ProviderFormat.time12h(field('openingTime'));
    final closing = ProviderFormat.time12h(field('closingTime'));
    return '$from - $to ($opening - $closing)';
  }

  String get cancellationText =>
      ProviderFormat.cancellationPolicy(provider['defaultCancellationPolicy']);

  String get lastPayoutText {
    final date = lastPayoutDate.value;
    if (date == null) return 'لا توجد تحويلات بنكية بعد';
    return 'آخر دورة تحويل بنكي: ${ProviderFormat.date(date)}';
  }

  @override
  void onInit() {
    super.onInit();
    _listenToProvider();
    _listenToOrders();
    _listenToCourses();
    _listenToWallet();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('ProviderProfileController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToProvider() {
    final subscription = _db
        .collection('serviceProviders')
        .doc(providerId)
        .snapshots()
        .listen((snapshot) {
      provider.value = snapshot.data() ?? {};
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
          .map((doc) => doc.data())
          .where((order) => order['orderStatus'] != 'canceled');

      studentsCount.value =
          orders.map((order) => order['studentId']).whereType<String>().toSet().length;
      completedOrders.value =
          orders.where((order) => order['orderStatus'] == 'completed').length;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToCourses() {
    final subscription = _db
        .collection('courses')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      publishedCourses.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((course) => course['status'] == 'published' && course['isActive'] == true)
          .toList();
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToWallet() {
    final subscription = _db
        .collection('financialTransactions')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      double balance = 0;
      DateTime? lastPayout;

      for (final doc in result.docs) {
        final data = doc.data();
        final amount = (data['netProviderAmount'] ?? 0).toDouble();
        final type = data['transactionType'];
        final payoutStatus = data['payoutStatus'];

        if (type == 'payment_in_platform' && payoutStatus == 'pending') balance += amount;
        if (type == 'refund') balance -= amount;

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (payoutStatus == 'transferred' &&
            createdAt != null &&
            (lastPayout == null || createdAt.isAfter(lastPayout))) {
          lastPayout = createdAt;
        }
      }

      availableBalance.value = balance;
      lastPayoutDate.value = lastPayout;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  final isSaving = false.obs;

  Future<bool> _updateProvider(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      await _db.collection('serviceProviders').doc(providerId).update({
        ...data,
        'updatedAt': Timestamp.now(),
      });
      Get.snackbar('تم', 'تم حفظ التغييرات');
      return true;
    } catch (e) {
      debugPrint('ProviderProfileController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغييرات، حاول مرة أخرى');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> saveWorkingHours({
    required List<String> days,
    required String openingTime,
    required String closingTime,
  }) {
    return _updateProvider({
      'workingDays': days,
      'openingTime': openingTime,
      'closingTime': closingTime,
    });
  }

  Future<bool> saveCancellationPolicy(String policy) {
    return _updateProvider({'defaultCancellationPolicy': policy});
  }

  Future<bool> saveWhatsapp(String number) {
    return _updateProvider({'whatsappNumber': number.trim()});
  }

  Future<void> logout() async {
    try {
      await Get.find<AuthRepository>().signOut();
      Get.offAll<void>(() => const AuthGate());
    } catch (e) {
      debugPrint('ProviderProfileController: $e');
      Get.snackbar('خطأ', 'لم يتم تسجيل الخروج، حاول مرة أخرى');
    }
  }
}