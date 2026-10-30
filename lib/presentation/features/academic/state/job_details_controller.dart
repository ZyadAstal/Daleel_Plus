import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class JobDetailsController extends GetxController {
  final String jobId;

  JobDetailsController(this.jobId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;

  final job = <String, dynamic>{}.obs;
  final student = <String, dynamic>{}.obs;
  final myApplication = Rxn<Map<String, dynamic>>();
  final isFavorite = false.obs;

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String text(String key) => (job[key] ?? '').toString();

  List<Map<String, dynamic>> listOf(String key) => ((job[key] ?? []) as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  List<String> get tags => ((job['tags'] ?? []) as List).map((item) => item.toString()).toList();

  String get deadlineText {
    final value = job['deadline'];
    if (value is! Timestamp) return '-';
    final date = value.toDate();
    final days = date.difference(DateTime.now()).inDays;
    return 'متبقي ${days < 0 ? 0 : days} أيام (${date.day} ${_months[date.month - 1]})';
  }

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(_db.collection('jobs').doc(jobId).snapshots().listen((doc) {
      job.value = doc.data() ?? {};
      isLoading.value = false;
    }, onError: (Object error) {
      debugPrint('JobDetailsController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل الفرصة';
      isLoading.value = false;
    }));

    _subscriptions.add(_db
        .collection('jobApplications')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      myApplication.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList()
          .firstWhereOrNull((item) => item['jobId'] == jobId);
    }, onError: (Object e) => debugPrint('JobDetailsController: $e')));

    _subscriptions.add(_db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      student.value = doc.data() ?? {};
    }, onError: (Object e) => debugPrint('JobDetailsController: $e')));

    _subscriptions.add(_db
        .collection('favorites')
        .doc('${currentStudentId}_$jobId')
        .snapshots()
        .listen((doc) => isFavorite.value = doc.exists,
        onError: (Object e) => debugPrint('JobDetailsController: $e')));
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  Future<void> toggleFavorite() async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$jobId');
    try {
      if (isFavorite.value) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': jobId,
          'targetType': 'job',
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('JobDetailsController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

  Future<bool> apply({required String cvUrl, required String note}) async {
    if (!cvUrl.trim().startsWith('http')) {
      Get.snackbar('رابط غير صحيح', 'أضف رابط السيرة الذاتية (Google Drive أو غيره)');
      return false;
    }

    isSending.value = true;
    try {
      await _db.collection('jobApplications').add({
        'jobId': jobId,
        'jobTitle': job['title'] ?? '',
        'companyName': job['companyName'] ?? '',
        'studentId': currentStudentId,
        'studentName': student['name'] ?? '',
        'studentUniversity': student['university'] ?? '',
        'studentMajor': student['specialization'] ?? student['major'] ?? '',
        'portfolioUrl': student['portfolioUrl'] ?? '',
        'cvUrl': cvUrl.trim(),
        'note': note.trim(),
        'status': 'submitted',
        'createdAt': Timestamp.now(),
      });
      await _db.collection('jobs').doc(jobId).update({'applicantsCount': FieldValue.increment(1)});
      return true;
    } catch (e) {
      debugPrint('JobDetailsController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال طلب التقديم، حاول مرة أخرى');
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