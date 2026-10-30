import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class TutorsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _tutors = <Map<String, dynamic>>[].obs;
  final favoriteIds = <String>{}.obs;
  final searchText = ''.obs;
  final department = ''.obs;

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  static List<String> subjectsOf(Map<String, dynamic> tutor) =>
      ((tutor['subjects'] ?? []) as List).map((subject) => (subject['name'] ?? '').toString()).toList();

  int get tutorsCount => _tutors.length;

  List<String> get departments => _tutors
      .map((tutor) => (tutor['department'] ?? '').toString())
      .where((text) => text.isNotEmpty)
      .toSet()
      .toList();

  List<Map<String, dynamic>> get tutors {
    final query = _normalize(searchText.value);
    final list = _tutors.where((tutor) {
      final matchesDepartment = department.value.isEmpty || tutor['department'] == department.value;
      final text = _normalize([tutor['businessName'], tutor['headline'], ...subjectsOf(tutor)].join(' '));
      return matchesDepartment && (query.isEmpty || text.contains(query));
    }).toList();
    list.sort((a, b) => ((b['averageRating'] ?? 0) as num).compareTo((a['averageRating'] ?? 0) as num));
    return list;
  }

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(_db
        .collection('serviceProviders')
        .where('providerType', isEqualTo: 'tutor')
        .snapshots()
        .listen((result) {
      _tutors.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: (Object error) {
      debugPrint('TutorsController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل المدرسين';
      isLoading.value = false;
    }));

    _subscriptions.add(_db
        .collection('favorites')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      favoriteIds.value = result.docs
          .map((doc) => doc.data())
          .where((data) => data['targetType'] == 'tutor')
          .map((data) => data['targetId'].toString())
          .toSet();
    }, onError: (Object e) => debugPrint('TutorsController: $e')));
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void changeSearch(String value) => searchText.value = value;

  void changeDepartment(String value) => department.value = value;

  Future<void> toggleFavorite(String tutorId) async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$tutorId');
    try {
      if (favoriteIds.contains(tutorId)) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': tutorId,
          'targetType': 'tutor',
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('TutorsController: $e');
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