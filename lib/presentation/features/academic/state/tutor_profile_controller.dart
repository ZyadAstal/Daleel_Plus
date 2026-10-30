import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../printing/state/print_centers_controller.dart';

class TutorProfileController extends GetxController {
  final String tutorId;

  TutorProfileController(this.tutorId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final tutor = <String, dynamic>{}.obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final isFavorite = false.obs;

  String text(String key) => (tutor[key] ?? '').toString();

  num number(String key) => (tutor[key] ?? 0) as num;

  List<String> textList(String key) =>
      ((tutor[key] ?? []) as List).map((item) => item.toString()).toList();

  List<Map<String, dynamic>> get subjects => ((tutor['subjects'] ?? []) as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  Map<String, dynamic> get hall => Map<String, dynamic>.from((tutor['hall'] ?? {}) as Map);

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  static String timeAgo(dynamic value) {
    if (value is! Timestamp) return '';
    final days = DateTime.now().difference(value.toDate()).inDays;
    if (days < 1) return 'اليوم';
    if (days < 7) return 'منذ $days أيام';
    if (days < 30) return 'منذ ${days ~/ 7} أسبوع';
    return 'منذ ${days ~/ 30} شهر';
  }

  @override
  void onInit() {
    super.onInit();
    _listenToTutor();
    _listenToReviews();
    _listenToFavorite();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('TutorProfileController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل بيانات المدرس';
    isLoading.value = false;
  }

  void _listenToTutor() {
    final subscription =
    _db.collection('serviceProviders').doc(tutorId).snapshots().listen((doc) {
      tutor.value = doc.data() ?? {};
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToReviews() {
    final subscription = _db
        .collection('reviews')
        .where('targetId', isEqualTo: tutorId)
        .snapshots()
        .listen((result) {
      final list = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      list.sort((a, b) {
        final dateA = a['createdAt'] is Timestamp ? (a['createdAt'] as Timestamp).toDate() : DateTime(2000);
        final dateB = b['createdAt'] is Timestamp ? (b['createdAt'] as Timestamp).toDate() : DateTime(2000);
        return dateB.compareTo(dateA);
      });
      reviews.value = list;
    }, onError: (Object e) => debugPrint('TutorProfileController: $e'));

    _subscriptions.add(subscription);
  }

  void _listenToFavorite() {
    final subscription = _db
        .collection('favorites')
        .doc('${currentStudentId}_$tutorId')
        .snapshots()
        .listen((doc) {
      isFavorite.value = doc.exists;
    }, onError: (Object e) => debugPrint('TutorProfileController: $e'));

    _subscriptions.add(subscription);
  }

  Future<void> toggleFavorite() async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$tutorId');

    try {
      if (isFavorite.value) {
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
      debugPrint('TutorProfileController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

  Future<void> _open(String url, String errorText) async {
    if (url.isEmpty) {
      Get.snackbar('غير متوفر', errorText);
      return;
    }

    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!opened) Get.snackbar('خطأ', errorText);
  }

  void callTutor() {
    final phone = text('phone');
    _open(phone.isEmpty ? '' : 'tel:$phone', 'رقم الهاتف غير متوفر');
  }

  void openWhatsapp() {
    final phone = text('whatsapp').replaceAll('+', '').replaceAll(' ', '');
    _open(phone.isEmpty ? '' : 'https://wa.me/$phone', 'رقم الواتساب غير متوفر');
  }

  void openLocation() {
    _open((hall['mapUrl'] ?? '').toString(), 'موقع القاعة غير متوفر');
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