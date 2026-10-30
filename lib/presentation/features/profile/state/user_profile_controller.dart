import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final userName = 'أحمد محمد العشي'.obs;
  final userEmail = 'ahmed.ashi@alazhar.edu.ps'.obs;
  final university = 'جامعة الأزهر - غزة'.obs;
  final faculty = 'كلية الهندسة وتكنولوجيا المعلومات • هندسة البرمجيات'.obs;
  final academicLevel = 'سنة رابعة (فصل تخرج)'.obs;
  final gpaText = 'معدل امتياز 91.4%'.obs;
  final avatarUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80'.obs;
  final completedOrdersCount = 14.obs;
  final pointsCount = 340.obs;
  final favoritesCount = 12.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;

      // 1. Load from Firebase Auth current user
      final user = _auth.currentUser;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          userName.value = user.displayName!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          userEmail.value = user.email!;
        }
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          avatarUrl.value = user.photoURL!;
        }
      }

      // 2. Load from SharedPreferences (local edits)
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_name');
      if (savedName != null && savedName.isNotEmpty) {
        userName.value = savedName;
      }

      // 3. Load from Firestore
      final uid = user?.uid;
      if (uid != null) {
        final doc = await _db.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          userName.value = data['fullName'] ?? data['name'] ?? userName.value;
          university.value = data['university'] ?? university.value;
          faculty.value = data['faculty'] ?? faculty.value;
          if (data['email'] != null) userEmail.value = data['email'];
        }
      }
    } catch (e) {
      debugPrint('UserProfileController load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile')?.then((_) {
      loadUserProfile(); // Refresh when returning from edit profile
    });
  }

  void logout() {
    Get.defaultDialog(
      title: 'تسجيل الخروج',
      middleText: 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
      textConfirm: 'نعم، خروج',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEF4444),
      onConfirm: () async {
        await _auth.signOut();
        Get.back();
        Get.snackbar(
          'تم تسجيل الخروج',
          'إلى اللقاء، نتمنى لك التوفيق دائماً',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
