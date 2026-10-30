import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

String get currentStudentId => FirebaseAuth.instance.currentUser!.uid;

enum PrintFilter { all, research, engineering }

enum PrintSort { rating, price }

class PrintCentersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _providers = <Map<String, dynamic>>[].obs;
  final _services = <String, Map<String, dynamic>>{}.obs;
  final favoriteIds = <String>{}.obs;

  final selectedFilter = PrintFilter.all.obs;
  final sortBy = PrintSort.rating.obs;
  final searchText = ''.obs;

  List<Map<String, dynamic>> get centers => _providers
      .map((provider) => {
    ...provider,
    'service': _services[provider['id']] ?? <String, dynamic>{},
  })
      .toList();

  bool _matchesFilter(Map<String, dynamic> center, PrintFilter filter) {
    final Map service = center['service'];
    switch (filter) {
      case PrintFilter.all:
        return true;
      case PrintFilter.research:
        return service['serviceType'] == 'research_print' ||
            service['serviceType'] == 'graduation_project';
      case PrintFilter.engineering:
        return service['largePosterPrice'] != null;
    }
  }

  int countFor(PrintFilter filter) =>
      centers.where((center) => _matchesFilter(center, filter)).length;

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  List<Map<String, dynamic>> get visibleCenters {
    final query = _normalize(searchText.value);

    final list = centers.where((center) {
      final searchable = _normalize([
        center['businessName'],
        center['headline'],
        center['city'],
        center['addressDetails'],
        center['service']['serviceTitle'],
        ...(center['service']['features'] ?? []),
      ].join(' '));

      return _matchesFilter(center, selectedFilter.value) &&
          (query.isEmpty || searchable.contains(query));
    }).toList();

    if (sortBy.value == PrintSort.price) {
      list.sort((a, b) => startPrice(a).compareTo(startPrice(b)));
    } else {
      list.sort((a, b) => rating(b).compareTo(rating(a)));
    }
    return list;
  }

  static double rating(Map<String, dynamic> center) =>
      (center['averageRating'] ?? 0).toDouble();

  static double startPrice(Map<String, dynamic> center) =>
      (center['service']['bwPagePrice'] ?? 0).toDouble();

  int get averagePrepMinutes {
    final times = centers
        .map((center) => (center['service']['prepMinutes'] ?? 0) as num)
        .where((minutes) => minutes > 0)
        .toList();
    if (times.isEmpty) return 0;
    return (times.reduce((a, b) => a + b) / times.length).round();
  }

  int get maxStudentDiscount => centers
      .map((center) => ((center['service']['studentDiscountPercent'] ?? 0) as num).toInt())
      .fold(0, (max, value) => value > max ? value : max);

  @override
  void onInit() {
    super.onInit();
    _listenToProviders();
    _listenToServices();
    _listenToFavorites();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('PrintCentersController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToProviders() {
    final subscription = _db
        .collection('serviceProviders')
        .where('providerType', isEqualTo: 'printing')
        .snapshots()
        .listen((result) {
      _providers.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToServices() {
    final subscription = _db.collection('printServices').snapshots().listen((result) {
      _services.value = {
        for (final doc in result.docs) (doc.data()['providerId'] ?? '').toString(): doc.data(),
      };
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToFavorites() {
    final subscription = _db
        .collection('favorites')
        .where('studentId', isEqualTo: currentStudentId)
        .snapshots()
        .listen((result) {
      favoriteIds.value = result.docs
          .map((doc) => doc.data())
          .where((data) => data['targetType'] == 'printshop')
          .map((data) => data['targetId'].toString())
          .toSet();
    }, onError: (Object e) => debugPrint('PrintCentersController: $e'));

    _subscriptions.add(subscription);
  }

  void changeFilter(PrintFilter filter) => selectedFilter.value = filter;

  void changeSort(PrintSort sort) => sortBy.value = sort;

  void changeSearch(String value) => searchText.value = value;

  Future<void> toggleFavorite(String centerId) async {
    final docId = '${currentStudentId}_$centerId';
    final ref = _db.collection('favorites').doc(docId);

    try {
      if (favoriteIds.contains(centerId)) {
        await ref.delete();
      } else {
        await ref.set({
          'studentId': currentStudentId,
          'targetId': centerId,
          'targetType': 'printshop',
          'savedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('PrintCentersController: $e');
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