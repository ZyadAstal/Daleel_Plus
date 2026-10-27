import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// ملف مؤقت للتجربة فقط: احذفيه قبل الرفع على GitHub
Future<void> seedPrintCenters() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();

  final centers = <Map<String, dynamic>>[
    {
      'id': 'seed_print_haram',
      'businessName': 'مطبعة ومكتبة الحرم الجامعي المركز',
      'headline': 'طباعة وتجليد الأبحاث ومشاريع التخرج',
      'city': 'غزة',
      'addressDetails': 'أمام بوابة هندسة الأزهر · تبعد 150م',
      'averageRating': 4.9,
      'reviewsCount': 180,
      'closingTime': '20:00',
      'service': {
        'serviceType': 'research_print',
        'serviceTitle': 'طباعة أبحاث وتجليد',
        'bwPagePrice': 0.15,
        'colorPagePrice': 0.40,
        'spiralBindingPrice': 4,
        'thermalBindingPrice': 6,
        'hardCoverBindingPrice': 25,
        'offersDelivery': true,
        'deliveryFee': 5,
        'studentDiscountPercent': 20,
        'prepMinutes': 15,
        'features': const ['استلام فوري خلال 15 دقيقة', 'تجليد مقوى هاردكفر'],
        'offerText': 'خصم 20% للكميات',
      },
    },
    {
      'id': 'seed_print_motafawq',
      'businessName': 'مركز المتفوق للطباعة الرقمية والحلول',
      'headline': 'خدمات التصوير والبحوث الجامعية',
      'city': 'غزة',
      'addressDetails': 'حي الرمال · شارع الثلاثيني',
      'averageRating': 4.8,
      'reviewsCount': 95,
      'closingTime': '20:00',
      'service': {
        'serviceType': 'large_poster',
        'serviceTitle': 'طباعة رقمية ومخططات',
        'bwPagePrice': 0.12,
        'colorPagePrice': 0.20,
        'largePosterPrice': 15,
        'spiralBindingPrice': 4,
        'thermalBindingPrice': 6,
        'hardCoverBindingPrice': 25,
        'offersDelivery': true,
        'deliveryFee': 5,
        'studentDiscountPercent': 20,
        'prepMinutes': 20,
        'features': const ['ورق ألماني فاخر 80 غرام', 'أختام معتمدة لمشاريع التخرج'],
      },
    },
    {
      'id': 'seed_print_quds',
      'businessName': 'مكتبة القدس الأكاديمية والتصوير الجامعي',
      'headline': 'ملازم وأبحاث ورسائل ماجستير',
      'city': 'غزة',
      'addressDetails': 'مقابل الجامعة الإسلامية',
      'averageRating': 4.7,
      'reviewsCount': 210,
      'closingTime': '21:00',
      'service': {
        'serviceType': 'research_print',
        'serviceTitle': 'طباعة ملازم وأبحاث',
        'bwPagePrice': 0.12,
        'colorPagePrice': 0.35,
        'spiralBindingPrice': 3,
        'thermalBindingPrice': 5,
        'hardCoverBindingPrice': 22,
        'offersDelivery': true,
        'deliveryFee': 0,
        'studentDiscountPercent': 15,
        'prepMinutes': 10,
        'features': const ['توصيل مجاني لسكن الطلاب', 'تنسيق رسائل الماجستير'],
      },
    },
    {
      'id': 'seed_print_ofoq',
      'businessName': 'مكتبة أفق الهندسية لتجليد المخططات',
      'headline': 'متخصصة في مشاريع معماري ومدني',
      'city': 'غزة',
      'addressDetails': 'متخصصة في مشاريع معماري ومدني',
      'averageRating': 5.0,
      'reviewsCount': 62,
      'closingTime': '19:00',
      'service': {
        'serviceType': 'graduation_project',
        'serviceTitle': 'تجليد مخططات ومشاريع تخرج',
        'bwPagePrice': 0.20,
        'colorPagePrice': 0.50,
        'largePosterPrice': 18,
        'spiralBindingPrice': 5,
        'thermalBindingPrice': 8,
        'hardCoverBindingPrice': 30,
        'offersDelivery': false,
        'deliveryFee': 0,
        'studentDiscountPercent': 10,
        'prepMinutes': 30,
        'features': const ['ختم ببصمة ذهبية حرارية', 'طي مخططات ليزري دقيق'],
        'highlight': 'تجليد جلدي فاخر بختم ذهبي بارز',
      },
    },
  ];

  for (final center in centers) {
    final id = center['id'] as String;
    final service = center['service'] as Map<String, dynamic>;

    batch.set(db.collection('serviceProviders').doc(id), {
      'uid': id,
      'providerType': 'printing',
      'businessName': center['businessName'],
      'headline': center['headline'],
      'city': center['city'],
      'addressDetails': center['addressDetails'],
      'averageRating': center['averageRating'],
      'reviewsCount': center['reviewsCount'],
      'closingTime': center['closingTime'],
      'openingTime': '08:00',
      'verificationStatus': 'verified',
      'isAcceptingOrders': true,
      'logoUrl': '',
      'coverImageUrl': '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    batch.set(db.collection('printServices').doc('service_$id'), {
      ...service,
      'providerId': id,
      'thickPaperExtra': 0.05,
      'glossyPaperExtra': 0.12,
      'createdAt': Timestamp.now(),
    });
  }

  await batch.commit();
  debugPrint('Seed: ${centers.length} print centers added');
}