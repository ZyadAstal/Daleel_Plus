import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../academic/screens/course_details_screen.dart';
import '../../academic/screens/job_details_screen.dart';
import '../../academic/screens/tutor_profile_screen.dart';
import '../../printing/screens/print_order_screen.dart';
import '../../printing/state/print_centers_controller.dart';
import '../../../shared/constants/app_colors.dart';

enum SearchSort { rating, priceLow, priceHigh }

class DiscoverySearchController extends GetxController {
  static DiscoverySearchController get instance => Get.isRegistered<DiscoverySearchController>()
      ? Get.find<DiscoverySearchController>()
      : Get.put(DiscoverySearchController(), permanent: true);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final searchField = TextEditingController();

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _courses = <Map<String, dynamic>>[].obs;
  final _jobs = <Map<String, dynamic>>[].obs;
  final _providers = <Map<String, dynamic>>[].obs;
  final _printServices = <String, Map<String, dynamic>>{}.obs;
  final recentSearches = <String>[].obs;
  final trending = <Map<String, dynamic>>[].obs;

  final query = ''.obs;
  final category = 'all'.obs;
  final sortBy = SearchSort.rating.obs;
  final compareIds = <String>[].obs;

  static const double maxPriceLimit = 800;
  final minPrice = 0.0.obs;
  final maxPrice = maxPriceLimit.obs;
  final modes = <String>{}.obs;
  final areas = <String>{}.obs;
  final minRating = 0.0.obs;
  final onlyCertified = false.obs;
  final onlyStudentDiscount = false.obs;
  final onlyLimitedSeats = false.obs;

  static const Map<String, String> categories = {
    'all': 'الكل',
    'course': 'دورات وتعليم',
    'printing': 'أماكن طباعة',
    'job': 'وظائف وتدريب',
    'tutor': 'مدرسون خصوصيون',
  };

  static const Map<String, String> typeLabels = {
    'course': 'دورة تدريبية',
    'tutor': 'مدرس خصوصي',
    'printing': 'خدمات طباعة ومكتبات',
    'job': 'فرص عمل وتدريب',
  };

  static const Map<String, String> modeLabels = {
    'onsite': 'وجاهي بالمقر',
    'online': 'أونلاين عن بعد',
    'hybrid': 'مختلط Hybrid',
    'delivery': 'توصيل للموقع المراد',
  };

  static const List<String> areaOptions = [
    'غزة - الرمال',
    'غزة - تل الهوى',
    'غزة - الشاطئ',
    'الجامعة الإسلامية',
    'دير البلح',
    'خانيونس',
    'جامعة الأقصى',
    'خانيونس - المواصي',
  ];

  static const Map<SearchSort, String> sortLabels = {
    SearchSort.rating: 'الأعلى تقييما',
    SearchSort.priceLow: 'الأقل سعرا',
    SearchSort.priceHigh: 'الأعلى سعرا',
  };

  static Color typeColor(String type) {
    switch (type) {
      case 'printing':
        return AppColors.secondary;
      case 'job':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  static int _daysLeft(dynamic value) {
    if (value is! Timestamp) return 99;
    final days = value.toDate().difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  static String ratingText(num value) {
    final text = value.toStringAsFixed(2);
    return text.endsWith('0') ? text.substring(0, text.length - 1) : text;
  }

  String _providerField(String providerId, String key) {
    final provider = _providers.firstWhereOrNull((p) => p['id'] == providerId);
    return (provider?[key] ?? '').toString();
  }

  static List<String> _modesFromText(String text) {
    final list = <String>[];
    if (text.contains('وجاهي')) list.add('onsite');
    if (text.contains('أونلاين') || text.contains('عن بعد') || text.contains('Remote')) list.add('online');
    if (text.contains('هجين') || text.contains('مدمج') || text.contains('Hybrid')) list.add('hybrid');
    if (list.isEmpty) list.add('onsite');
    return list;
  }

  static const Map<String, String> _attendanceModes = {
    'in_person': 'onsite',
    'online': 'online',
    'hybrid': 'hybrid',
  };

  List<Map<String, dynamic>> get allItems {
    final items = <Map<String, dynamic>>[];

    for (final course in _courses) {
      final providerId = (course['providerId'] ?? '').toString();
      final num original = course['originalPrice'] ?? 0;
      final num? discounted = course['discountedPrice'];
      final num maxSeats = course['maxSeats'] ?? 0;
      final num booked = course['bookedSeats'] ?? 0;
      items.add({
        'id': course['id'],
        'type': 'course',
        'title': course['title'] ?? '',
        'subtitle': [_providerField(providerId, 'businessName'), course['instructorName'] ?? '']
            .where((text) => text.toString().isNotEmpty)
            .join(' • '),
        'providerId': providerId,
        'providerName': _providerField(providerId, 'businessName'),
        'imageUrl': course['coverImageUrl'] ?? '',
        'price': discounted ?? original,
        'oldPrice': discounted == null ? 0 : original,
        'priceUnit': course['pricingUnit'] == 'hour' ? 'ساعة' : 'للدورة',
        'rating': course['averageRating'] ?? 0,
        'ratingsCount': course['ratingsCount'] ?? 0,
        'area': (course['area'] ?? _providerField(providerId, 'city')).toString(),
        'modes': [_attendanceModes[course['attendanceMode']] ?? 'onsite'],
        'hasCertificate': course['hasAccreditedCertificate'] ?? false,
        'hasStudentDiscount': discounted != null,
        'limitedSeats': maxSeats > 0 && maxSeats - booked <= 5,
        'badge': (course['hasAccreditedCertificate'] ?? false) ? 'دورة معتمدة' : 'دورة',
        'note': discounted == null || original == 0
            ? ''
            : 'وفر ${((original - discounted) / original * 100).round()}% لفترة محدودة 🔥',
        'raw': course,
      });
    }

    for (final provider in _providers) {
      final type = provider['providerType'];
      if (type == 'privateTutor') {
        final mode = (provider['teachingModeLabel'] ?? '').toString();
        items.add({
          'id': provider['id'],
          'type': 'tutor',
          'title': provider['businessName'] ?? '',
          'subtitle': provider['headline'] ?? '',
          'providerId': provider['id'],
          'providerName': provider['businessName'] ?? '',
          'imageUrl': provider['logoUrl'] ?? '',
          'price': provider['hourlyRate'] ?? 0,
          'oldPrice': 0,
          'priceUnit': 'ساعة',
          'rating': provider['averageRating'] ?? 0,
          'ratingsCount': provider['reviewsCount'] ?? 0,
          'area': (provider['city'] ?? '').toString(),
          'modes': _modesFromText(mode),
          'hasCertificate': provider['isVerified'] ?? false,
          'hasStudentDiscount': provider['freeTrial'] ?? false,
          'limitedSeats': false,
          'badge': (provider['isVerified'] ?? false) ? 'مدرس معتمد' : 'مدرس',
          'note': (provider['freeTrial'] ?? false) ? 'جلسة أولى تجريبية مجانا 🎁' : mode,
          'raw': provider,
        });
      } else if (type == 'printing') {
        final service = _printServices[provider['id']] ?? <String, dynamic>{};
        final num discount = service['studentDiscountPercent'] ?? 0;
        items.add({
          'id': provider['id'],
          'type': 'printing',
          'title': provider['businessName'] ?? '',
          'subtitle': (service['serviceTitle'] ?? provider['headline'] ?? '').toString(),
          'providerId': provider['id'],
          'providerName': provider['businessName'] ?? '',
          'imageUrl': provider['coverImageUrl'] ?? provider['logoUrl'] ?? '',
          'price': service['bwPagePrice'] ?? 0,
          'oldPrice': 0,
          'priceUnit': 'صفحة',
          'rating': provider['averageRating'] ?? 0,
          'ratingsCount': provider['reviewsCount'] ?? 0,
          'area': [provider['city'], provider['addressDetails']].where((t) => t != null).join(' '),
          'modes': [
            'onsite',
            if (service['deliveryFee'] != null) 'delivery',
          ],
          'hasCertificate': false,
          'hasStudentDiscount': discount > 0,
          'limitedSeats': false,
          'badge': 'طباعة فورية',
          'note': 'تسليم فوري بنفس اليوم ⚡',
          'raw': {...provider, 'service': service},
        });
      }
    }

    for (final job in _jobs) {
      final workType = (job['workTypeLabel'] ?? job['location'] ?? '').toString();
      items.add({
        'id': job['id'],
        'type': 'job',
        'title': job['title'] ?? '',
        'subtitle': job['companyName'] ?? '',
        'providerId': '',
        'providerName': job['companyName'] ?? '',
        'imageUrl': job['coverImageUrl'] ?? '',
        'price': job['monthlyReward'] ?? 0,
        'oldPrice': 0,
        'priceUnit': 'شهريا',
        'rating': 0,
        'ratingsCount': 0,
        'area': (job['location'] ?? '').toString(),
        'modes': _modesFromText(workType),
        'hasCertificate': false,
        'hasStudentDiscount': false,
        'limitedSeats': _daysLeft(job['deadline']) <= 3,
        'badge': 'فرصة عمل',
        'note': (job['jobTypeLabel'] ?? '').toString(),
        'raw': job,
      });
    }

    return items;
  }

  bool _matchesQuery(Map<String, dynamic> item) {
    final words = _normalize(query.value).split(' ').where((word) => word.isNotEmpty);
    if (words.isEmpty) return true;
    final text = _normalize(
      [item['title'], item['subtitle'], item['providerName'], item['area'], typeLabels[item['type']], item['note']]
          .join(' '),
    );
    return words.any((word) => text.contains(word));
  }

  bool _matchesFilters(Map<String, dynamic> item) {
    final num price = item['price'];
    final List itemModes = item['modes'];
    final area = _normalize(item['area'].toString());

    return (category.value == 'all' || item['type'] == category.value) &&
        (price >= minPrice.value && (maxPrice.value >= maxPriceLimit || price <= maxPrice.value)) &&
        (modes.isEmpty || itemModes.any(modes.contains)) &&
        (areas.isEmpty || areas.any((option) => area.contains(_normalize(option)))) &&
        ((item['rating'] as num) >= minRating.value) &&
        (!onlyCertified.value || item['hasCertificate'] == true) &&
        (!onlyStudentDiscount.value || item['hasStudentDiscount'] == true) &&
        (!onlyLimitedSeats.value || item['limitedSeats'] == true);
  }

  List<Map<String, dynamic>> get results {
    final list = allItems.where((item) => _matchesQuery(item) && _matchesFilters(item)).toList();

    switch (sortBy.value) {
      case SearchSort.rating:
        list.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
        break;
      case SearchSort.priceLow:
        list.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case SearchSort.priceHigh:
        list.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
    }
    return list;
  }

  List<Map<String, dynamic>> get suggestions =>
      query.value.trim().isEmpty ? [] : results.take(4).toList();

  int get activeFiltersCount =>
      (category.value == 'all' ? 0 : 1) +
          (minPrice.value > 0 || maxPrice.value < maxPriceLimit ? 1 : 0) +
          modes.length +
          areas.length +
          (minRating.value > 0 ? 1 : 0) +
          (onlyCertified.value ? 1 : 0) +
          (onlyStudentDiscount.value ? 1 : 0) +
          (onlyLimitedSeats.value ? 1 : 0);

  List<Map<String, dynamic>> get compareItems =>
      allItems.where((item) => compareIds.contains(item['id'])).toList();

  @override
  void onInit() {
    super.onInit();
    _listen(_db.collection('courses').where('isActive', isEqualTo: true), (docs) {
      _courses.value = docs.where((course) => course['serviceType'] != 'private_lesson').toList();
      isLoading.value = false;
    });
    _listen(_db.collection('jobs').where('status', isEqualTo: 'open'), (docs) => _jobs.value = docs);
    _listen(_db.collection('serviceProviders'), (docs) => _providers.value = docs);
    _listen(_db.collection('printServices'), (docs) {
      _printServices.value = {for (final doc in docs) (doc['providerId'] ?? '').toString(): doc};
    });
    _listen(_db.collection('searchStats').orderBy('count', descending: true).limit(4), (docs) {
      trending.value = docs;
    });

    final userSubscription = _db.collection('Users').doc(currentStudentId).snapshots().listen((doc) {
      recentSearches.value =
          ((doc.data()?['recentSearches'] ?? []) as List).map((item) => item.toString()).toList();
    }, onError: (Object e) => debugPrint('DiscoverySearchController: $e'));
    _subscriptions.add(userSubscription);
  }

  void _listen(Query<Map<String, dynamic>> source, void Function(List<Map<String, dynamic>>) onData) {
    final subscription = source.snapshots().listen((result) {
      onData(result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
    }, onError: (Object error) {
      debugPrint('DiscoverySearchController: $error');
      errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
      isLoading.value = false;
    });
    _subscriptions.add(subscription);
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    searchField.dispose();
    super.onClose();
  }

  void changeQuery(String value) => query.value = value;

  void useSearchTerm(String term) {
    searchField.text = term;
    query.value = term;
  }

  void clearQuery() => useSearchTerm('');

  Future<void> saveSearch() async {
    final term = query.value.trim();
    if (term.isEmpty) return;

    final list = [term, ...recentSearches.where((item) => item != term)].take(6).toList();
    final topType = results.isEmpty ? 'course' : results.first['type'];

    try {
      await _db.collection('Users').doc(currentStudentId).set({'recentSearches': list}, SetOptions(merge: true));
      await _db.collection('searchStats').doc(_normalize(term).replaceAll('/', '-')).set({
        'term': term,
        'type': topType,
        'count': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('DiscoverySearchController: $e');
    }
  }

  Future<void> removeRecent(String term) async {
    final list = recentSearches.where((item) => item != term).toList();
    await _db.collection('Users').doc(currentStudentId).set({'recentSearches': list}, SetOptions(merge: true));
  }

  Future<void> clearRecent() async {
    await _db.collection('Users').doc(currentStudentId).set({'recentSearches': []}, SetOptions(merge: true));
  }

  void changeCategory(String value) => category.value = value;

  void changeSort(SearchSort value) => sortBy.value = value;

  void changePriceRange(RangeValues values) {
    minPrice.value = values.start.roundToDouble();
    maxPrice.value = values.end.roundToDouble();
  }

  void toggleMode(String mode) => modes.contains(mode) ? modes.remove(mode) : modes.add(mode);

  void toggleArea(String area) => areas.contains(area) ? areas.remove(area) : areas.add(area);

  void changeMinRating(double value) => minRating.value = minRating.value == value ? 0 : value;

  void resetFilters() {
    category.value = 'all';
    minPrice.value = 0;
    maxPrice.value = maxPriceLimit;
    modes.clear();
    areas.clear();
    minRating.value = 0;
    onlyCertified.value = false;
    onlyStudentDiscount.value = false;
    onlyLimitedSeats.value = false;
  }

  void toggleCompare(String id) {
    if (compareIds.contains(id)) {
      compareIds.remove(id);
    } else if (compareIds.length < 2) {
      compareIds.add(id);
    } else {
      Get.snackbar('مقارنة', 'يمكنك مقارنة خدمتين فقط في نفس الوقت');
    }
  }

  static void openItem(Map<String, dynamic> item) {
    switch (item['type']) {
      case 'course':
        CourseDetailsScreen.open(item['id']);
        break;
      case 'printing':
        PrintOrderScreen.open(item['raw']);
        break;
      case 'tutor':
        TutorProfileScreen.open(item['id']);
        break;
      case 'job':
        JobDetailsScreen.open(item['id']);
        break;
    }
  }

  static String actionText(String type) {
    switch (type) {
      case 'tutor':
        return 'حجز جلسة';
      case 'printing':
        return 'طلب طباعة';
      case 'job':
        return 'تقديم فوري';
      default:
        return 'تفاصيل وحجز';
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