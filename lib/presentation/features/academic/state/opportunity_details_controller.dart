import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/opportunity_model.dart';

class OpportunityDetailsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String opportunityId;

  OpportunityDetailsController({String? opportunityId})
      : opportunityId = opportunityId ?? Get.parameters['opportunityId'] ?? 'opp1';

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final opportunityModel = Rxn<OpportunityModel>();
  final opportunity = <String, dynamic>{}.obs;
  final isBookmarked = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOpportunityDetails();
  }

  Future<void> loadOpportunityDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doc = await _db.collection('opportunities').doc(opportunityId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        opportunity.value = data;
        opportunityModel.value = OpportunityModel.fromFirestore(doc);
      } else {
        final fallback = _fallbackOpportunityData(opportunityId);
        opportunity.value = fallback;
        opportunityModel.value = OpportunityModel.fromMap(fallback, docId: opportunityId);
      }
    } catch (e) {
      debugPrint('OpportunityDetailsController error: $e');
      final fallback = _fallbackOpportunityData(opportunityId);
      opportunity.value = fallback;
      opportunityModel.value = OpportunityModel.fromMap(fallback, docId: opportunityId);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleBookmark() {
    isBookmarked.value = !isBookmarked.value;
    Get.snackbar(
      isBookmarked.value ? 'تم الحفظ' : 'تمت الإزالة',
      isBookmarked.value
          ? 'تم حفظ الفرصة التدريبية في المفضلة'
          : 'تمت إزالة الفرصة من المفضلة',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void applyForOpportunity() {
    final title = opportunityModel.value?.title ?? opportunity['title'] ?? 'الفرصة';
    final company = opportunity['company'] ?? 'الشركة';
    Get.snackbar(
      'تم إرسال طلب التقديم',
      'تم تقديم طلبك بنجاح في $title لدى $company',
      backgroundColor: const Color(0xFF006A48),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Map<String, dynamic> _fallbackOpportunityData(String id) {
    if (id == 'opp2') {
      return {
        'id': 'opp2',
        'title': 'تدريب مطور تطبيقات جوال Flutter Developer',
        'company': 'شركة أفق للتكنولوجيا والمعلومات',
        'companySub': 'Ofoq Tech Solutions',
        'location': 'غزة / الرمال - بالقرب من الجامعة الإسلامية',
        'statusText': 'نشطة ومتاحة',
        'isVerified': true,
        'allowance': '500 ₪ / شهر',
        'duration': '2 شهر تدريبية',
        'deadline': 'متبقي 6 أيام (25 أكتوبر)',
        'seats': '2 متدربين فقط',
        'tags': [
          '✨ تدريب منتهي بالتوظيف',
          '💻 مدفوع الأجر',
          '🏢 وجاهي بالشركة'
        ],
        'about':
            'يتيح هذا البرنامج التفاعلي للمشاركين فرصة بناء وتطوير تطبيقات جوال حقيقية باستخدام إطار العمل Flutter ولغة Dart. سينضم المتدرب إلى فريق تطوير البرمجيات بالشركة لبناء واجهات تفاعلية وربط الخدمات مع Firebase و RESTful APIs اتباعاً لأفضل الممارسات البرمجية Clean Architecture.',
        'projectHighlight': {
          'title': 'بناء تطبيق جوال حي ونشره',
          'subtitle': 'تضمين التطبيق في معرض أعمالك البرمجي ونشره على Google Play.',
        },
        'requirements': [
          {
            'icon': Icons.school_rounded,
            'title': 'التخصص الأكاديمي',
            'subtitle':
                'طالب أو خريج هندسة حاسوب، هندسة برمجيات، أو علوم حاسوب وتكنولوجيا المعلومات.',
          },
          {
            'icon': Icons.code_rounded,
            'title': 'المهارات البرمجية الأساسية',
            'subtitle':
                'معرفة جيدة بلغة Dart وإطار Flutter، وإدارة الحالة باستخدام GetX أو Provider، وربط REST APIs.',
          },
          {
            'icon': Icons.folder_copy_rounded,
            'title': 'المشاريع السابقة (GitHub)',
            'subtitle':
                'إرفاق رابط حساب GitHub يحتوي على مشروعين على الأقل تم إنشاؤهما بـ Flutter.',
          },
        ],
        'perks': [
          {
            'icon': Icons.bolt_rounded,
            'title': 'بيئة تطوير برمجية متكاملة',
            'subtitle':
                'أجهزة حديثة ومحطات عمل مجهزة، إنترنت فايبر عالي السرعة وطاقة مستمرة.',
          },
          {
            'icon': Icons.psychology_rounded,
            'title': 'إشراف مباشر من Senior Flutter Engineer',
            'subtitle':
                'مراجعة كود أسبوعية (Code Review) لتطبيق أساليب الهندسة النظيفة.',
          },
          {
            'icon': Icons.military_tech_rounded,
            'title': 'عقد عمل ووظيفة دائم',
            'subtitle': 'إمكانية توقيع عقد عمل رسمي بالشركة فور إتمام فترة التدريب بنجاح.',
          },
        ],
        'detailedLocation': 'غزة - الرمال، شارع الثلاثيني بالقرب من الجامعة الإسلامية',
      };
    } else if (id == 'opp3') {
      return {
        'id': 'opp3',
        'title': 'مساعد تحليل بيانات وتطبيقات بايثون (Data Analyst)',
        'company': 'مركز الرؤية الرقمية للذكاء الاصطناعي',
        'companySub': 'Digital Vision AI Center',
        'location': 'غزة / النصر - مجمع الإبداع التقني',
        'statusText': 'نشطة ومتاحة',
        'isVerified': true,
        'allowance': '700 ₪ / شهر',
        'duration': '4 أشهر تدريبية',
        'deadline': 'متبقي 10 أيام (30 أكتوبر)',
        'seats': '4 متدربين',
        'tags': [
          '🌐 عن بعد / هجين',
          '📊 تحليل بيانات وذكاء اصطناعي',
          '🕒 دوام جزئي'
        ],
        'about':
            'برنامج مخصص للتدريب على تنظيف ومعالجة البيانات الضخمة، وبناء لوحات التحكم التفاعلية Dashboard، ونمذجة الخوارزميات باستخدام Python و Pandas و PowerBI، واستخراج الرؤى التحليلية لاتخاذ القرارات المؤسسية.',
        'projectHighlight': {
          'title': 'تحليل بيانات حقيقية لشركات إقليمية',
          'subtitle': 'بناء 3 لوحات تفاعلية Dashboards وتقارير تنبؤية معتمدة.',
        },
        'requirements': [
          {
            'icon': Icons.school_rounded,
            'title': 'التخصص الأكاديمي',
            'subtitle':
                'تخصص نظم المعلومات الحاسوبية، علم البيانات، الهندسة، أو الإحصاء.',
          },
          {
            'icon': Icons.analytics_rounded,
            'title': 'مهارات تحليل البيانات',
            'subtitle':
                'معرفة بلغة Python و مكتبات Pandas و NumPy و SQL وأساسيات PowerBI.',
          },
        ],
        'perks': [
          {
            'icon': Icons.wifi_rounded,
            'title': 'مرونة كاملة بالعمل عن بعد',
            'subtitle':
                'إمكانية إنجاز المهام والتحليل بساعات عمل مرنة ومناسبة للجدول الجامعي.',
          },
          {
            'icon': Icons.military_tech_rounded,
            'title': 'شهادة خبرة معتمدة من مركز الذكاء الاصطناعي',
            'subtitle': 'توصية وشهادة خبرة موثقة تدعم ملفك الوظيفي.',
          },
        ],
        'detailedLocation': 'غزة - النصر، مجمع الإبداع التقني',
      };
    }

    // Default for opp1
    return {
      'id': id,
      'title': 'تدريب عملي مدفوع: مصمم تجربة وواجهات المستخدم (UI/UX Intern)',
      'company': 'شركة تكنوبلاس للحلول الرقمية',
      'companySub': 'TechnoPlus Digital Solutions',
      'location': 'غزة / الرمال - برج الشروق (الطابق الرابع)',
      'statusText': 'نشطة ومتاحة',
      'isVerified': true,
      'allowance': '600 ₪ / شهر',
      'duration': '3 أشهر تدريبية',
      'deadline': 'متبقي 4 أيام (20 أكتوبر)',
      'seats': '3 متدربين فقط',
      'tags': [
        '✨ تدريب منتهي بالتوظيف',
        '🕒 دوام جزئي مرن',
        '🏠 نظام هجين / عن بعد'
      ],
      'about':
          'يهدف هذا البرنامج إلى صقل مهارات طلبة وخريجي الجامعات وتجسير الفجوة بين المعرفة الأكاديمية وسوق العمل الفعلي. سينضم المتدرب كعضو فاعل إلى فريق تجربة المستخدم، للمشاركة المباشرة في تصميم منصات الويب وتطبيقات الهواتف الذكية لمشاريع تجارية حية محلياً ودولياً، واكتساب منهجيات العمل الاحترافي مثل Design Thinking و Agile UX.',
      'projectHighlight': {
        'title': 'مشاريع حقيقية بنسبة 100%',
        'subtitle': 'ستنتهي فترة التدريب بملف أعمال يحتوي على 3 مشاريع واقعية منشورة.',
      },
      'requirements': [
        {
          'icon': Icons.school_rounded,
          'title': 'التخصص الأكاديمي',
          'subtitle':
              'طالب جامعي بسنته الأخيرة أو خريج جديد في هندسة البرمجيات، الوسائط المتعددة (Multimedia)، أو تكنولوجيا المعلومات.',
        },
        {
          'icon': Icons.tune_rounded,
          'title': 'المهارات التقنية وأدوات التصميم',
          'subtitle':
              'معرفة ممتازة ببرنامج Figma، ومبادئ Auto-Layout والمكونات (Components)، وأساسيات أنظمة التصميم (Design Systems).',
        },
        {
          'icon': Icons.folder_copy_rounded,
          'title': 'معرض الأعمال (Portfolio)',
          'subtitle':
              'إرفاق رابط لأعمال سابقة أو دراسات حالة (Behance, Dribbble) أو رابط Figma تفاعلي.',
        },
        {
          'icon': Icons.chat_bubble_outline_rounded,
          'title': 'الشغف والعمل الجماعي',
          'subtitle':
              'القدرة على استقبال التغذية الراجعة البناءة، والتعاون الإيجابي مع فريق تطوير الواجهات الأمامية.',
        },
      ],
      'perks': [
        {
          'icon': Icons.bolt_rounded,
          'title': 'بيئة عمل ملائمة ومستقرة',
          'subtitle':
              'مقر مجهز بالإنترنت فائق السرعة، ومصادر الطاقة البديلة المستمرة.',
        },
        {
          'icon': Icons.psychology_rounded,
          'title': 'إشراف وتوجيه مهني (1on1 Mentorship)',
          'subtitle':
              'متابعة أسبوعية من Senior Product Designer لتطوير مهاراتك خطوة بخطوة.',
        },
        {
          'icon': Icons.military_tech_rounded,
          'title': 'فرصة التثبيت والتوظيف الفعلي',
          'subtitle': 'إمكانية التعيين بعقد دوام كامل فور اجتياز فترة التدريب بكفاءة.',
        },
      ],
      'detailedLocation': 'الرمال، بالقرب من الاتصالات',
    };
  }
}
