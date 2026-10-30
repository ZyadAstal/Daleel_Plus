import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../providers/state/provider_helpers.dart';
import 'print_centers_controller.dart';

class PrintOrderController extends GetxController {
  final Map<String, dynamic> center;

  PrintOrderController({required this.center});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic> get service => Map<String, dynamic>.from(center['service'] ?? {});

  double _price(String key, double fallback) => (service[key] ?? fallback).toDouble();

  double get bwPrice => _price('bwPagePrice', 0.15);
  double get colorPrice => _price('colorPagePrice', 0.40);
  double get thickExtra => _price('thickPaperExtra', 0.05);
  double get glossyExtra => _price('glossyPaperExtra', 0.12);
  double get spiralPrice => _price('spiralBindingPrice', 4);
  double get thermalPrice => _price('thermalBindingPrice', 6);
  double get hardCoverPrice => _price('hardCoverBindingPrice', 25);
  double get deliveryFee => _price('deliveryFee', 5);
  bool get offersDelivery => service['offersDelivery'] ?? false;
  int get discountPercent => ((service['studentDiscountPercent'] ?? 0) as num).toInt();

  static String money(double value) => '${ProviderFormat.number(value, decimals: 2)} ₪';

  final fileName = ''.obs;
  final fileUrl = ''.obs;
  final pages = 0.obs;
  final copies = 1.obs;
  final paper = 'normal'.obs;
  final colorMode = 'bw'.obs;
  final binding = 'none'.obs;
  final pickup = 'store'.obs;
  final isSubmitting = false.obs;
  final paymentMethod = 'cash'.obs;

  static const Map<String, String> paymentMethods = {
    'cash': 'عند الاستلام (نقدًا)',
    'jawwal_pay': 'Jawwal Pay',
    'palpay': 'PalPay',
    'bank': 'تحويل بنكي',
  };

  static const List<String> enabledPaymentMethods = ['cash'];

  String get paymentLabel =>
      paymentMethod.value == 'cash' ? 'عند الاستلام' : paymentMethods[paymentMethod.value]!;

  double get paperExtra {
    switch (paper.value) {
      case 'thick':
        return thickExtra;
      case 'glossy':
        return glossyExtra;
      default:
        return 0;
    }
  }

  double get bindingPrice {
    switch (binding.value) {
      case 'spiral':
        return spiralPrice;
      case 'thermal':
        return thermalPrice;
      case 'hardcover':
        return hardCoverPrice;
      default:
        return 0;
    }
  }

  String get colorLabel => colorMode.value == 'bw' ? 'أبيض وأسود' : 'ألوان ليزرية';

  String get bindingLabel {
    switch (binding.value) {
      case 'spiral':
        return 'سلك معدني حلزوني';
      case 'thermal':
        return 'تجليد حراري احترافي';
      case 'hardcover':
        return 'كرتون مقوى فاخر';
      default:
        return 'بدون تجليد';
    }
  }

  double get printingCost {
    final pagePrice = (colorMode.value == 'bw' ? bwPrice : colorPrice) + paperExtra;
    return pagePrice * pages.value * copies.value;
  }

  double get bindingCost => bindingPrice * copies.value;

  double get deliveryCost => pickup.value == 'delivery' ? deliveryFee : 0;

  double get discountAmount => (printingCost + bindingCost) * discountPercent / 100;

  double get total => printingCost + bindingCost - discountAmount + deliveryCost;

  void setFile({required String name, required String url, required int pageCount}) {
    fileName.value = name;
    fileUrl.value = url;
    pages.value = pageCount;
  }

  void increaseCopies() => copies.value++;

  void decreaseCopies() {
    if (copies.value > 1) copies.value--;
  }

  Future<String?> submit() async {
    if (fileName.value.isEmpty || pages.value <= 0) {
      Get.snackbar('تنبيه', 'أضف الملف المراد طباعته وعدد صفحاته أولًا');
      return null;
    }
    if (isSubmitting.value) return null;
    isSubmitting.value = true;

    try {
      final studentSnapshot = await _db.collection('Users').doc(currentStudentId).get();
      final student = studentSnapshot.data() ?? {};
      final now = DateTime.now();

      final orderRef = await _db.collection('orders').add({
        'orderNumber': 'PRT-${now.year}-${now.millisecondsSinceEpoch % 100000}',
        'orderType': 'printing',
        'orderStatus': 'pending',
        'providerId': center['id'],
        'studentId': currentStudentId,
        'studentName': student['name'] ?? '',
        'studentPhone': student['phone'] ?? '',
        'studentUniversity': student['university'] ?? '',
        'studentAvatar': '',
        'itemTitle':
        'طباعة ${fileName.value} (${pages.value} صفحة $colorLabel - ${copies.value} نسخة)',
        'pickupLocation': pickup.value == 'delivery'
            ? 'توصيل لبوابة الجامعة / السكن'
            : (center['businessName'] ?? ''),
        'fileUrl': fileUrl.value,
        'printSpecs': {
          'pages': pages.value,
          'copies': copies.value,
          'paper': paper.value,
          'colorMode': colorMode.value,
          'binding': binding.value,
          'pickup': pickup.value,
        },
        'subtotalAmount': printingCost + bindingCost,
        'discountPercent': discountPercent,
        'totalPaidAmount': double.parse(total.toStringAsFixed(2)),
        'paymentMethod': paymentMethod.value,
        'paymentStatus': paymentMethod.value == 'cash' ? 'pay_on_arrival' : 'awaiting_transfer',
        'studentNote': '',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      return orderRef.id;
    } catch (e) {
      debugPrint('PrintOrderController: $e');
      Get.snackbar('خطأ', 'لم يتم إرسال الطلب، حاول مرة أخرى');
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}