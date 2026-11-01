import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'provider_helpers.dart';

enum RequestFilter { pending, active, completed, canceled }

class ProviderRequestsController extends GetxController {
  // initialFilter و initialSearch: لما نفتح الطلبات من زر معين (مثلا "التفاصيل" بالرئيسية)
  ProviderRequestsController({
    RequestFilter initialFilter = RequestFilter.pending,
    String initialSearch = '',
  }) {
    selectedFilter.value = initialFilter;
    searchText.value = initialSearch;
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  String get providerId => currentProviderId;

  static const String allUniversities = 'كل الجامعات';

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final isVerified = false.obs;
  final isAvailable = true.obs;

  final orders = <Map<String, dynamic>>[].obs;
  final selectedFilter = RequestFilter.pending.obs;
  final selectedUniversity = allUniversities.obs;
  final searchText = ''.obs;
  final busyOrderId = ''.obs;

  bool _matchesFilter(Map<String, dynamic> order, RequestFilter filter) {
    final status = order['orderStatus'];
    switch (filter) {
      case RequestFilter.pending:
        return status == 'pending';
      case RequestFilter.active:
        return const ['confirmed', 'in_progress', 'ready_for_pickup'].contains(status);
      case RequestFilter.completed:
        return status == 'completed';
      case RequestFilter.canceled:
        return status == 'canceled';
    }
  }

  int countFor(RequestFilter filter) =>
      orders.where((order) => _matchesFilter(order, filter)).length;

  List<String> get universities {
    final names = orders
        .map((order) => (order['studentUniversity'] ?? '').toString())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
    return [allUniversities, ...names];
  }

  List<Map<String, dynamic>> get visibleOrders {
    final query = searchText.value.trim();

    return orders.where((order) {
      final number = (order['orderNumber'] ?? '').toString();
      final name = (order['studentName'] ?? '').toString();
      final university = (order['studentUniversity'] ?? '').toString();
      final title = (order['itemTitle'] ?? '').toString();

      final matchesSearch = query.isEmpty ||
          number.contains(query.replaceAll('#', '')) ||
          name.contains(query) ||
          title.contains(query);
      final matchesUniversity =
          selectedUniversity.value == allUniversities || university == selectedUniversity.value;

      return _matchesFilter(order, selectedFilter.value) && matchesSearch && matchesUniversity;
    }).toList();
  }

  double get amountToCollect {
    double total = 0;
    for (final order in orders) {
      final isOpen = !['completed', 'canceled'].contains(order['orderStatus']);
      final isUnpaid = const ['pay_on_arrival', 'partially_paid'].contains(order['paymentStatus']);
      if (isOpen && isUnpaid) total += (order['totalPaidAmount'] ?? 0).toDouble();
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    _listenToProvider();
    _listenToOrders();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('ProviderRequestsController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToProvider() {
    final subscription = _db
        .collection('serviceProviders')
        .doc(providerId)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data() ?? {};
      isVerified.value = data['verificationStatus'] == 'verified';
      isAvailable.value = data['isAcceptingOrders'] ?? true;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToOrders() {
    final subscription = _db
        .collection('orders')
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .listen((result) {
      orders.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList()
        ..sort((a, b) {
          final first = a['createdAt'] as Timestamp? ?? Timestamp.now();
          final second = b['createdAt'] as Timestamp? ?? Timestamp.now();
          return second.compareTo(first);
        });
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void changeFilter(RequestFilter filter) => selectedFilter.value = filter;

  void changeUniversity(String university) => selectedUniversity.value = university;

  void changeSearch(String value) => searchText.value = value;

  // notifyTitle و notifyBody: نص الإشعار اللي بيوصل للطالب بعد التغيير
  Future<bool> _updateOrder(
      Map<String, dynamic> order,
      Map<String, dynamic> data,
      String successMessage, {
      String? notifyTitle,
      String? notifyBody,
      Map<String, dynamic> notifyExtra = const {},
      }) async {
    if (busyOrderId.value.isNotEmpty) return false;
    busyOrderId.value = order['id'];

    try {
      await _db.collection('orders').doc(order['id']).update({
        ...data,
        'updatedAt': Timestamp.now(),
      });
      Get.snackbar('تم', successMessage);
      if (notifyTitle != null) {
        await notifyStudent(order, notifyTitle, notifyBody ?? '', extra: notifyExtra);
      }
      return true;
    } catch (e) {
      debugPrint('ProviderRequestsController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
      return false;
    } finally {
      busyOrderId.value = '';
    }
  }

  Future<void> acceptOrder(Map<String, dynamic> order) async {
    final accepted = await _updateOrder(
      order,
      {'orderStatus': 'confirmed'},
      'تم قبول طلب ${order['studentName'] ?? ''}',
      notifyTitle: 'تم قبول طلبك ✅',
      notifyBody: 'تم تأكيد طلبك: ${order['itemTitle'] ?? ''}',
    );

    final courseId = (order['courseId'] ?? '').toString();
    if (!accepted || courseId.isEmpty) return;

    try {
      await _db.collection('courses').doc(courseId).update({
        'bookedSeats': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('ProviderRequestsController: $e');
    }
  }

  Future<bool> rejectOrder(Map<String, dynamic> order) {
    return _updateOrder(
      order,
      {'orderStatus': 'canceled'},
      'تم رفض الطلب',
      notifyTitle: 'تعذر قبول طلبك',
      notifyBody: 'نعتذر، لم يتم قبول طلبك: ${order['itemTitle'] ?? ''}',
    );
  }

  Future<bool> confirmDelivery(Map<String, dynamic> order) {
    return _updateOrder(
      order,
      {'orderStatus': 'completed', 'paymentStatus': 'paid'},
      'تم تأكيد التسليم',
      notifyTitle: 'اكتمل طلبك 🎉',
      notifyBody: 'تم إكمال طلبك: ${order['itemTitle'] ?? ''}. شاركنا تقييمك من صفحة طلباتي',
    );
  }

  Future<bool> changeAppointment(Map<String, dynamic> order, DateTime date) {
    return _updateOrder(
      order,
      {'appointmentAt': Timestamp.fromDate(date)},
      'تم تعديل الموعد',
      notifyTitle: 'تم تعديل موعدك',
      notifyBody: '${order['itemTitle'] ?? ''}: الموعد الجديد ${ProviderFormat.appointment(date)}',
      notifyExtra: {'eventAt': Timestamp.fromDate(date)},
    );
  }

  Future<void> openWhatsapp(Map<String, dynamic> order) async {
    final phone = (order['studentPhone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      Get.snackbar('تنبيه', 'لا يوجد رقم واتساب لهذا الطالب');
      return;
    }

    final opened = await launchUrl(
      Uri.parse('https://wa.me/$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) Get.snackbar('خطأ', 'تعذر فتح واتساب');
  }

  // زر "إعادة المحاولة" بشاشة الخطأ
  void retry() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    errorMessage.value = '';
    isLoading.value = true;
    onInit();
  }
}
