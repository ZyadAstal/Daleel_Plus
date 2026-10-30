import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class AddReviewController extends GetxController {
  final String orderId;

  AddReviewController(this.orderId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final commentController = TextEditingController();

  final isLoading = true.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;

  final order = <String, dynamic>{}.obs;
  final providerName = ''.obs;
  final courseImage = ''.obs;
  final student = <String, dynamic>{}.obs;

  final rating = 5.obs;
  final criteria = <String, int>{
    'content': 5,
    'commitment': 5,
    'environment': 4,
    'support': 5,
  }.obs;
  final selectedTags = <String>{}.obs;
  final images = <String>[].obs;
  final isAnonymous = false.obs;
  final commentLength = 0.obs;

  static const Map<String, String> criteriaNames = {
    'content': 'جودة المحتوى والشرح الأكاديمي',
    'commitment': 'الالتزام بالمواعيد والوقت المحدد',
    'environment': 'بيئة القاعات والكهرباء والإنترنت',
    'support': 'التعاون والدعم الفني للمتدربين',
  };

  static const Map<String, IconData> criteriaIcons = {
    'content': Icons.menu_book_outlined,
    'commitment': Icons.schedule,
    'environment': Icons.wifi,
    'support': Icons.support_agent,
  };

  static const List<String> tags = [
    '👨‍🏫 مدرب متمكن',
    '💻 شرح عملي وتطبيقي',
    '❄️ قاعة مجهزة ومكيفة',
    '🚀 مشاريع حقيقية',
    '🏷️ سعر مناسب للطلاب',
  ];

  static const Map<int, String> ratingLabels = {
    1: 'سيئ',
    2: 'مقبول',
    3: 'جيد',
    4: 'جيد جدا',
    5: 'ممتاز جدا',
  };

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String text(String key) => (order[key] ?? '').toString();

  bool get isCompleted => order['orderStatus'] == 'completed';

  bool get isReviewed => order['isReviewed'] == true;

  bool get canSubmit => isCompleted && !isReviewed && !isSending.value;

  String get completedDate {
    final value = order['completedAt'] ?? order['updatedAt'] ?? order['createdAt'];
    if (value is! Timestamp) return '';
    final date = value.toDate();
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String get studentInfo => [student['specialization'] ?? student['major'], student['university']]
      .where((text) => (text ?? '').toString().isNotEmpty)
      .join(' - ');

  @override
  void onInit() {
    super.onInit();
    commentController.addListener(() => commentLength.value = commentController.text.length);

    _subscriptions.add(_db.collection('orders').doc(orderId).snapshots().listen((doc) {
      order.value = doc.data() ?? {};
      isLoading.value = false;
      _loadNames();
    }, onError: (Object error) {
      debugPrint('AddReviewController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل الطلب';
      isLoading.value = false;
    }));

    _subscriptions.add(_db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      student.value = doc.data() ?? {};
    }, onError: (Object e) => debugPrint('AddReviewController: $e')));
  }

  Future<void> _loadNames() async {
    final providerId = text('providerId');
    final courseId = text('courseId');
    try {
      if (providerId.isNotEmpty && providerName.value.isEmpty) {
        final provider = await _db.collection('serviceProviders').doc(providerId).get();
        providerName.value = (provider.data()?['businessName'] ?? '').toString();
      }
      if (courseId.isNotEmpty && courseImage.value.isEmpty) {
        final course = await _db.collection('courses').doc(courseId).get();
        courseImage.value = (course.data()?['coverImageUrl'] ?? '').toString();
      }
    } catch (e) {
      debugPrint('AddReviewController: $e');
    }
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    commentController.dispose();
    super.onClose();
  }

  void changeRating(int value) => rating.value = value;

  void changeCriteria(String key, int value) => criteria[key] = value;

  void toggleTag(String tag) => selectedTags.contains(tag) ? selectedTags.remove(tag) : selectedTags.add(tag);

  void addImage(String url) {
    final link = url.trim();
    if (link.startsWith('http')) {
      images.add(link);
    } else {
      Get.snackbar('رابط غير صحيح', 'أدخل رابط صورة يبدأ بـ http');
    }
  }

  void removeImage(String url) => images.remove(url);

  Future<bool> submit() async {
    if (commentController.text.trim().length < 10) {
      Get.snackbar('المراجعة قصيرة', 'اكتب مراجعة لا تقل عن 10 أحرف');
      return false;
    }

    final providerId = text('providerId');
    if (providerId.isEmpty) {
      Get.snackbar('خطأ', 'لا يمكن تقييم هذا الطلب');
      return false;
    }

    isSending.value = true;
    try {
      final courseId = text('courseId');
      final newRating = rating.value;

      await _db.runTransaction((transaction) async {
        final providerRef = _db.collection('serviceProviders').doc(providerId);
        final courseRef = courseId.isEmpty ? null : _db.collection('courses').doc(courseId);
        final providerDoc = await transaction.get(providerRef);
        final courseDoc = courseRef == null ? null : await transaction.get(courseRef);

        Map<String, dynamic> newAverage(Map<String, dynamic>? data) {
          final num average = data?['averageRating'] ?? 0;
          final num count = data?['ratingsCount'] ?? 0;
          final total = average * count + newRating;
          return {
            'averageRating': double.parse((total / (count + 1)).toStringAsFixed(2)),
            'ratingsCount': count + 1,
          };
        }

        transaction.set(_db.collection('reviews').doc(), {
          'orderId': orderId,
          'targetId': providerId,
          'targetType': text('orderType') == 'course' ? 'academy' : text('orderType'),
          'courseId': courseId,
          'studentId': currentStudentId,
          'studentName': student['name'] ?? '',
          'studentInfo': studentInfo,
          'rating': newRating,
          'criteria': Map<String, int>.from(criteria),
          'tags': selectedTags.toList(),
          'comment': commentController.text.trim(),
          'images': images.toList(),
          'isAnonymous': isAnonymous.value,
          'createdAt': Timestamp.now(),
        });

        transaction.update(_db.collection('orders').doc(orderId), {'isReviewed': true});

        if (providerDoc.exists) transaction.update(providerRef, newAverage(providerDoc.data()));
        if (courseRef != null && courseDoc != null && courseDoc.exists) {
          transaction.update(courseRef, newAverage(courseDoc.data()));
        }
      });
      return true;
    } catch (e) {
      debugPrint('AddReviewController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال التقييم، حاول مرة أخرى');
      return false;
    } finally {
      isSending.value = false;
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