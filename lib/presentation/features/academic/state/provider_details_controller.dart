import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/course_details_screen.dart';
import '../../providers/state/provider_helpers.dart';

String convertDriveUrlToDirectLink(String url) {
  if (url.contains('drive.google.com') && url.contains('/d/')) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://lh3.googleusercontent.com/d/$fileId';
    }
  }
  return url;
}

class ProviderDetailsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String providerId;

  ProviderDetailsController({String? providerId})
      : providerId = providerId ?? currentProviderId;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final provider = <String, dynamic>{}.obs;
  final courses = <Map<String, dynamic>>[].obs;
  final reviews = <Map<String, dynamic>>[].obs;

  final selectedCategory = 'الكل'.obs;
  final isBookmarked = false.obs;

  String get coverImageUrl {
    final rawUrl = (provider['coverImageUrl'] ?? provider['imageUrl'])?.toString();
    if (rawUrl != null && rawUrl.isNotEmpty) {
      return convertDriveUrlToDirectLink(rawUrl);
    }
    return 'https://lh3.googleusercontent.com/d/1bLABQ-fHEWX_x1MDPhe8XQGUMyC1DrRb';
  }

  List<String> get categories {
    final list = <String>['الكل'];
    for (final c in courses) {
      final cat = (c['category_subtag'] ?? c['categorySubtag'] ?? c['category'] ?? c['domain'])?.toString().trim();
      if (cat != null && cat.isNotEmpty && !list.contains(cat)) {
        list.add(cat);
      }
    }
    return list;
  }

  List<Map<String, dynamic>> get filteredCourses {
    if (selectedCategory.value == 'الكل' || selectedCategory.value.trim().isEmpty) {
      return courses;
    }
    final selected = selectedCategory.value.trim().toLowerCase();
    return courses.where((c) {
      final cat = (c['category_subtag'] ?? c['categorySubtag'] ?? c['category'] ?? c['domain'] ?? '').toString().toLowerCase();
      final title = (c['title'] ?? c['name'] ?? '').toString().toLowerCase();
      final desc = (c['description'] ?? c['details'] ?? '').toString().toLowerCase();

      return cat.contains(selected) || title.contains(selected) || desc.contains(selected);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadProviderData();
  }

  Future<void> loadProviderData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Fetch provider document
      final doc = await _db.collection('serviceProviders').doc(providerId).get();
      if (doc.exists && doc.data() != null) {
        provider.value = doc.data()!;
      } else {
        provider.value = _fallbackProviderData();
      }

      // 2. Fetch ALL courses from Firebase without any ID or providerId filter
      final List<Map<String, dynamic>> allFirebaseCourses = [];

      try {
        final snap1 = await _db.collection('Courses').get();
        for (final d in snap1.docs) {
          allFirebaseCourses.add({...d.data(), 'id': d.id});
        }
      } catch (e) {
        debugPrint('Error loading Courses collection: $e');
      }

      try {
        final snap2 = await _db.collection('courses').get();
        for (final d in snap2.docs) {
          if (!allFirebaseCourses.any((item) => item['id'] == d.id)) {
            allFirebaseCourses.add({...d.data(), 'id': d.id});
          }
        }
      } catch (e) {
        debugPrint('Error loading courses collection: $e');
      }

      courses.value = allFirebaseCourses;

      // 3. Fetch reviews for this provider
      final reviewsSnapshot = await _db
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        reviews.value = reviewsSnapshot.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList();
      } else {
        reviews.value = _fallbackReviewsData();
      }
    } catch (e) {
      debugPrint('ProviderDetailsController error: $e');
      if (provider.value.isEmpty) provider.value = _fallbackProviderData();
      if (reviews.value.isEmpty) reviews.value = _fallbackReviewsData();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    Get.snackbar(
      isBookmarked.value ? 'تم الحفظ' : 'تمت الإزالة',
      isBookmarked.value
          ? 'تم إتمام إضافة المزود إلى قائمة المحفوظات'
          : 'تمت إزالة المزود من المحفوظات',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openServiceDetails(Map<String, dynamic> course) {
    Get.to(() => CourseDetailsScreen(courseId: course['id']?.toString()));
  }

  Map<String, dynamic> _fallbackProviderData() {
    return {
      'name': 'أكاديمية الإبداع التكنولوجي',
      'description':
          'مركز ريادي معتمد لتمكين الكفاءات الرقمية وهندسة البرمجيات والذكاء الاصطناعي مع توفير بيئة تعليمية متطورة وطاقة مستمرة 24/7.',
      'verificationStatus': 'verified',
      'isAcceptingOrders': true,
      'admissionStatusText': 'القبول والتسجيل مفتوح',
      'city': 'غزة',
      'addressDetails': 'الرمال / بالقرب من مفترق الاتصالات',
      'averageRating': 4.9,
      'reviewsCount': 154,
      'providerType': 'مزود تعليمي وتدريبي مرخص',
      'whatsappNumber': '+972599000000',
      'phoneNumber': '+97282800000',
      'coverImageUrl': 'https://lh3.googleusercontent.com/d/1bLABQ-fHEWX_x1MDPhe8XQGUMyC1DrRb',
      'instructors': [
        {
          'name': 'م. أحمد المشهراوي',
          'title': 'كبير مهندسي برمجيات ومحاضر معتمد Full-Stack',
          'verified': true,
        },
        {
          'name': 'أ. سارة البطش',
          'title': 'أخصائية أولى في تصميم تجربة المستخدم والمنتجات الرقمية',
          'verified': true,
          'initials': 'س.ب',
        }
      ]
    };
  }

  List<Map<String, dynamic>> _fallbackCoursesData() {
    return [
      {
        'id': 'c1',
        'title': 'دبلوم تطوير الويب Full-Stack',
        'category': 'برمجة وويب',
        'description': 'React, Node.js, Next.js وبناء المشاريع الإنتاجية',
        'duration': '40 ساعة تدريبية',
        'price': 280,
        'oldPrice': 350,
        'badge': 'مسار متكامل',
        'discount': 'خصم 20%',
      },
      {
        'id': 'c2',
        'title': 'مسار تصميم واجهات المستخدم UI/UX',
        'category': 'تصميم UI/UX',
        'description': 'Figma، أبحاث المستخدم وتصميم النماذج التفاعلية المتقدمة',
        'duration': '30 ساعة تدريبية',
        'price': 220,
        'oldPrice': null,
        'badge': 'تصميم رقمي',
        'discount': null,
      },
      {
        'id': 'c3',
        'title': 'دورة الذكاء الاصطناعي وبايثون',
        'category': 'ذكاء اصطناعي',
        'description': 'Machine Learning, نماذج اللغات وتطبيقات الأتمتة الحديثة',
        'duration': '25 ساعة تدريبية',
        'price': 190,
        'oldPrice': 240,
        'badge': 'علم البيانات',
        'discount': 'خصم 20%',
      },
      {
        'id': 'c4',
        'title': 'معسكر إدارة المشاريع وهندسة البرمجيات',
        'category': 'إدارة تقنية',
        'description': 'Agile & Scrum, Git, ومنهجيات تسليم البرمجيات للمؤسسات',
        'duration': '35 ساعة تدريبية',
        'price': 240,
        'oldPrice': null,
        'badge': 'إدارة تقنية',
        'discount': null,
      },
    ];
  }

  List<Map<String, dynamic>> _fallbackReviewsData() {
    return [
      {
        'name': 'عبد الله مهدي',
        'tag': 'طالب دبلوم الويب - تقييم موثق',
        'rating': 5.0,
        'comment':
            'التجهيزات والكهرباء والإنترنت مستقرة وممتازة، والمدربون يقدمون متابعة عملية حقيقية في كل جلسة.',
        'initials': 'م.ع',
      },
      {
        'name': 'سارة كمال',
        'tag': 'خريجة مسار UI/UX - تقييم موثق',
        'rating': 5.0,
        'comment':
            'استفدت جداً من خصم بطاقتي خطوتي في تخفيض الرسوم والتطبيق العملي للمشاريع الواقعية.',
        'initials': 'س.ك',
      },
    ];
  }
}
