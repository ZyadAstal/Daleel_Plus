import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/screens/auth_gate.dart';

import '../../printing/state/print_centers_controller.dart';

class StudentAccountController extends GetxController {
  static StudentAccountController get instance =>
      Get.isRegistered<StudentAccountController>()
      ? Get.find<StudentAccountController>()
      : Get.put(StudentAccountController());

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final student = <String, dynamic>{}.obs;
  final completedOrders = 0.obs;
  final favoritesCount = 0.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final universityController = TextEditingController();
  final majorController = TextEditingController();
  final yearController = TextEditingController();
  final studentNumberController = TextEditingController();
  final portfolioController = TextEditingController();
  final avatarUrl = ''.obs;
  final interests = <String>[].obs;

  static const Map<String, String> branches = {
    'gaza': 'فرع غزة (الرئيسي)',
    'khanyounis': 'فرع خانيونس',
    'deir_albalah': 'فرع دير البلح',
  };

  String text(String key) => (student[key] ?? '').toString();

  String get major => text('specialization').isNotEmpty
      ? text('specialization')
      : text('major');

  static List<String> interestsOf(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    if (value is String) {
      return value
          .split(RegExp('[،,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> get settings =>
      Map<String, dynamic>.from((student['settings'] ?? {}) as Map);

  bool setting(String key, {bool fallback = true}) => settings[key] ?? fallback;

  String get email => text('email').isNotEmpty
      ? text('email')
      : (FirebaseAuth.instance.currentUser?.email ?? '');

  int get completion {
    final fields = [
      'name',
      'phone',
      'city',
      'university',
      'studyYear',
      'studentNumber',
      'portfolioUrl',
      'avatarUrl',
    ];
    final filled =
        fields.where((key) => text(key).isNotEmpty).length +
        (major.isNotEmpty ? 1 : 0) +
        (interests.isNotEmpty ? 1 : 0);
    return (filled / (fields.length + 2) * 100).round();
  }

  String get lastUpdateText {
    final value = student['updatedAt'];
    if (value is! Timestamp) return '';
    final days = DateTime.now().difference(value.toDate()).inDays;
    if (days == 0) return 'آخر تحديث للملف الشخصي: اليوم';
    if (days == 1) return 'آخر تحديث للملف الشخصي: أمس';
    return 'آخر تحديث للملف الشخصي: منذ $days أيام';
  }

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(
      _db
          .collection('Users')
          .doc(currentStudentId)
          .snapshots()
          .listen(
            (doc) {
              final firstLoad = student.isEmpty;
              student.value = doc.data() ?? {};
              if (firstLoad) fillForm();
              isLoading.value = false;
            },
            onError: (Object error) {
              debugPrint('StudentAccountController: $error');
              errorMessage.value = 'حدث خطأ أثناء تحميل الحساب';
              isLoading.value = false;
            },
          ),
    );

    _subscriptions.add(
      _db
          .collection('orders')
          .where('studentId', isEqualTo: currentStudentId)
          .snapshots()
          .listen((result) {
            completedOrders.value = result.docs
                .where((doc) => doc.data()['orderStatus'] == 'completed')
                .length;
          }, onError: (Object e) => debugPrint('StudentAccountController: $e')),
    );

    _subscriptions.add(
      _db
          .collection('favorites')
          .where('studentId', isEqualTo: currentStudentId)
          .snapshots()
          .listen(
            (result) => favoritesCount.value = result.docs.length,
            onError: (Object e) => debugPrint('StudentAccountController: $e'),
          ),
    );
  }

  void fillForm() {
    nameController.text = text('name');
    phoneController.text = text('phone');
    cityController.text = text('city');
    universityController.text = text('university');
    majorController.text = major;
    yearController.text = text('studyYear');
    studentNumberController.text = text('studentNumber');
    portfolioController.text = text('portfolioUrl');
    avatarUrl.value = text('avatarUrl');
    interests.value = interestsOf(student['interests']);
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    for (final field in [
      nameController,
      phoneController,
      cityController,
      universityController,
      majorController,
      yearController,
      studentNumberController,
      portfolioController,
    ]) {
      field.dispose();
    }
    super.onClose();
  }

  void addInterest(String value) {
    final interest = value.trim();
    if (interest.isNotEmpty && !interests.contains(interest))
      interests.add(interest);
  }

  void removeInterest(String value) => interests.remove(value);

  void changeAvatar(String url) {
    if (url.trim().startsWith('http')) {
      avatarUrl.value = url.trim();
    } else {
      Get.snackbar('رابط غير صحيح', 'أدخل رابط صورة يبدأ بـ http');
    }
  }

  Future<bool> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('بيانات ناقصة', 'الاسم الكامل مطلوب');
      return false;
    }

    final code = text('countryCode');
    final phone = phoneController.text.trim();
    if (code.isNotEmpty &&
        !RegExp('^${RegExp.escape(code)}[0-9]{9}\$').hasMatch(phone)) {
      Get.snackbar(
        'رقم الجوال غير صحيح',
        'اكتب الرقم بالصيغة $code متبوعًا بـ 9 أرقام',
      );
      return false;
    }

    isSaving.value = true;
    try {
      await _db.collection('Users').doc(currentStudentId).set({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'city': cityController.text.trim(),
        'university': universityController.text.trim(),
        'specialization': majorController.text.trim(),
        'major': majorController.text.trim(),
        'studyYear': yearController.text.trim(),
        'studentNumber': studentNumberController.text.trim(),
        'portfolioUrl': portfolioController.text.trim(),
        'avatarUrl': avatarUrl.value,
        'interests': interests.join('، '),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('StudentAccountController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التعديلات، حاول مرة أخرى');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    try {
      await _db.collection('Users').doc(currentStudentId).set({
        'settings': {key: value},
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('StudentAccountController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ الإعداد');
    }
  }

  Future<void> resetPassword() async {
    if (email.isEmpty) {
      Get.snackbar('غير متاح', 'لا يوجد بريد إلكتروني مرتبط بالحساب');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar('تم الإرسال', 'أرسلنا رابط تغيير كلمة المرور إلى $email');
    } catch (e) {
      debugPrint('StudentAccountController: $e');
      Get.snackbar('خطأ', 'لم نتمكن من إرسال رابط تغيير كلمة المرور');
    }
  }

  Future<void> requestAccountDeletion() async {
    try {
      await _db.collection('Users').doc(currentStudentId).set({
        'deletionRequested': true,
        'deletionRequestedAt': Timestamp.now(),
      }, SetOptions(merge: true));
      Get.snackbar(
        'تم استلام الطلب',
        'سيتم مراجعة طلب حذف الحساب خلال 48 ساعة',
      );
    } catch (e) {
      debugPrint('StudentAccountController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال الطلب');
    }
  }

  Future<void> logout() async {
    try {
      await Get.find<AuthRepository>().signOut();
      Get.offAll<void>(() => const AuthGate());
    } catch (e) {
      debugPrint('StudentAccountController: $e');
      Get.snackbar('خطأ', 'لم يتم تسجيل الخروج، حاول مرة أخرى');
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
