import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/state/provider_helpers.dart';

class BookingTicketController extends GetxController {
  final String orderId;

  BookingTicketController(this.orderId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _orderSubscription;

  final isLoading = true.obs;
  final order = <String, dynamic>{}.obs;
  final course = <String, dynamic>{}.obs;
  final provider = <String, dynamic>{}.obs;

  static const List<String> _weekdays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  String text(String key) => (order[key] ?? '').toString();

  String get status => text('orderStatus');

  bool get isConfirmed => status == 'confirmed' || status == 'completed';

  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'معتمدة ونشطة';
      case 'completed':
        return 'مكتملة';
      case 'canceled':
        return 'ملغاة';
      default:
        return 'بانتظار تأكيد المركز';
    }
  }

  String get providerAddress => [provider['city'], provider['addressDetails']]
      .where((text) => (text ?? '').toString().isNotEmpty)
      .join('، ');

  DateTime? get startDateTime {
    final appointment = order['appointmentAt'];
    if (appointment is Timestamp) return appointment.toDate();

    final start = course['startDate'];
    if (start is! Timestamp) return null;
    final date = start.toDate();
    final parts = (course['startTime'] ?? '').toString().split(':');
    final hour = parts.length == 2 ? int.tryParse(parts[0]) ?? 9 : 9;
    final minute = parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  String get dateText {
    final date = startDateTime;
    if (date == null) return 'يُحدد الموعد بعد تأكيد المركز';
    return '${_weekdays[date.weekday - 1]} ${ProviderFormat.date(date)}';
  }

  String get timeText {
    final date = startDateTime;
    if (date == null) return '';
    final time = ProviderFormat.time12h(
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
    );
    final venue = (course['venueName'] ?? '').toString();
    return venue.isEmpty ? 'الساعة $time' : 'الساعة $time • $venue';
  }

  String get paymentText {
    switch (text('paymentMethod')) {
      case 'cash':
        return 'الدفع النقدي عند الحضور';
      case 'jawwal_pay':
        return 'محفظة جوال باي (Jawwal Pay)';
      case 'card':
        return 'بطاقة بنكية';
      default:
        return ProviderFormat.paymentMethod(text('paymentMethod'));
    }
  }

  @override
  void onInit() {
    super.onInit();
    _orderSubscription = _db.collection('orders').doc(orderId).snapshots().listen((doc) {
      order.value = doc.data() ?? {};
      isLoading.value = false;
      _loadDetails();
    }, onError: (Object e) {
      debugPrint('BookingTicketController: $e');
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadDetails() async {
    try {
      final courseId = text('courseId');
      final providerId = text('providerId');
      if (courseId.isNotEmpty && course.isEmpty) {
        course.value = (await _db.collection('courses').doc(courseId).get()).data() ?? {};
      }
      if (providerId.isNotEmpty && provider.isEmpty) {
        provider.value = (await _db.collection('serviceProviders').doc(providerId).get()).data() ?? {};
      }
    } catch (e) {
      debugPrint('BookingTicketController: $e');
    }
  }

  static String _calendarDate(DateTime date) {
    final utc = date.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${utc.year}${two(utc.month)}${two(utc.day)}T${two(utc.hour)}${two(utc.minute)}00Z';
  }

  Future<void> addToCalendar() async {
    final start = startDateTime;
    if (start == null) {
      Get.snackbar('الموعد غير محدد', 'سيتم تحديد الموعد بعد تأكيد المركز للحجز');
      return;
    }

    final end = start.add(const Duration(hours: 2));
    final url = Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': text('itemTitle'),
      'dates': '${_calendarDate(start)}/${_calendarDate(end)}',
      'details': 'رقم التذكرة: ${text('orderNumber')}',
      'location': providerAddress,
    });
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> openLocation() async {
    final mapUrl = (provider['mapUrl'] ?? '').toString();
    final url = mapUrl.isNotEmpty
        ? Uri.parse(mapUrl)
        : Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${provider['businessName'] ?? ''} $providerAddress',
    });
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}