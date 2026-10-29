import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();

  // Text Controllers for permitted editable fields
  final nameController = TextEditingController();
  final emailController = TextEditingController(); // University email (locked/read-only)
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  // Academic details (some read-only/verified)
  final universityController = TextEditingController();
  final facultyController = TextEditingController();
  final academicLevelController = TextEditingController();
  final studentIdController = TextEditingController(); // Official student ID (locked)

  // Professional links
  final githubController = TextEditingController();

  // Observable tags
  final interests = <Map<String, dynamic>>[].obs;

  // State
  final isLoading = true.obs;
  final isSaving = false.obs;
  final completionPercentage = 92.obs;
  final lastUpdatedText = 'منذ يومين'.obs;

  // New Interest Controller
  final newInterestController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    universityController.dispose();
    facultyController.dispose();
    academicLevelController.dispose();
    studentIdController.dispose();
    githubController.dispose();
    newInterestController.dispose();
    super.onClose();
  }

  Future<void> loadProfileData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();

      // Check SharedPreferences first for offline/session persistence
      final savedName = prefs.getString('user_name');
      final savedPhone = prefs.getString('user_phone');
      final savedLocation = prefs.getString('user_location');
      final savedGithub = prefs.getString('user_github');
      final savedInterests = prefs.getStringList('user_interests');

      if (savedName != null) {
        nameController.text = savedName;
        phoneController.text = savedPhone ?? '+970 59 123 4567';
        locationController.text = savedLocation ?? 'غزة - الرمال / حي النصر';
        githubController.text = savedGithub ?? 'github.com/ahmed-ashi';

        // Academic defaults
        emailController.text = 'ahmed.ashi@alazhar.edu.ps';
        universityController.text = 'جامعة الأزهر - غزة';
        facultyController.text = 'كلية الهندسة وتكنولوجيا المعلومات - هندسة البرمجيات';
        academicLevelController.text = 'سنة رابعة - فصل تخرج 2025';
        studentIdController.text = '20201482';

        if (savedInterests != null && savedInterests.isNotEmpty) {
          interests.value = savedInterests
              .map((tag) => {'title': tag, 'color': _getColorForTag(tag)})
              .toList();
        } else {
          _loadDefaultInterests();
        }
      } else {
        // Try Firestore or load initial mock data
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          final doc = await _db.collection('users').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            nameController.text = data['fullName'] ?? 'أحمد محمد العشي';
            emailController.text = data['email'] ?? 'ahmed.ashi@alazhar.edu.ps';
            phoneController.text = data['phone'] ?? '+970 59 123 4567';
            locationController.text = data['location'] ?? 'غزة - الرمال / حي النصر';
            universityController.text = data['university'] ?? 'جامعة الأزهر - غزة';
            facultyController.text = data['faculty'] ?? 'كلية الهندسة وتكنولوجيا المعلومات - هندسة البرمجيات';
            academicLevelController.text = data['academicLevel'] ?? 'سنة رابعة - فصل تخرج 2025';
            studentIdController.text = data['studentId'] ?? '20201482';
            githubController.text = data['github'] ?? 'github.com/ahmed-ashi';
            _loadDefaultInterests();
          } else {
            _populateDefaults();
          }
        } else {
          _populateDefaults();
        }
      }
    } catch (e) {
      debugPrint('EditProfileController load error: $e');
      _populateDefaults();
    } finally {
      isLoading.value = false;
    }
  }

  void _populateDefaults() {
    nameController.text = 'أحمد محمد العشي';
    emailController.text = 'ahmed.ashi@alazhar.edu.ps';
    phoneController.text = '+970 59 123 4567';
    locationController.text = 'غزة - الرمال / حي النصر';
    universityController.text = 'جامعة الأزهر - غزة';
    facultyController.text = 'كلية الهندسة وتكنولوجيا المعلومات - هندسة البرمجيات';
    academicLevelController.text = 'سنة رابعة - فصل تخرج 2025';
    studentIdController.text = '20201482';
    githubController.text = 'github.com/ahmed-ashi';
    _loadDefaultInterests();
  }

  void _loadDefaultInterests() {
    interests.value = [
      {'title': 'تطوير ويب Full-Stack', 'type': 'purple'},
      {'title': 'تصميم UI/UX', 'type': 'gold'},
      {'title': 'تعلم الآلة', 'type': 'green'},
      {'title': 'منح ماجستير', 'type': 'blue'},
    ];
  }

  String _getColorForTag(String tag) {
    if (tag.contains('تصميم')) return 'gold';
    if (tag.contains('آلة') || tag.contains('بيانات')) return 'green';
    if (tag.contains('منح') || tag.contains('ماجستير')) return 'blue';
    return 'purple';
  }

  void removeInterest(int index) {
    if (index >= 0 && index < interests.length) {
      interests.removeAt(index);
    }
  }

  void addInterest(String title) {
    if (title.trim().isNotEmpty) {
      interests.add({
        'title': title.trim(),
        'type': 'purple',
      });
      newInterestController.clear();
      Get.back(); // close bottom sheet/dialog
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'خطأ في التحقق',
        'يرجى التأكد من ملء جميع الحقول المطلوبة بشكل صحيح',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;

      // 1. Save to SharedPreferences for session persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', nameController.text.trim());
      await prefs.setString('user_phone', phoneController.text.trim());
      await prefs.setString('user_location', locationController.text.trim());
      await prefs.setString('user_github', githubController.text.trim());
      await prefs.setStringList(
        'user_interests',
        interests.map((e) => e['title'].toString()).toList(),
      );

      // 2. Persist to Firestore if user authenticated or offline collection
      final uid = _auth.currentUser?.uid;
      final payload = {
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'location': locationController.text.trim(),
        'github': githubController.text.trim(),
        'interests': interests.map((e) => e['title'].toString()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (uid != null) {
        await _db.collection('users').doc(uid).set(payload, SetOptions(merge: true));
      }

      lastUpdatedText.value = 'الآن';

      Get.snackbar(
        'تم الحفظ بنجاح',
        'تم تحديث بياناتك الشخصية والأكاديمية وحفظها بنجاح',
        backgroundColor: const Color(0xFF22C55E),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      Get.snackbar(
        'تنبيه',
        'تم حفظ التعديلات محلياً بنجاح',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
