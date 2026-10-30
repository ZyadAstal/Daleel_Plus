import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SeedCourses {
  static Future<void> add20Courses() async {
    final db = FirebaseFirestore.instance;

    final titles = [
      'أساسيات تطوير الويب',
      'التسويق الرقمي',
      'تحليل البيانات باستخدام Python',
      'تصميم واجهات UI/UX',
      'البرمجة بلغة Dart',
      'تطوير تطبيقات Flutter',
      'قواعد البيانات SQL',
      'الأمن السيبراني',
      'إدارة المشاريع',
      'اللغة الإنجليزية للمبتدئين',
      'التصميم الجرافيكي',
      'Excel وتحليل البيانات',
      'إدارة وسائل التواصل الاجتماعي',
      'الذكاء الاصطناعي للمبتدئين',
      'تعلم لغة Java',
      'التجارة الإلكترونية',
      'المونتاج وصناعة الفيديو',
      'الحوسبة السحابية',
      'مهارات القيادة والتواصل',
      'تطوير تطبيقات الويب المتقدمة',
    ];

    final categories = [
      'Web Development',
      'Digital Marketing',
      'Data Analysis',
      'UI UX Design',
      'Programming',
      'Mobile Development',
      'Databases',
      'Cybersecurity',
      'Project Management',
      'Languages',
      'Graphic Design',
      'Office Skills',
      'Social Media',
      'Artificial Intelligence',
      'Programming',
      'E-commerce',
      'Video Editing',
      'Cloud Computing',
      'Soft Skills',
      'Web Development',
    ];

    final descriptions = [
      'تعلم HTML وCSS وJavaScript.',
      'تعلم التسويق الإلكتروني وإدارة الحملات.',
      'تحليل البيانات باستخدام Python وPandas.',
      'تعلم التصميم وتجربة المستخدم باستخدام Figma.',
      'تعلم أساسيات لغة Dart.',
      'إنشاء تطبيقات الهواتف باستخدام Flutter.',
      'تعلم SQL وتصميم قواعد البيانات.',
      'مقدمة في حماية الأنظمة والشبكات.',
      'تعلم تخطيط المشاريع وإدارة الموارد.',
      'تطوير مهارات اللغة الإنجليزية.',
      'تعلم مبادئ التصميم الجرافيكي.',
      'تحليل البيانات باستخدام Excel.',
      'إدارة المحتوى على وسائل التواصل الاجتماعي.',
      'مقدمة في الذكاء الاصطناعي.',
      'تعلم البرمجة باستخدام Java.',
      'تعلم إنشاء المتاجر الإلكترونية.',
      'تعلم تحرير الفيديو والمونتاج.',
      'مقدمة في الحوسبة السحابية.',
      'تطوير مهارات القيادة والتواصل.',
      'بناء تطبيقات ويب متقدمة.',
    ];

    final modes = [
      'in_person',
      'online',
      'hybrid',
      'online',
      'online',
      'hybrid',
      'in_person',
      'online',
      'in_person',
      'online',
      'hybrid',
      'in_person',
      'online',
      'online',
      'in_person',
      'online',
      'hybrid',
      'online',
      'in_person',
      'hybrid',
    ];

    final levels = [
      'beginner',
      'beginner',
      'intermediate',
      'beginner',
      'beginner',
      'intermediate',
      'beginner',
      'intermediate',
      'beginner',
      'beginner',
      'beginner',
      'beginner',
      'beginner',
      'beginner',
      'intermediate',
      'beginner',
      'beginner',
      'advanced',
      'beginner',
      'advanced',
    ];

    final prices = [
      300,
      200,
      400,
      280,
      180,
      350,
      220,
      320,
      250,
      150,
      260,
      170,
      190,
      300,
      280,
      240,
      230,
      380,
      160,
      450,
    ];

    final schedules = [
      ['Sun', 'Tue'],
      ['Mon', 'Wed'],
      ['Sat', 'Tue', 'Thu'],
    ];

    final now = DateTime.now();
    int successCount = 0;

    debugPrint('بدء إضافة 20 دورة إلى courses...');

    // دفعة واحدة تضم 20 مستندًا
    final batch = db.batch();

    for (int i = 0; i < 20; i++) {
      final id = 'course_${(i + 1).toString().padLeft(3, '0')}';

      final mode = modes[i];

      final startDate = DateTime(now.year, now.month, now.day + 14 + (i * 2));

      final data = <String, dynamic>{
        'document_id': id,
        'provider_id': 'provider_${(i % 3 + 1).toString().padLeft(3, '0')}',

        'title': titles[i],
        'category_subtag': categories[i],
        'description': descriptions[i],

        'syllabus_pdf_url': null,
        'cover_image_url': '',

        'original_price': prices[i],
        'discounted_price': i % 3 == 0 ? null : prices[i] - 30,

        'attendance_mode': mode,
        'venue_name': mode == 'online' ? null : 'مركز التدريب ${i % 3 + 1}',
        'virtual_meeting_url': mode == 'in_person'
            ? null
            : 'https://example.com/meetings/$id',

        'start_date': Timestamp.fromDate(startDate),
        'end_date': Timestamp.fromDate(startDate.add(const Duration(days: 30))),

        'schedule_days': schedules[i % schedules.length],
        'start_time': '14:00',
        'end_time': '16:00',
        'total_hours': 24 + (i % 5) * 6,

        'target_level': levels[i],
        'prerequisites': levels[i] == 'beginner'
            ? null
            : 'معرفة أساسية بالمجال',

        'target_audiences': ['طلاب الجامعات', 'الخريجون', 'الباحثون عن عمل'],

        'instructor_name': 'المدرب ${i + 1}',
        'instructor_avatar': null,

        'has_accredited_certificate': true,
        'cancellation_policy': 'Full_Refund_48h',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      };

      batch.set(db.collection('Courses').doc(id), data);
    }

    try {
      await batch.commit().timeout(const Duration(seconds: 60));

      successCount = 20;

      debugPrint('نجحت إضافة جميع الدورات!');
      debugPrint('عدد الدورات المضافة: $successCount');

      // جلب العدد الحالي بعد نجاح الإضافة
      final countResult = await db.collection('Courses').count().get();

      debugPrint('إجمالي المستندات في Courses: ${countResult.count ?? 0}');
    } on FirebaseException catch (e, stack) {
      debugPrint('فشل رفع الدورات');
      debugPrint('Firebase code: ${e.code}');
      debugPrint('Firebase message: ${e.message}');
      debugPrintStack(stackTrace: stack);
      throw Exception('خطأ Firebase (${e.code}): ${e.message ?? 'تحقق من قواعد أمان Firestore Rules'}');
    } catch (e, stack) {
      debugPrint('خطأ أثناء إضافة الدورات: $e');
      debugPrintStack(stackTrace: stack);
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        throw Exception('انتهت مهلة الاتصال. تأكد من اتصال الإنترنت أو قواعد الأمان (Firestore Rules).');
      }
      rethrow;
    }
  }

  static Future<void> testFirestore() async {
    try {
      debugPrint('بدء اختبار Firestore...');

      final result = await FirebaseFirestore.instance
          .collection('Courses')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 20));

      debugPrint('نجح الاتصال!');
      debugPrint('عدد المستندات المقروءة: ${result.docs.length}');
    } catch (e, stack) {
      debugPrint('فشل الاتصال: $e');
      debugPrintStack(stackTrace: stack);
    }
  }
}
