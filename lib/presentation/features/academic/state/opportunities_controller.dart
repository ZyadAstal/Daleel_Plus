import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpportunitiesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final opportunities = <Map<String, dynamic>>[].obs;
  final selectedFilter = 'الكل'.obs;
  final searchQuery = ''.obs;

  List<String> get filters => [
        'الكل',
        'تدريب منتهي بالتوظيف',
        'دوام جزئي',
        'عن بعد / هجين',
        'مدفوع الأجر',
      ];

  List<Map<String, dynamic>> get filteredOpportunities {
    Iterable<Map<String, dynamic>> list = opportunities;

    if (selectedFilter.value != 'الكل') {
      list = list.where((opp) {
        final tags = (opp['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final type = opp['type'] ?? '';
        return tags.contains(selectedFilter.value) || type.toString().contains(selectedFilter.value);
      });
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      list = list.where((opp) {
        final title = (opp['title'] ?? '').toString().toLowerCase();
        final company = (opp['company'] ?? '').toString().toLowerCase();
        return title.contains(q) || company.contains(q);
      });
    }

    return list.toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db.collection('opportunities').get();
      if (snapshot.docs.isNotEmpty) {
        opportunities.value = snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      } else {
        opportunities.value = _fallbackOpportunitiesData();
      }
    } catch (e) {
      debugPrint('OpportunitiesController error: $e');
      opportunities.value = _fallbackOpportunitiesData();
    } finally {
      isLoading.value = false;
    }
  }

  void openOpportunityDetails(Map<String, dynamic> opp) {
    Get.toNamed('/opportunity-details', parameters: {'opportunityId': opp['id']?.toString() ?? 'opp1'});
  }

  List<Map<String, dynamic>> _fallbackOpportunitiesData() {
    return [
      {
        'id': 'opp1',
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
        'type': 'تدريب منتهي بالتوظيف',
        'workMode': 'نظام هجين / عن بعد',
        'tags': ['تدريب منتهي بالتوظيف', 'دوام جزئي مرن', 'نظام هجين / عن بعد'],
      },
      {
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
        'type': 'مدفوع الأجر',
        'workMode': 'وجاهي بالشركة',
        'tags': ['تدريب منتهي بالتوظيف', 'مدفوع الأجر'],
      },
      {
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
        'type': 'عن بعد / هجين',
        'workMode': 'عن بعد بالكامل',
        'tags': ['عن بعد / هجين', 'دوام جزئي'],
      },
    ];
  }
}
