import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TutorCategoryFilter {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const TutorCategoryFilter({
    required this.title,
    required this.icon,
    this.iconColor,
  });
}

class PrivateTutorsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final tutors = <Map<String, dynamic>>[].obs;
  final selectedCategory = 'جميع المدرسين (48)'.obs;
  final searchQuery = ''.obs;

  List<TutorCategoryFilter> get categoryFilters => const [
        TutorCategoryFilter(title: 'جميع المدرسين (48)', icon: Icons.star_rounded),
        TutorCategoryFilter(title: 'الهندسة و IT', icon: Icons.memory_rounded),
        TutorCategoryFilter(title: 'العلوم الطبية', icon: Icons.local_hospital_outlined, iconColor: Color(0xFFEF4444)),
        TutorCategoryFilter(title: 'العلوم الإدارية والمالية', icon: Icons.business_center_outlined),
        TutorCategoryFilter(title: 'اللغات والترجمة', icon: Icons.translate_rounded),
      ];

  void selectCategory(String catTitle) {
    selectedCategory.value = catTitle;
  }

  List<Map<String, dynamic>> get filteredTutors {
    Iterable<Map<String, dynamic>> list = tutors;

    if (!selectedCategory.value.contains('جميع')) {
      list = list.where((tutor) {
        final cat = tutor['category'] ?? '';
        final subjects = (tutor['subjects'] as List?)?.map((e) => e.toString()).toList() ?? [];
        return cat.toString().contains(selectedCategory.value) ||
            subjects.any((s) => s.contains(selectedCategory.value));
      });
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((tutor) {
        final name = (tutor['name'] ?? '').toString().toLowerCase();
        final title = (tutor['title'] ?? '').toString().toLowerCase();
        final subjects = (tutor['subjects'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        return name.contains(q) || title.contains(q) || subjects.any((s) => s.contains(q));
      });
    }

    return list.toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadTutors();
  }

  Future<void> loadTutors() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db.collection('tutors').get();
      if (snapshot.docs.isNotEmpty) {
        tutors.value = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      } else {
        tutors.value = _fallbackTutorsData();
      }
    } catch (e) {
      debugPrint('PrivateTutorsController error: $e');
      tutors.value = _fallbackTutorsData();
    } finally {
      isLoading.value = false;
    }
  }

  void openTutorProfile(Map<String, dynamic> tutor) {
    Get.toNamed('/tutor-profile', parameters: {'tutorId': tutor['id']?.toString() ?? 't1'});
  }

  List<Map<String, dynamic>> _fallbackTutorsData() {
    return [
      {
        'id': 't1',
        'name': 'د. إبراهيم النجار',
        'title': 'محاضر وباحث أكاديمي - تخصص الرياضيات التطبيقية وهندسة البرمجيات',
        'category': 'الهندسة و IT',
        'rating': 4.9,
        'reviewsCount': 142,
        'experienceYears': 8,
        'completedSessions': 380,
        'hourlyRate': 40,
        'isAvailableToday': true,
        'isVerified': true,
        'university': 'الجامعة الإسلامية & الأزهر',
        'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        'subjects': ['تفاضل وتكامل 1 & 2', 'جبر خطي', 'رياضيات منفصلة'],
        'attendanceMode': 'وجاهي وعن بعد',
      },
      {
        'id': 't2',
        'name': 'م. خليل إبراهيم',
        'title': 'مهندس ذكاء اصطناعي وباحث في التعلم الآلي وعلم البيانات',
        'category': 'الهندسة و IT',
        'rating': 4.9,
        'reviewsCount': 98,
        'experienceYears': 7,
        'completedSessions': 290,
        'hourlyRate': 50,
        'isAvailableToday': true,
        'isVerified': true,
        'university': 'جامعة الأمة & الجامعة الإسلامية',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
        'subjects': ['برمجة بايثون', 'تعلم آلي', 'معالجة بيانات'],
        'attendanceMode': 'عن بعد فقط',
      },
      {
        'id': 't3',
        'name': 'أ. سارة البطش',
        'title': 'أخصائية تصميم تجربة المستخدم واجهات UI/UX والمنتجات الرقمية',
        'category': 'الهندسة و IT',
        'rating': 4.8,
        'reviewsCount': 115,
        'experienceYears': 6,
        'completedSessions': 240,
        'hourlyRate': 35,
        'isAvailableToday': false,
        'isVerified': true,
        'university': 'جامعة الأقصى & كلية فلسطين',
        'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        'subjects': ['تصميم Figma متقدم', 'User Research', 'Design Systems'],
        'attendanceMode': 'وجاهي بالمركز',
      },
    ];
  }
}
