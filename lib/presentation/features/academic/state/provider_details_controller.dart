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

  List<String> get categories => [
        'الكل',
        'برمجة وويب',
        'ذكاء اصطناعي',
        'تصميم UI/UX',
        'إدارة تقنية',
      ];

  List<Map<String, dynamic>> get filteredCourses {
    if (selectedCategory.value == 'الكل') {
      return courses;
    }
    return courses.where((c) {
      final category = c['category'] ?? c['domain'] ?? '';
      return category.toString().contains(selectedCategory.value);
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

      // 2. Fetch courses for this provider
      final coursesSnapshot = await _db
          .collection('courses')
          .where('providerId', isEqualTo: providerId)
          .get();

      if (coursesSnapshot.docs.isNotEmpty) {
        courses.value = coursesSnapshot.docs
            .map((d) => {...d.data(), 'id': d.id})
            .toList();
      } else {
        courses.value = _fallbackCoursesData();
      }

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
      provider.value = _fallbackProviderData();
      courses.value = _fallbackCoursesData();
      reviews.value = _fallbackReviewsData();
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
