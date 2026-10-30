import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class CourseDetailsController extends GetxController {
  final String courseId;

  CourseDetailsController(this.courseId);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];
  StreamSubscription? _providerSubscription;

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final course = <String, dynamic>{}.obs;
  final provider = <String, dynamic>{}.obs;
  final student = <String, dynamic>{}.obs;
  final reviews = <Map<String, dynamic>>[].obs;
  final myOrder = Rxn<Map<String, dynamic>>();
  final isFavorite = false.obs;
  final expandedModule = (-1).obs;

  static const Map<String, String> attendanceModes = {
    'in_person': 'وجاهي بالقاعة',
    'online': 'أونلاين عن بعد',
    'hybrid': 'مدمج (وجاهي + أونلاين)',
  };

  static const List<String> _months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  String text(String key) => (course[key] ?? '').toString();

  num get originalPrice => course['originalPrice'] ?? 0;

  num get price => course['discountedPrice'] ?? originalPrice;

  num get savedAmount => originalPrice - price;

  int get discountPercent => originalPrice == 0 ? 0 : (savedAmount / originalPrice * 100).round();

  int get seatsLeft {
    final num maxSeats = course['maxSeats'] ?? 0;
    final num booked = course['bookedSeats'] ?? 0;
    return maxSeats == 0 ? -1 : (maxSeats - booked).toInt();
  }

  List<Map<String, dynamic>> listOf(String key) => ((course[key] ?? []) as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  List<String> get tags {
    final list = ((course['tags'] ?? []) as List).map((item) => item.toString()).toList();
    if (list.isEmpty && (course['hasAccreditedCertificate'] ?? false)) list.add('شهادة مهنية معتمدة');
    return list;
  }

  String get startDateText {
    final value = course['startDate'];
    if (value is! Timestamp) return '';
    final date = value.toDate();
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  String get orderStatusText {
    switch (myOrder.value?['orderStatus']) {
      case 'pending':
        return 'بانتظار تأكيد المركز';
      case 'confirmed':
        return 'تم تأكيد حجزك ✓';
      case 'completed':
        return 'أتممت هذه الدورة ✓';
      default:
        return '';
    }
  }

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();

    _subscriptions.add(_db.collection('courses').doc(courseId).snapshots().listen((doc) {
      course.value = doc.data() ?? {};
      isLoading.value = false;
      _listenToProvider((course['providerId'] ?? '').toString());
    }, onError: _handleError));

    _subscriptions.add(_db
        .collection('reviews')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .listen((result) {
      final list = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
      reviews.value = list;
    }, onError: (Object e) => debugPrint('CourseDetailsController: $e')));

    _subscriptions.add(_db
        .collection('orders')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      myOrder.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList()
          .firstWhereOrNull((order) => order['courseId'] == courseId && order['orderStatus'] != 'canceled');
    }, onError: (Object e) => debugPrint('CourseDetailsController: $e')));

    _subscriptions.add(_db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      student.value = doc.data() ?? {};
    }, onError: (Object e) => debugPrint('CourseDetailsController: $e')));

    _subscriptions.add(_db
        .collection('favorites')
        .doc('${currentStudentId}_$courseId')
        .snapshots()
        .listen((doc) => isFavorite.value = doc.exists,
        onError: (Object e) => debugPrint('CourseDetailsController: $e')));
  }

  void _listenToProvider(String providerId) {
    if (providerId.isEmpty || provider['id'] == providerId) return;

    _providerSubscription?.cancel();
    _providerSubscription = _db.collection('serviceProviders').doc(providerId).snapshots().listen((doc) {
      provider.value = {...?doc.data(), 'id': doc.id};
    }, onError: (Object e) => debugPrint('CourseDetailsController: $e'));
  }

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

  void _handleError(Object error) {
    debugPrint('CourseDetailsController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل بيانات الدورة';
    isLoading.value = false;
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _providerSubscription?.cancel();
    super.onClose();
  }

  void toggleModule(int index) => expandedModule.value = expandedModule.value == index ? -1 : index;

  Future<void> toggleFavorite() async {
    final ref = _db.collection('favorites').doc('${currentStudentId}_$courseId');

    try {
      if (isFavorite.value) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': courseId,
          'targetType': 'course',
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('CourseDetailsController: $e');
      Get.snackbar('خطأ', 'لم يتم حفظ التغيير، حاول مرة أخرى');
    }
  }

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