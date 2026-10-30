import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String get currentProviderId => FirebaseAuth.instance.currentUser!.uid;

class ProviderFormat {
  ProviderFormat._();

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  static const Map<String, String> dayNames = {
    'sat': 'السبت',
    'sun': 'الأحد',
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
  };

  static String number(num value, {int decimals = 0}) {
    final parts = value.abs().toStringAsFixed(decimals).split('.');
    final whole = parts.first;
    final buffer = StringBuffer(value < 0 ? '-' : '');

    for (int i = 0; i < whole.length; i++) {
      buffer.write(whole[i]);
      final remaining = whole.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }

    return parts.length > 1 ? '$buffer.${parts[1]}' : buffer.toString();
  }

  static String price(dynamic amount) {
    final value = (amount ?? 0).toDouble();
    if (value == 0) return 'مجانا';
    return '${number(value, decimals: value % 1 == 0 ? 0 : 2)} ₪';
  }

  static String timeAgo(Timestamp? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toDate());
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} ساعة';
    return 'قبل ${diff.inDays} يوم';
  }

  static String time12h(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;

    final hour = int.tryParse(parts[0]) ?? 0;
    final period = hour < 12 ? 'ص' : 'م';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${hour12.toString().padLeft(2, '0')}:${parts[1]} $period';
  }

  static String date(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  static String dayName(String key) => dayNames[key] ?? '';

  static const List<String> _weekdays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];

  static String appointment(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final difference = day.difference(today).inDays;

    final weekday = _weekdays[date.weekday - 1];
    final String dayText;
    if (difference == 0) {
      dayText = 'اليوم $weekday';
    } else if (difference == 1) {
      dayText = 'غدًا $weekday';
    } else {
      dayText = '$weekday ${date.day} ${_months[date.month - 1]}';
    }

    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final String period;
    if (date.hour < 12) {
      period = 'صباحًا';
    } else if (date.hour < 15) {
      period = 'ظهرًا';
    } else if (date.hour < 18) {
      period = 'عصرًا';
    } else {
      period = 'مساءً';
    }

    return '$dayText - $hour12:$minute $period';
  }

  static String orderStatus(String? status) {
    switch (status) {
      case 'pending':
        return 'جديد';
      case 'confirmed':
        return 'مؤكد';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'ready_for_pickup':
        return 'جاهز للاستلام';
      case 'completed':
        return 'مكتمل';
      case 'canceled':
        return 'ملغي';
      default:
        return '';
    }
  }

  static String paymentMethod(String? method) {
    switch (method) {
      case 'cash':
        return 'نقدًا';
      case 'bank':
        return 'تحويل بنكي';
      case 'jawwal_pay':
        return 'Jawwal Pay';
      default:
        return 'دفع إلكتروني';
    }
  }

  static String paymentStatus(String? status) {
    switch (status) {
      case 'paid':
        return 'مدفوع';
      case 'partially_paid':
        return 'مدفوع جزئيًا';
      case 'pay_on_arrival':
        return 'الدفع عند الاستلام';
      case 'awaiting_transfer':
        return 'بانتظار التحويل';
      case 'refunded':
        return 'مسترد';
      default:
        return '';
    }
  }

  static String attendance(String? mode) {
    switch (mode) {
      case 'in_person':
        return 'حضور وجاهي بالمركز';
      case 'online':
        return 'عن بُعد (أونلاين)';
      case 'hybrid':
        return 'مختلط (هجين)';
      default:
        return '';
    }
  }

  static const List<String> cancellationPolicies = [
    'full_refund_48h',
    'half_refund_first_session',
    'custom',
  ];

  static String cancellationPolicy(String? policy) {
    switch (policy) {
      case 'full_refund_48h':
        return 'مرنة (إلغاء كامل قبل 48 ساعة من الدورة)';
      case 'half_refund_first_session':
        return 'استرداد 50% بعد الجلسة الأولى';
      case 'custom':
        return 'سياسة مخصصة للمركز';
      default:
        return 'لم تُحدد بعد';
    }
  }
}