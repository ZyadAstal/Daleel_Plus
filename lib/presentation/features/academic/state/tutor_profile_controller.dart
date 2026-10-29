import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorProfileController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String tutorId;

  TutorProfileController({String? tutorId})
      : tutorId = tutorId ?? Get.parameters['tutorId'] ?? 't1';

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final tutor = <String, dynamic>{}.obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTutorProfile();
  }

  Future<void> loadTutorProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doc = await _db.collection('tutors').doc(tutorId).get();
      if (doc.exists && doc.data() != null) {
        tutor.value = doc.data()!;
      } else {
        tutor.value = _fallbackTutorData(tutorId);
      }

      reviews.value = _fallbackReviewsData(tutorId);
    } catch (e) {
      debugPrint('TutorProfileController error: $e');
      tutor.value = _fallbackTutorData(tutorId);
      reviews.value = _fallbackReviewsData(tutorId);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    Get.snackbar(
      isBookmarked.value ? 'تم الحفظ' : 'تمت الإزالة',
      isBookmarked.value ? 'تم حفظ الملف الأكاديمي للمدرس في المفضلة' : 'تمت إزالة المدرس من المفضلة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> makeDirectCall() async {
    final phone = tutor['phone'] ?? '+972599000000';
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('اتصال مباشر', 'الاتصال بالرقم: $phone');
      }
    } catch (e) {
      Get.snackbar('اتصال مباشر', 'الاتصال بالرقم: $phone');
    }
  }

  Future<void> openWhatsapp() async {
    final whatsapp = tutor['whatsapp'] ?? '+972599000000';
    final Uri uri = Uri.parse('https://wa.me/${whatsapp.replaceAll('+', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('واتساب فوري', 'فتح محادثة واتساب مع المدرس');
      }
    } catch (e) {
      Get.snackbar('واتساب فوري', 'فتح محادثة واتساب مع المدرس');
    }
  }

  void bookSession() {
    Get.snackbar(
      'حجز جلسة أكاديمية',
      'تم بدء حجز جلسة مع ${tutor['name'] ?? 'المدرس'} بنجاح',
      backgroundColor: const Color(0xFF22C55E),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Map<String, dynamic> _fallbackTutorData(String id) {
    if (id == 't2') {
      return {
        'id': 't2',
        'name': 'م. خليل إبراهيم',
        'title': 'مهندس ذكاء اصطناعي وباحث في التعلم الآلي وعلم البيانات',
        'rating': 4.9,
        'reviewsCount': 98,
        'reviewsSub': '98 تقييم موثق من طلاب الهندسة والحاسوب',
        'experienceYears': 7,
        'completedSessions': 290,
        'satisfactionRate': 98,
        'hourlyRate': 50,
        'phone': '+972599654321',
        'whatsapp': '+972599654321',
        'location': 'غزة - النصر، مجمع الإبداع التقني، ط 3.',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
        'bio': 'متخصص في تدريس لغة بايثون وتطبيقات التعلم الآلي وشبكات العصبون الاصطناعية. أركز على التطبيق العملي لبناء نماذج تنبؤية واستخراج البيانات الضخمة بمشاركة عملية في مشاريع تخرج حقيقية.',
        'philosophies': [
          'التطبيق العملي مع لغة بايثون',
          'بناء نماذج Machine Learning حية',
          'مشاريع تخرج متكاملة',
        ],
        'courses': [
          {
            'code': 'Python Programming & OOP',
            'name': 'أساسيات بايثون المتقدمة',
            'badge': 'موصى به',
            'icon': 'code',
          },
          {
            'code': 'Machine Learning & AI',
            'name': 'خوارزميات التعلم الآلي',
            'pill': 'كلية الهندسة وتكنولوجيا المعلومات',
            'icon': 'stats',
          },
        ],
        'teachingModes': [
          {
            'type': 'فردي',
            'title': 'جلسة فردية 1on1',
            'desc': 'توجيه في مشاريع التخرج والأبحاث',
            'price': '50 ₪ / ساعة',
          },
          {
            'type': 'عن بعد',
            'title': 'جلسات أونلاين تفاعلية',
            'desc': 'مشاركة شاشة وتطبيق فوري للكود',
            'price': '40 ₪ / ساعة',
          },
        ],
        'amenities': ['مختبر حاسوب مجهز', 'إنترنت فايبر عالي السرعة'],
      };
    } else if (id == 't3') {
      return {
        'id': 't3',
        'name': 'أ. سارة البطش',
        'title': 'أخصائية تصميم تجربة المستخدم واجهات UI/UX والمنتجات الرقمية',
        'rating': 4.8,
        'reviewsCount': 115,
        'reviewsSub': '115 تقييم موثق من طلاب الفنون والتصميم',
        'experienceYears': 6,
        'completedSessions': 240,
        'satisfactionRate': 97,
        'hourlyRate': 35,
        'phone': '+972599789123',
        'whatsapp': '+972599789123',
        'location': 'غزة - الرمال، عمارة العباس التجارية ط 4.',
        'avatarUrl': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
        'bio': 'أساعد الطالبات والطلاب على احتراف تصميم واجهات وتجربة المستخدم باستخدام Figma وبناء بورتفوليو احترافي ينافس في سوق العمل الحر والشركات التقنية العالمية.',
        'philosophies': [
          'احتراف أداة Figma من الصفر',
          'بناء ملف أعمال Portfolio تجاري',
          'تطبيق قواعد Design Thinking',
        ],
        'courses': [
          {
            'code': 'UI/UX Design Masterclass',
            'name': 'تصميم واجهات المستخدم UI/UX',
            'badge': 'شائع جداً',
            'icon': 'grid',
          },
        ],
        'teachingModes': [
          {
            'type': 'فردي',
            'title': 'جلسة فردية 1on1',
            'desc': 'تقييم ومراجعة بورتفوليو التصميم',
            'price': '35 ₪ / ساعة',
          },
        ],
        'amenities': ['استوديو تصميم', 'شاشات عرض تفاعلية'],
      };
    }

    // Default for t1 (Dr. Ibrahim Al-Najjar)
    return {
      'id': 't1',
      'name': 'د. إبراهيم النجار',
      'title': 'محاضر وباحث أكاديمي - تخصص الرياضيات التطبيقية وهندسة البرمجيات',
      'rating': 4.9,
      'reviewsCount': 142,
      'reviewsSub': '142 تقييم موثق من طلاب الأزهر والإسلامية',
      'experienceYears': 8,
      'completedSessions': 380,
      'satisfactionRate': 99,
      'hourlyRate': 40,
      'phone': '+972599123456',
      'whatsapp': '+972599123456',
      'location': 'غزة - حي الرمال، شارع الثلاثيني، مقابل البوابة الجنوبية للجامعة الإسلامية مباشرة (عمارة الأمل، ط 2).',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'bio': 'أركز على تبسيط المفاهيم الرياضية وربطها بالتطبيقات البرمجية العملية، مما يمنح الطالب فهماً عميقاً بدلاً من الحفظ المجرد. نعتمد خلال الحصص على تقنيات التفاعل المستمر، تفكيك المسائل الرياضية الشائكة خطوة بخطوة، والتركيز المكثف على حل اختبارات السنوات السابقة لجامعات الأزهر والإسلامية لضمان التفوق وتحصيل أعلى الدرجات (+A).',
      'philosophies': [
        'تبسيط وتفكيك المعادلات',
        'حل نماذج الامتحانات السابقة',
        'ملخصات وشيتات مراجعة مجانية',
      ],
      'courses': [
        {
          'code': 'Calculus I & II',
          'name': 'تفاضل وتكامل 1 & 2',
          'badge': 'الأكثر طلباً',
          'icon': 'math',
        },
        {
          'code': 'Data Structures & Algorithms',
          'name': 'هياكل بيانات وخوارزميات',
          'pill': 'كلية الهندسة وتكنولوجيا المعلومات',
          'icon': 'code',
        },
        {
          'code': 'Linear Algebra & Diff Equations',
          'name': 'الجبر الخطي والمعادلات التفاضلية',
          'pill': 'سنة ثانية هندسة',
          'icon': 'grid',
        },
        {
          'code': 'Engineering Probability & Stats',
          'name': 'إحصاء واحتمالات هندسية',
          'pill': 'مشترك عام',
          'icon': 'stats',
        },
      ],
      'teachingModes': [
        {
          'type': 'فردي',
          'title': 'جلسة فردية 1on1',
          'desc': 'تركيز كامل وحل مخصص لاحتياجاتك',
          'price': '40 ₪ / ساعة',
        },
        {
          'type': 'توفيري',
          'title': 'مجموعات طلابية',
          'desc': 'مجموعات صغيرة (3 - 5 طلاب كحد أقصى)',
          'price': '25 ₪ / للطالب',
        },
      ],
      'amenities': ['قاعات مكيفة', 'إنترنت فايبر', 'طاقة شمسية 24/7'],
    };
  }

  List<Map<String, dynamic>> _fallbackReviewsData(String id) {
    if (id == 't2') {
      return [
        {
          'name': 'أحمد صالحة',
          'tag': 'طالب هندسة حاسوب',
          'rating': 5.0,
          'timeAgo': 'منذ يومين',
          'comment': '"المهندس خليل شرحه ممتاز جداً في بايثون ومفهوم الذكاء الاصطناعي صار أوضح بكثير."',
          'initials': 'أ.ص',
        },
      ];
    } else if (id == 't3') {
      return [
        {
          'name': 'ريم عبد الله',
          'tag': 'طالبة وسائط متعددة',
          'rating': 5.0,
          'timeAgo': 'منذ 4 أيام',
          'comment': '"الأستاذة سارة ساعدتني بترتيب ملف الأعمال وصار أسلوبي في Figma احترافي جداً."',
          'initials': 'ر.ع',
        },
      ];
    }
    return [
      {
        'name': 'محمد حسان الدلو',
        'tag': 'طالب هندسة حاسوب - الأزهر',
        'rating': 5.0,
        'timeAgo': 'منذ 3 أيام',
        'comment': '"الدكتور إبراهيم متمكن جداً، ساعدني بتخطي عقدة التفاضل 2 بعد ما كنت خايف منها كتير. أسلوبه سلس جداً في الشرح والحل، وحلينا سوا كل الامتحانات السابقة وحصلت على علامة 94% بفضل الله."',
        'initials': 'م.ح',
      },
      {
        'name': 'سارة منير شعث',
        'tag': 'تكنولوجيا معلومات - الجامعة الإسلامية',
        'rating': 5.0,
        'timeAgo': 'منذ أسبوع',
        'comment': '"حجزت مع الدكتور كورس هياكل البيانات بمجموعة من 4 طالبات. القاعة مكيفة ومريحة والشرح عملي جداً مع كود حي وتطبيقات مباشرة. أنصح فيه كل طالب وطالبة بدهم يفهموا بعمق."',
        'initials': 'س.م',
      },
    ];
  }
}
