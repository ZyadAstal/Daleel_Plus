import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class JobsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _jobs = <Map<String, dynamic>>[].obs;
  final applications = <Map<String, dynamic>>[].obs;
  final favoriteIds = <String>{}.obs;
  final student = <String, dynamic>{}.obs;
  final searchText = ''.obs;

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  List<Map<String, dynamic>> get jobs {
    final query = _normalize(searchText.value);
    final list = _jobs.where((job) {
      if (query.isEmpty) return true;
      return _normalize([job['title'], job['companyName'], job['location'], job['workTypeLabel']].join(' '))
          .contains(query);
    }).toList();
    list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
    return list;
  }

  Set<String> get appliedJobIds => applications.map((item) => (item['jobId'] ?? '').toString()).toSet();

  int get pendingApplications => applications.where((item) => item['status'] == 'submitted').length;

  String get applicationsText => applications.map((item) => (item['companyName'] ?? '').toString()).take(2).join(' + ');

  String get major => (student['specialization'] ?? student['major'] ?? '').toString();

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

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

    _subscriptions.add(_db.collection('jobs').where('status', isEqualTo: 'open').snapshots().listen((result) {
      _jobs.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: (Object error) {
      debugPrint('JobsController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل الفرص';
      isLoading.value = false;
    }));

    _subscriptions.add(_db
        .collection('jobApplications')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      applications.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: (Object e) => debugPrint('JobsController: $e')));

    _subscriptions.add(_db
        .collection('favorites')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      favoriteIds.value = result.docs
          .map((doc) => doc.data())
          .where((data) => data['targetType'] == 'job')
          .map((data) => data['targetId'].toString())
          .toSet();
    }, onError: (Object e) => debugPrint('JobsController: $e')));

    _subscriptions.add(_db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      student.value = doc.data() ?? {};
    }, onError: (Object e) => debugPrint('JobsController: $e')));
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void changeSearch(String value) => searchText.value = value;

  Future<void> toggleFavorite(String jobId) async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$jobId');
    try {
      if (favoriteIds.contains(jobId)) {
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
      debugPrint('JobsController: $e');
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