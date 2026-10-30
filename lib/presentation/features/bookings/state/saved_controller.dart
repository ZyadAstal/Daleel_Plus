import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../printing/state/print_centers_controller.dart';

class SavedController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _favorites = <Map<String, dynamic>>[].obs;
  final _courses = <String, Map<String, dynamic>>{}.obs;
  final _jobs = <String, Map<String, dynamic>>{}.obs;
  final _providers = <String, Map<String, dynamic>>{}.obs;
  final _printServices = <String, Map<String, dynamic>>{}.obs;

  final type = ''.obs;
  final searchText = ''.obs;
  final newestFirst = true.obs;

  static const Map<String, String> typeNames = {
    '': 'الكل',
    'course': 'دورات',
    'job': 'وظائف ومنح',
    'printshop': 'مراكز طباعة',
    'tutor': 'مدرسون',
    'academy': 'أكاديميات',
  };

  Map<String, dynamic> dataOf(Map<String, dynamic> favorite) {
    final id = (favorite['targetId'] ?? '').toString();
    switch (favorite['targetType']) {
      case 'course':
        return _courses[id] ?? {};
      case 'job':
        return _jobs[id] ?? {};
      case 'printshop':
        final provider = _providers[id];
        if (provider == null) return {};
        return {...provider, 'service': _printServices[id] ?? <String, dynamic>{}};
      default:
        return _providers[id] ?? {};
    }
  }

  String providerName(String providerId) => (_providers[providerId]?['businessName'] ?? '').toString();

  List<Map<String, dynamic>> get _known => _favorites.where((item) => dataOf(item).isNotEmpty).toList();

  int countFor(String value) => value.isEmpty ? _known.length : _known.where((item) => item['targetType'] == value).length;

  List<Map<String, dynamic>> get items {
    final query = searchText.value.trim().toLowerCase();
    final list = _known.where((item) {
      final data = dataOf(item);
      final text = [data['title'], data['businessName'], data['companyName']].join(' ').toLowerCase();
      return (type.value.isEmpty || item['targetType'] == type.value) && (query.isEmpty || text.contains(query));
    }).toList();
    list.sort((a, b) {
      final result = _date(a['savedAt']).compareTo(_date(b['savedAt']));
      return newestFirst.value ? -result : result;
    });
    return list;
  }

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

  static String savedAgo(dynamic value) {
    if (value is! Timestamp) return '';
    final days = DateTime.now().difference(value.toDate()).inDays;
    if (days == 0) return 'تم الحفظ اليوم';
    if (days == 1) return 'تم الحفظ بالأمس';
    if (days < 7) return 'تم الحفظ منذ $days أيام';
    return 'تم الحفظ قبل ${days ~/ 7} أسبوع';
  }

  @override
  void onInit() {
    super.onInit();
    _subscriptions.add(_db
        .collection('favorites')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      _favorites.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: (Object error) {
      debugPrint('SavedController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل المحفوظات';
      isLoading.value = false;
    }));

    _listenMap(_db.collection('courses'), _courses);
    _listenMap(_db.collection('jobs'), _jobs);
    _listenMap(_db.collection('serviceProviders'), _providers);
    _subscriptions.add(_db.collection('printServices').snapshots().listen((result) {
      _printServices.value = {
        for (final doc in result.docs) (doc.data()['providerId'] ?? '').toString(): doc.data(),
      };
    }, onError: (Object e) => debugPrint('SavedController: $e')));
  }

  void _listenMap(CollectionReference<Map<String, dynamic>> source, RxMap<String, Map<String, dynamic>> target) {
    _subscriptions.add(source.snapshots().listen((result) {
      target.value = {for (final doc in result.docs) doc.id: {...doc.data(), 'id': doc.id}};
    }, onError: (Object e) => debugPrint('SavedController: $e')));
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void changeType(String value) => type.value = value;

  void changeSearch(String value) => searchText.value = value;

  void toggleSort() => newestFirst.toggle();

  Future<void> remove(Map<String, dynamic> favorite) async {
    final data = Map<String, dynamic>.from(favorite)..remove('id');
    final ref = _db.collection('favorites').doc(favorite['id']);
    try {
      await ref.delete();
      Get.snackbar(
        'تمت إزالة العنصر من المفضلة',
        '',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () {
            ref.set(data);
            Get.closeCurrentSnackbar();
          },
          child: const Text('تراجع', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      );
    } catch (e) {
      debugPrint('SavedController: $e');
      Get.snackbar('خطأ', 'لم تتم الإزالة، حاول مرة أخرى');
    }
  }

  Future<void> clearAll() async {
    try {
      final batch = _db.batch();
      for (final item in _favorites) {
        batch.delete(_db.collection('favorites').doc(item['id']));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('SavedController: $e');
      Get.snackbar('خطأ', 'لم يتم إفراغ المحفوظات');
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