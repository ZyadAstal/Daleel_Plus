import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/course_model.dart';

class CourseDetailsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String courseId;

  CourseDetailsController({String? courseId})
      : courseId = courseId ?? 'c1';

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final courseModel = Rxn<CourseModel>();
  final course = <String, dynamic>{}.obs;
  final provider = <String, dynamic>{}.obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final isBookmarked = false.obs;
  final expandedModules = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourseDetails();
  }

  Future<void> loadCourseDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doc = await _db.collection('courses').doc(courseId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        course.value = data;
        courseModel.value = CourseModel.fromFirestore(doc);

        final providerId = data['provider_id'] ?? data['providerId'];
        if (providerId != null) {
          final pDoc = await _db.collection('serviceProviders').doc(providerId.toString()).get();
          if (pDoc.exists && pDoc.data() != null) {
            provider.value = pDoc.data()!;
          } else {
            provider.value = _fallbackProviderData();
          }
        } else {
          provider.value = _fallbackProviderData();
        }
      } else {
        final fallback = _fallbackCourseData(courseId);
        course.value = fallback;
        courseModel.value = CourseModel.fromMap(fallback, docId: courseId);
        provider.value = _fallbackProviderData();
      }

      reviews.value = _fallbackReviewsData();
    } catch (e) {
      debugPrint('CourseDetailsController error: $e');
      final fallback = _fallbackCourseData(courseId);
      course.value = fallback;
      courseModel.value = CourseModel.fromMap(fallback, docId: courseId);
      provider.value = _fallbackProviderData();
      reviews.value = _fallbackReviewsData();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    Get.snackbar(
      isBookmarked.value ? 'تم الحفظ' : 'تمت الإزالة',
      isBookmarked.value ? 'تم حفظ الدورة في المفضلة' : 'تمت إزالة الدورة من المفضلة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleModule(int index) {
    expandedModules[index] = !(expandedModules[index] ?? false);
  }

  void bookCourse() {
    final title = courseModel.value?.title ?? course['fullTitle'] ?? course['title'];
    Get.snackbar(
      'تم تقديم طلب الحجز',
      'تم حجز مقعدك بنجاح في $title',
      backgroundColor: const Color(0xFF22C55E),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Map<String, dynamic> _fallbackCourseData(String id) {
    if (id == 'c2') {
      return {
        'id': 'c2',
        'provider_id': 'CClgjCzo2ZUZj8Y1QDiKRICSuxM2',
        'title': 'مسار تصميم واجهات المستخدم UI/UX',
        'fullTitle': 'مسار تصميم واجهات المستخدم والملاحة الرقمية UI/UX Design',
        'category_subtag': 'تصميم رقمي • مسار مهني متقدم',
        'discountTag': 'خصم خاص لطلاب دليل+',
        'rating': 4.8,
        'studentsCount': 96,
        'cover_image_url': 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?auto=format&fit=crop&w=800&q=80',
        'badges': ['تصميم رقمي', 'شهادة معتمدة'],
        'features': [
          '30 ساعة تدريبية معتمدة ومكثفة',
          'يبدأ المسار في: 20 أكتوبر القادم',
          'تطبيق عملي على مشروع بورتفوليو حقيقي',
        ],
        'original_price': 300.0,
        'discounted_price': 220.0,
        'price': 220.0,
        'oldPrice': 300.0,
        'savedAmount': 80.0,
        'remainingSeats': 3,
        'attendance_mode': 'in_person',
        'total_hours': 30,
        'target_level': 'intermediate',
        'modules': [
          {
            'number': 1,
            'title': 'أبحاث المستخدم وتحليل المنافسين',
            'subtitle': 'User Personas, Empathy Maps & User Journey',
            'content': 'تعلم كيفية دراسة سلوك المستخدم وبناء الخرائط التفاعلية وشخصيات المستخدمين.',
          },
          {
            'number': 2,
            'title': 'تصميم Wireframes والواجهات التفاعلية',
            'subtitle': 'Figma, Prototyping & Design Systems',
            'content': 'تطبيق عملي لبناء أنظمة التصميم وإنشاء نماذج تفاعلية متقدمة باستخدام Figma.',
          },
        ],
        'instructor': {
          'name': 'أ. سارة البطش',
          'badge': 'أخصائية معتمدة',
          'role': 'أخصائية أولى في تصميم تجربة المستخدم والمنتجات الرقمية',
          'rating': 5.0,
          'experience': 'أكثر من 6+ سنوات خبرة عملية',
          'bio': 'قادت تصميم العديد من التطبيقات الرقمية في قطاع التقنية والخدمات المالية مع تركيز على واجهات المستخدم التفاعلية.',
        },
        'amenities': [
          {
            'icon': Icons.ac_unit,
            'title': 'قاعات مكيفة ومجهزة',
            'subtitle': 'شاشات تفاعلية ومحطات عمل فردية مريحة',
          },
          {
            'icon': Icons.card_membership,
            'title': 'شهادة معتمدة في تصميم UI/UX',
            'subtitle': 'شهادة تخرج موثقة تدعم السيرة الذاتية',
          },
        ],
      };
    } else if (id == 'c3') {
      return {
        'id': 'c3',
        'provider_id': 'CClgjCzo2ZUZj8Y1QDiKRICSuxM2',
        'title': 'دورة الذكاء الاصطناعي وبايثون',
        'fullTitle': 'دورة نماذج الذكاء الاصطناعي والتعلم الآلي وبايثون',
        'category_subtag': 'علم البيانات • ذكاء اصطناعي',
        'discountTag': 'خصم 20% لطلاب دليل+',
        'rating': 4.9,
        'studentsCount': 112,
        'cover_image_url': 'https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?auto=format&fit=crop&w=800&q=80',
        'badges': ['علم البيانات', 'تطبيقات الذكاء الاصطناعي'],
        'features': [
          '25 ساعة تدريبية معتمدة',
          'تبدأ الدورة في: 25 أكتوبر القادم',
          'تدريب على نماذج التعلم الآلي وبناء البوتات الذكية',
        ],
        'original_price': 240.0,
        'discounted_price': 190.0,
        'price': 190.0,
        'oldPrice': 240.0,
        'savedAmount': 50.0,
        'remainingSeats': 5,
        'attendance_mode': 'online',
        'total_hours': 25,
        'target_level': 'intermediate',
        'modules': [
          {
            'number': 1,
            'title': 'أساسيات بايثون وتحليل البيانات',
            'subtitle': 'NumPy, Pandas, Matplotlib & Seaborn',
            'content': 'تعلم معالجة البيانات الضخمة وتمثيلها بيانيا باستخدام مكتبات بايثون القياسية.',
          },
          {
            'number': 2,
            'title': 'نماذج التعلم الآلي المعزز',
            'subtitle': 'Scikit-Learn, Regression & Classification Models',
            'content': 'بناء وتدريب خوارزميات التنبؤ والتصنيف المتقدمة وتطبيقاتها الذكية.',
          },
        ],
        'instructor': {
          'name': 'م. خليل إبراهيم',
          'badge': 'باحث ذكاء اصطناعي',
          'role': 'AI & Data Science Specialist',
          'rating': 4.9,
          'experience': '7+ سنوات في نمذجة البيانات والتعلم الآلي',
          'bio': 'خبير في بناء وتطوير برمجيات الأتمتة المتقدمة ونماذج المعالجة اللغوية.',
        },
        'amenities': [
          {
            'icon': Icons.wifi,
            'title': 'جلسات أونلاين مسجلة بالكامل',
            'subtitle': 'إمكانية إعادة الوصول للمحاضرات في أي وقت عبر المنصة',
          },
        ],
      };
    } else if (id == 'c4') {
      return {
        'id': 'c4',
        'provider_id': 'CClgjCzo2ZUZj8Y1QDiKRICSuxM2',
        'title': 'معسكر إدارة المشاريع وهندسة البرمجيات',
        'fullTitle': 'معسكر إدارة المشاريع وهندسة البرمجيات والمنهجيات المتقدمة',
        'category_subtag': 'إدارة تقنية • منهجيات Agile & Scrum',
        'discountTag': 'حجز مبكر ساري',
        'rating': 4.7,
        'studentsCount': 85,
        'cover_image_url': 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?auto=format&fit=crop&w=800&q=80',
        'badges': ['إدارة تقنية', 'شهادة قيادة مشاريع'],
        'features': [
          '35 ساعة تدريبية مكثفة',
          'يبدأ المعسكر في: 1 نوفمبر القادم',
          'إدارة فرق التطوير وتسليم المشاريع للمؤسسات',
        ],
        'original_price': 300.0,
        'discounted_price': 240.0,
        'price': 240.0,
        'oldPrice': 300.0,
        'savedAmount': 60.0,
        'remainingSeats': 2,
        'attendance_mode': 'hybrid',
        'total_hours': 35,
        'target_level': 'advanced',
        'modules': [
          {
            'number': 1,
            'title': 'منهجيات العمل Agile & Scrum',
            'subtitle': 'Sprints, Backlog Grooming & Product Ownership',
            'content': 'التدريب على قيادة الفرق البرمجية وتطبيق المنهجيات السريعة في إدارة المشاريع.',
          },
        ],
        'instructor': {
          'name': 'م. طارق حماد',
          'badge': 'مستشار إدارة مشاريع',
          'role': 'Agile Coach & Technical Project Manager',
          'rating': 4.8,
          'experience': '10+ سنوات خبرة قيادية',
          'bio': 'أدار تسليم عشرات المشاريع البرمجية الضخمة للعديد من المؤسسات والشركات الناشئة.',
        },
        'amenities': [
          {
            'icon': Icons.card_membership,
            'title': 'شهادة معتمدة في إدارة المشاريع البرمجية',
            'subtitle': 'قابلة للاعتماد الدولي',
          },
        ],
      };
    }

    // Default for c1 or any other doc ID
    return {
      'id': id,
      'provider_id': 'CClgjCzo2ZUZj8Y1QDiKRICSuxM2',
      'title': 'دبلوم تطوير تطبيقات الويب Full-Stack والذكاء الاصطناعي',
      'fullTitle': 'دبلوم تطوير الويب المتكامل Full-Stack Web Development',
      'category_subtag': 'دورات وتعليم • دبلوم مهني معتمد',
      'discountTag': 'خصم 20% لطلاب دليل+',
      'rating': 4.9,
      'studentsCount': 148,
      'cover_image_url': 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
      'badges': ['مسار وظيفي واعد', 'شهادة مهنية معتمدة'],
      'features': [
        '120 ساعة تدريبية معتمدة ومكثفة',
        'يبدأ الدبلوم في: 15 أكتوبر القادم',
        'وجاهي بالقاعة الذكية + تسجيلات سحابية مدى الحياة',
      ],
      'original_price': 350.0,
      'discounted_price': 260.0,
      'price': 260.0,
      'oldPrice': 350.0,
      'savedAmount': 90.0,
      'remainingSeats': 4,
      'attendance_mode': 'in_person',
      'total_hours': 120,
      'target_level': 'beginner',
      'modules': [
        {
          'number': 1,
          'title': 'أساسيات الويب الحديث ومفاهيم Frontend',
          'subtitle': 'HTML5, Modern CSS, Tailwind, React.js 18',
          'content': 'شرح مفصل لبناء الواجهات التفاعلية الحديثة واستخدام مكتبات التصميم المتقدمة.',
        },
        {
          'number': 2,
          'title': 'بناء الـ APIs وقواعد البيانات Backend',
          'subtitle': 'Node.js, Express, RESTful, PostgreSQL & Prisma',
          'content': 'تطوير الخوادم وإدارة قواعد البيانات الحديثة وبناء برمجيات آمنة وقابلة للتوسع.',
        },
        {
          'number': 3,
          'title': 'دمج نماذج الذكاء الاصطناعي LLMs',
          'subtitle': 'OpenAI APIs, Prompting, LangChain & Vector Embeddings',
          'content': 'تكامل تطبيقاتك مع نماذج Gemini و OpenAI لبناء أدوات ذكية مؤتمتة.',
        },
        {
          'number': 4,
          'title': 'مشروع التخرج ونشره على السحابة',
          'subtitle': 'Docker, CI/CD, Vercel, Supabase & Live Deployment',
          'content': 'تطبيق عملي لبناء مشروع حقيقي ونشره على الاستضافات السحابية العالمية.',
        },
      ],
      'instructor': {
        'name': 'م. محمد عبد الله',
        'badge': 'معتمد دولياً',
        'role': 'Senior Full-Stack Engineer & Mentor',
        'rating': 5.0,
        'experience': 'أكثر من 8+ سنوات خبرة دولية',
        'bio': 'قاد فرق هندسية في شركات تقنية رائدة بالشرق الأوسط، ودرب أكثر من 600 طالب تخرج منهم برمجون حالياً بشركات إقليمية وعالمية بنظام العمل عن بعد.',
      },
      'amenities': [
        {
          'icon': Icons.ac_unit,
          'title': 'قاعات مكيفة ومجهزة',
          'subtitle': 'شاشات تفاعلية ومحطات عمل فردية مريحة',
        },
        {
          'icon': Icons.wifi,
          'title': 'إنترنت فايبر سريع وطاقة شمسية مستمرة',
          'subtitle': 'ضمان استمرار المحاضرات والكهرباء والإنترنت 24/7 دون انقطاع',
        },
        {
          'icon': Icons.card_membership,
          'title': 'شهادة تدريب معتمدة رسمياً',
          'subtitle': 'قابلة للتصديق ومصدقة من وزارة العمل والتعليم العالي',
        },
      ],
    };
  }

  Map<String, dynamic> _fallbackProviderData() {
    return {
      'id': 'p1',
      'name': 'أكاديمية الإبداع التكنولوجي',
      'address': 'غزة - الرمال، شارع الوحدة',
      'isVerified': true,
    };
  }

  List<Map<String, dynamic>> _fallbackReviewsData() {
    return [
      {
        'name': 'عبدالله مهدي',
        'tag': 'خريج هندسة حاسوب - مسجل معتمد',
        'rating': 5.0,
        'comment': 'دورة نوعية جداً، التطبيق العملي يبدأ من المحاضرة الأولى. المهندس إبراهيم متعاون لأبعد الحدود والكهرباء والإنترنت مستقران جداً داخل المركز.',
        'initials': 'م.ع',
      },
      {
        'name': 'سارة كمال',
        'tag': 'طالبة وسائط متعددة - مسجلة معتمدة',
        'rating': 5.0,
        'comment': 'مشروع التخرج ساعدني في تجهيز Portfolio متكامل وتقدمت لفرصة تدريب عن بعد بعدها بأسبوعين. الخصم عبر بطاقة خطوتي كان حقيقياً وموفراً جداً!',
        'initials': 'س.ك',
      },
    ];
  }
}
