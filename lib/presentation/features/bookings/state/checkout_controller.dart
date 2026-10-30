import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class CheckoutController extends GetxController {
  final String type;
  final String itemId;

  CheckoutController({required this.type, required this.itemId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final couponController = TextEditingController();

  final isLoading = true.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;

  final item = <String, dynamic>{}.obs;
  final provider = <String, dynamic>{}.obs;
  final student = <String, dynamic>{}.obs;
  final coupon = Rxn<Map<String, dynamic>>();
  final paymentMethod = 'cash'.obs;

  static const Map<String, String> paymentNames = {
    'jawwal_pay': 'محفظة جوال باي (Jawwal Pay)',
    'cash': 'الدفع النقدي عند الحضور (كاش)',
    'card': 'بطاقة بنكية / فيزا كارد (Visa/Mastercard)',
  };

  static const List<String> enabledPayments = ['cash'];

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  bool get isSession => type == 'session';

  String text(String key) => (item[key] ?? '').toString();

  String get title => isSession ? 'جلسة خصوصية مع ${text('businessName')}' : text('title');

  String get providerName => isSession ? text('businessName') : (provider['businessName'] ?? '').toString();

  String get providerArea => (provider['city'] ?? '').toString();

  num get originalPrice => isSession ? (item['hourlyRate'] ?? 0) : (item['originalPrice'] ?? 0);

  num get studentDiscount {
    if (isSession) {
      final num percent = item['studentDiscountPercent'] ?? 0;
      return originalPrice * percent / 100;
    }
    final num? discounted = item['discountedPrice'];
    return discounted == null ? 0 : originalPrice - discounted;
  }

  int get studentDiscountPercent => originalPrice == 0 ? 0 : (studentDiscount / originalPrice * 100).round();

  num get couponDiscount {
    final data = coupon.value;
    if (data == null) return 0;
    final afterStudent = originalPrice - studentDiscount;
    final num amount = data['discountAmount'] ?? afterStudent * ((data['discountPercent'] ?? 0) as num) / 100;
    return amount > afterStudent ? afterStudent : amount;
  }

  num get fees => item['certificateFee'] ?? 0;

  num get total => originalPrice - studentDiscount - couponDiscount + fees;

  String get dateText {
    final value = item['startDate'];
    if (value is! Timestamp) return '';
    final date = value.toDate();
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String get attendanceText {
    switch (item['attendanceMode']) {
      case 'online':
        return 'الحضور أونلاين عن بعد';
      case 'hybrid':
        return 'الحضور مدمج (وجاهي + أونلاين)';
      default:
        return 'الحضور وجاهي في مقر ${isSession ? 'القاعة' : 'الأكاديمية'}';
    }
  }

  static String money(num value) => value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    couponController.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    try {
      final collection = isSession ? 'serviceProviders' : 'courses';
      final itemDoc = await _db.collection(collection).doc(itemId).get();
      item.value = itemDoc.data() ?? {};

      final providerId = isSession ? itemId : text('providerId');
      if (providerId.isNotEmpty) {
        final providerDoc = await _db.collection('serviceProviders').doc(providerId).get();
        provider.value = {...?providerDoc.data(), 'id': providerDoc.id};
      }

      final studentDoc = await _db.collection('Users').doc(currentStudentId).get();
      student.value = studentDoc.data() ?? {};
    } catch (e) {
      debugPrint('CheckoutController: $e');
      errorMessage.value = 'حدث خطأ أثناء تحميل تفاصيل الطلب';
    }
    isLoading.value = false;
  }

  Future<void> applyCoupon() async {
    final code = couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      final result = await _db
          .collection('offers')
          .where('code', isEqualTo: code)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        coupon.value = null;
        Get.snackbar('كوبون غير صالح', 'تأكد من كتابة الكود بشكل صحيح');
        return;
      }
      coupon.value = {...result.docs.first.data(), 'code': code};
    } catch (e) {
      debugPrint('CheckoutController: $e');
      Get.snackbar('خطأ', 'لم نتمكن من التحقق من الكوبون');
    }
  }

  void removeCoupon() {
    coupon.value = null;
    couponController.clear();
  }

  void changePayment(String method) {
    if (enabledPayments.contains(method)) {
      paymentMethod.value = method;
    } else {
      Get.snackbar('قريبًا', 'الدفع الإلكتروني عبر المحافظ والبطاقات سيتوفر قريبًا');
    }
  }

  Future<String?> confirm() async {
    isSending.value = true;
    try {
      if (!isSession) {
        final existing = await _db.collection('orders').where('studentId', isEqualTo: currentStudentId).get();
        final hasOrder = existing.docs.any(
              (doc) => doc.data()['courseId'] == itemId && doc.data()['orderStatus'] != 'canceled',
        );
        if (hasOrder) {
          Get.snackbar('حجز موجود', 'لديك طلب حجز سابق لهذه الدورة');
          return null;
        }
      }

      final now = DateTime.now();
      final order = await _db.collection('orders').add({
        'orderNumber': '${isSession ? 'SES' : 'TKT'}-${now.year}-${now.millisecondsSinceEpoch % 10000}',
        'orderType': isSession ? 'session' : 'course',
        'orderStatus': 'pending',
        'providerId': provider['id'] ?? '',
        'courseId': isSession ? '' : itemId,
        'studentId': currentStudentId,
        'studentName': student['name'] ?? '',
        'studentPhone': student['phone'] ?? '',
        'studentUniversity': student['university'] ?? '',
        'studentMajor': student['specialization'] ?? student['major'] ?? '',
        'studentAvatar': student['avatarUrl'] ?? '',
        'studentNote': '',
        'itemTitle': title,
        'subtotalAmount': originalPrice,
        'discountPercent': studentDiscountPercent,
        'couponCode': coupon.value?['code'] ?? '',
        'couponDiscount': couponDiscount,
        'totalPaidAmount': double.parse(total.toStringAsFixed(2)),
        'paymentMethod': paymentMethod.value,
        'paymentStatus': paymentMethod.value == 'cash' ? 'pay_on_arrival' : 'paid',
        'attendanceMode': item['attendanceMode'] ?? 'in_person',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      return order.id;
    } catch (e) {
      debugPrint('CheckoutController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال الحجز، حاول مرة أخرى');
      return null;
    } finally {
      isSending.value = false;
    }
  }

  void retry() {
    errorMessage.value = '';
    isLoading.value = true;
    _load();
  }
}