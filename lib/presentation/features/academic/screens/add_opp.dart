
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<String, dynamic>> loadCurrentProvider() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('يجب تسجيل الدخول أولاً.');
  }

  final db = FirebaseFirestore.instance;

  final userDoc = await db.collection('Users').doc(user.uid).get();

  if (!userDoc.exists) {
    throw Exception('لا يوجد ملف لهذا المستخدم في Users.');
  }

  final userData = userDoc.data()!;

  if (userData['user_role'] != 'Provider' ||
      userData['status'] != 'active') {
    throw Exception('الحساب ليس مزود خدمة نشطاً.');
  }

  final providerQuery = await db
      .collection('Service_Providers')
      .where('user_id', isEqualTo: user.uid)
      .limit(1)
      .get();

  if (providerQuery.docs.isEmpty) {
    throw Exception('لم يتم العثور على ملف مزود الخدمة.');
  }

  final providerData = providerQuery.docs.first.data();

  return {
    'uid': user.uid,
    'provider_name': userData['fullname'] ?? '',
    'provider_avatar_url': userData['avatar_url'],
    'business_name': providerData['business_name'] ?? '',
    'city': providerData['city'] ?? '',
    'verification_status':
    providerData['verification_status'] ?? 'pending',
  };
}

Future<void> addSampleOpportunity({
  required Map<String, dynamic> provider,
  required String title,
  required String opportunityType,
  required String description,
  required List<String> requirements,
  required num? stipendSalary,
  required String workMode,
  required String city,
  required DateTime deadline,
  required String application,
  required bool featured,
}) async {
  final db = FirebaseFirestore.instance;
  final uid = provider['uid'] as String;

  final existing = await db
      .collection('jobs')
      .where('provider_id', isEqualTo: uid)
      .where('title', isEqualTo: title)
      .limit(1)
      .get();

  if (existing.docs.isNotEmpty) {
    throw Exception('هذه الفرصة موجودة مسبقاً: $title');
  }

  final doc = db.collection('jobs').doc();

  await doc.set({
    'document_id': doc.id,
    'provider_id': uid,
    'uid': uid,
    'title': title,
    'opportunity_type': opportunityType,
    'description': description,
    'requirements': requirements,
    'stipend_salary': stipendSalary,
    'work_mode': workMode,
    'city_location': city,
    'deadline_date': Timestamp.fromDate(deadline),
    'application_link_or_email': application,
    'is_featured': featured,
    'is_active': true,
    'created_at': FieldValue.serverTimestamp(),

    // بيانات الناشر لعرضها في بطاقة الفرصة.
    'provider_name': provider['provider_name'],
    'business_name': provider['business_name'],
    'provider_avatar_url': provider['provider_avatar_url'],
    'provider_verification_status':
    provider['verification_status'],
  });
}
