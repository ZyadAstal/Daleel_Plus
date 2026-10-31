import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../printing/state/print_centers_controller.dart';

class SupportController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final detailsController = TextEditingController();
  final scrollController = ScrollController();

  final isLoading = true.obs;
  final isSending = false.obs;
  final faqs = <Map<String, dynamic>>[].obs;
  final openTickets = 0.obs;
  final contact = <String, dynamic>{}.obs;
  final searchText = ''.obs;
  final expandedIndex = (-1).obs;
  final ticketType = 'course'.obs;
  final attachmentUrl = ''.obs;

  static const Map<String, String> ticketTypes = {
    'course': 'مشكلة حجز دورة',
    'printing': 'جودة خدمة الطباعة',
    'payment': 'مشكلة دفع ورصيد',
    'suggestion': 'اقتراح أو ملاحظة',
  };

  static const Map<String, IconData> ticketIcons = {
    'course': Icons.event_busy_outlined,
    'printing': Icons.print_outlined,
    'payment': Icons.payments_outlined,
    'suggestion': Icons.lightbulb_outline,
  };

  String get whatsapp => (contact['whatsapp'] ?? '970599001234').toString();

  String get phone => (contact['phone'] ?? '+970599001234').toString();

  List<Map<String, dynamic>> get visibleFaqs {
    final query = searchText.value.trim();
    if (query.isEmpty) return faqs;
    return faqs
        .where(
          (faq) =>
              '${faq['question'] ?? ''} ${faq['answer'] ?? ''}'.contains(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(
      _db
          .collection('faqs')
          .snapshots()
          .listen(
            (result) {
              final list = result.docs.map((doc) => doc.data()).toList();
              list.sort(
                (a, b) => ((a['order'] ?? 0) as num).compareTo(
                  (b['order'] ?? 0) as num,
                ),
              );
              faqs.value = list;
              isLoading.value = false;
            },
            onError: (Object e) {
              debugPrint('SupportController: $e');
              isLoading.value = false;
            },
          ),
    );

    _subscriptions.add(
      _db
          .collection('supportTickets')
          .where('studentId', isEqualTo: currentStudentId)
          .snapshots()
          .listen((result) {
            openTickets.value = result.docs
                .where((doc) => doc.data()['status'] != 'closed')
                .length;
          }, onError: (Object e) => debugPrint('SupportController: $e')),
    );

    _subscriptions.add(
      _db.collection('appSettings').doc('support').snapshots().listen((doc) {
        contact.value = doc.data() ?? {};
      }, onError: (Object e) => debugPrint('SupportController: $e')),
    );
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    detailsController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void scrollToForm() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void changeSearch(String value) => searchText.value = value;

  void toggleFaq(int index) =>
      expandedIndex.value = expandedIndex.value == index ? -1 : index;

  void changeType(String value) => ticketType.value = value;

  void setAttachment(String url) {
    if (url.trim().startsWith('http')) {
      attachmentUrl.value = url.trim();
    } else {
      Get.snackbar('رابط غير صحيح', 'أدخل رابط صورة يبدأ بـ http');
    }
  }

  Future<void> openWhatsapp() => launchUrl(
    Uri.parse('https://wa.me/${whatsapp.replaceAll('+', '')}'),
    mode: LaunchMode.externalApplication,
  );

  Future<void> callSupport() => launchUrl(Uri.parse('tel:$phone'));

  Future<bool> sendTicket() async {
    if (detailsController.text.trim().length < 10) {
      Get.snackbar('التفاصيل قصيرة', 'اكتب تفاصيل المشكلة بشكل أوضح');
      return false;
    }

    isSending.value = true;
    try {
      final user = await _db.collection('Users').doc(currentStudentId).get();
      await _db.collection('supportTickets').add({
        'studentId': currentStudentId,
        'studentName': user.data()?['name'] ?? '',
        'type': ticketType.value,
        'details': detailsController.text.trim(),
        'attachmentUrl': attachmentUrl.value,
        'status': 'open',
        'createdAt': Timestamp.now(),
      });
      detailsController.clear();
      attachmentUrl.value = '';
      Get.snackbar(
        'تم إرسال التذكرة',
        'سيتم تعيين مشرف مختص لمتابعة حالتك فورًا',
      );
      return true;
    } catch (e) {
      debugPrint('SupportController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال التذكرة، حاول مرة أخرى');
      return false;
    } finally {
      isSending.value = false;
    }
  }
}
