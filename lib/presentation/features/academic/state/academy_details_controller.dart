import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class AcademyDetailsController extends GetxController {
  final String providerId;

  AcademyDetailsController(this.providerId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final provider = <String, dynamic>{}.obs;
  final _courses = <Map<String, dynamic>>[].obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final isFavorite = false.obs;
  final selectedCategory = ''.obs;
  final showAllReviews = false.obs;

  String text(String key) => (provider[key] ?? '').toString();

  List<String> get categories => _courses
      .map((course) => (course['categorySubtag'] ?? '').toString())
      .where((category) => category.isNotEmpty)
      .toSet()
      .toList();

  List<Map<String, dynamic>> get courses => _courses
      .where((course) => selectedCategory.value.isEmpty || course['categorySubtag'] == selectedCategory.value)
      .toList();

  int get coursesCount => _courses.length;

  bool get hasDiscounts => _courses.any((course) => course['discountedPrice'] != null);

  List<Map<String, dynamic>> get instructors => ((provider['instructors'] ?? []) as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  List<Map<String, dynamic>> get visibleReviews => showAllReviews.value ? reviews : reviews.take(2).toList();

  int get reviewsCount => ((provider['ratingsCount'] ?? provider['reviewsCount'] ?? reviews.length) as num).toInt();

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  static String initials(String name) {
    final words = name.replaceAll('.', ' ').split(' ').where((word) => word.length > 1).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first.substring(0, 1);
    return '${words[0].substring(0, 1)}.${words[1].substring(0, 1)}';
  }

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(_db.collection('serviceProviders').doc(providerId).snapshots().listen((doc) {
      provider.value = doc.data() ?? {};
      isLoading.value = false;
    }, onError: _handleError));

    _subscriptions.add(_db
        .collection('courses')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      _courses.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((course) => course['isActive'] == true)
          .toList();
    }, onError: _handleError));

    _subscriptions.add(_db
        .collection('reviews')
        .where('targetId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      final list = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
      reviews.value = list;
    }, onError: (Object e) => debugPrint('AcademyDetailsController: $e')));

    _subscriptions.add(_db
        .collection('favorites')
        .doc('${currentStudentId}_$providerId')
        .snapshots()
        .listen((doc) => isFavorite.value = doc.exists,
        onError: (Object e) => debugPrint('AcademyDetailsController: $e')));
  }

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

  void _handleError(Object error) {
    debugPrint('AcademyDetailsController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل بيانات المركز';
    isLoading.value = false;
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void changeCategory(String category) =>
      selectedCategory.value = selectedCategory.value == category ? '' : category;

  Future<void> toggleFavorite() async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$providerId');

    try {
      if (isFavorite.value) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': providerId,
          'targetType': 'academy',
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('AcademyDetailsController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
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