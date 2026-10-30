import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class StudentHomeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final student = <String, dynamic>{}.obs;
  final offer = Rxn<Map<String, dynamic>>();
  final _courses = <Map<String, dynamic>>[].obs;
  final _jobs = <Map<String, dynamic>>[].obs;
  final _providers = <Map<String, dynamic>>[].obs;
  final favoriteIds = <String>{}.obs;

  String get firstName {
    final name = (student['name'] ?? '').toString().trim();
    return name.isEmpty ? 'بك' : name.split(' ').first;
  }

  String get universityText {
    final university = (student['university'] ?? '').toString();
    final major = (student['specialization'] ?? student['major'] ?? '').toString();
    return [university, major].where((text) => text.isNotEmpty).join(' - ');
  }

  int get coursesCount => _courses.length;

  int get jobsCount => _jobs.length;

  int get printCentersCount => _providersOfType('printing').length;

  int get tutorsCount => _providersOfType('privateTutor').length;

  List<Map<String, dynamic>> get featuredCourses {
    final list = _courses
        .map((course) => {...course, 'providerName': providerName((course['providerId'] ?? '').toString())})
        .toList();
    list.sort((a, b) => rating(b).compareTo(rating(a)));
    return list.take(6).toList();
  }

  List<Map<String, dynamic>> get latestJobs {
    final list = [..._jobs];
    list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
    return list.take(3).toList();
  }

  List<Map<String, dynamic>> get topTutors {
    final list = _providersOfType('privateTutor');
    list.sort((a, b) => rating(b).compareTo(rating(a)));
    return list.take(6).toList();
  }

  List<Map<String, dynamic>> _providersOfType(String type) =>
      _providers.where((provider) => provider['providerType'] == type).toList();

  String providerName(String providerId) {
    final provider = _providers.firstWhereOrNull((p) => p['id'] == providerId);
    return (provider?['businessName'] ?? '').toString();
  }

  static double rating(Map<String, dynamic> item) =>
      ((item['averageRating'] ?? 0) as num).toDouble();

  static DateTime _date(dynamic value) =>
      value is Timestamp ? value.toDate() : DateTime(2000);

  static int daysLeft(dynamic value) {
    if (value is! Timestamp) return 0;
    final days = value.toDate().difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();
    _listenToStudent();
    _listenToOffers();
    _listenToCourses();
    _listenToJobs();
    _listenToProviders();
    _listenToFavorites();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('StudentHomeController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToStudent() {
    final subscription =
    _db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      student.value = doc.data() ?? {};
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToOffers() {
    final subscription = _db
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((result) {
      final offers = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      offers.sort((a, b) => _date(a['endsAt']).compareTo(_date(b['endsAt'])));
      offer.value = offers.isEmpty ? null : offers.first;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToCourses() {
    final subscription = _db
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((result) {
      _courses.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToJobs() {
    final subscription = _db
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((result) {
      _jobs.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToProviders() {
    final subscription = _db.collection('serviceProviders').snapshots().listen((result) {
      _providers.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToFavorites() {
    final subscription = _db
        .collection('favorites')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      favoriteIds.value =
          result.docs.map((doc) => doc.data()['targetId'].toString()).toSet();
    }, onError: (Object e) => debugPrint('StudentHomeController: $e'));

    _subscriptions.add(subscription);
  }

  Future<void> toggleFavorite(String targetId, String targetType) async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$targetId');

    try {
      if (favoriteIds.contains(targetId)) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': targetId,
          'targetType': targetType,
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('StudentHomeController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

  Future<void> copyOfferCode() async {
    final code = (offer.value?['code'] ?? '').toString();
    if (code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));
    Get.snackbar('تم نسخ الكود', 'استخدم $code عند الدفع أو الحجز');
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