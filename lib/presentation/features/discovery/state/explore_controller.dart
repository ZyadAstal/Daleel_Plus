import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum ExploreSection { all, courses, jobs, printing, tutors }

class ExploreController extends GetxController {
  final ExploreSection initialSection;

  ExploreController({this.initialSection = ExploreSection.all});

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subscriptions = [];

  final isLoading = true.obs;
  final errorMessage = ''.obs;

  final _courses = <Map<String, dynamic>>[].obs;
  final _jobs = <Map<String, dynamic>>[].obs;
  final _providers = <Map<String, dynamic>>[].obs;
  final _printServices = <String, Map<String, dynamic>>{}.obs;

  final section = ExploreSection.all.obs;
  final searchText = ''.obs;
  final courseCategory = ''.obs;
  final jobType = ''.obs;
  final tutorSubject = ''.obs;

  static const Map<ExploreSection, String> sectionNames = {
    ExploreSection.all: 'الكل',
    ExploreSection.courses: '🎓 دورات وتطوير مهني',
    ExploreSection.jobs: '💼 وظائف وتدريب عملي',
    ExploreSection.printing: '🖨️ أماكن طباعة',
    ExploreSection.tutors: '👨‍🏫 مدرسون خصوصيون',
  };

  bool shows(ExploreSection value) =>
      section.value == ExploreSection.all || section.value == value;

  int get _limit => section.value == ExploreSection.all ? 2 : 100;

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .trim();

  bool _matchesSearch(List<dynamic> fields) {
    final query = _normalize(searchText.value);
    if (query.isEmpty) return true;
    return _normalize(fields.join(' ')).contains(query);
  }

  static List<String> _distinct(Iterable<dynamic> values) =>
      values.map((value) => (value ?? '').toString()).where((value) => value.isNotEmpty).toSet().toList();

  List<String> get courseCategories => _distinct(_courses.map((course) => course['categorySubtag']));

  List<String> get jobTypes => _distinct(_jobs.map((job) => job['jobTypeLabel']));

  List<String> get tutorSubjects => _distinct(tutors.expand((tutor) => subjectsOf(tutor)));

  List<Map<String, dynamic>> get tutors =>
      _providers.where((provider) => provider['providerType'] == 'tutor').toList();

  static List<String> subjectsOf(Map<String, dynamic> tutor) =>
      ((tutor['subjects'] ?? []) as List).map((subject) => (subject['name'] ?? '').toString()).toList();

  List<Map<String, dynamic>> get visibleCourses {
    final list = _courses
        .map((course) => {...course, 'providerName': providerName((course['providerId'] ?? '').toString())})
        .where((course) {
      final category = (course['categorySubtag'] ?? '').toString();
      return (courseCategory.value.isEmpty || category == courseCategory.value) &&
          _matchesSearch([course['title'], course['description'], category, course['providerName']]);
    }).toList();
    list.sort((a, b) => rating(b).compareTo(rating(a)));
    return list.take(_limit).toList();
  }

  List<Map<String, dynamic>> get visibleJobs {
    final list = _jobs.where((job) {
      return (jobType.value.isEmpty || job['jobTypeLabel'] == jobType.value) &&
          _matchesSearch([job['title'], job['companyName'], job['location'], job['jobTypeLabel']]);
    }).toList();
    list.sort((a, b) => _date(b['createdAt']).compareTo(_date(a['createdAt'])));
    return list.take(_limit).toList();
  }

  List<Map<String, dynamic>> get visiblePrintCenters {
    final list = _providers
        .where((provider) => provider['providerType'] == 'printing')
        .map((center) => {...center, 'service': _printServices[center['id']] ?? <String, dynamic>{}})
        .where((center) => _matchesSearch([center['businessName'], center['addressDetails'], center['city']]))
        .toList();
    list.sort((a, b) => rating(b).compareTo(rating(a)));
    return list.take(section.value == ExploreSection.all ? 1 : 100).toList();
  }

  List<Map<String, dynamic>> get visibleTutors {
    final list = tutors.where((tutor) {
      final subjects = subjectsOf(tutor);
      return (tutorSubject.value.isEmpty || subjects.contains(tutorSubject.value)) &&
          _matchesSearch([tutor['businessName'], tutor['headline'], ...subjects]);
    }).toList();
    list.sort((a, b) => rating(b).compareTo(rating(a)));
    return list.take(_limit).toList();
  }

  int get jobsCount => _jobs.length;

  double get lowestPagePrice {
    final prices = _printServices.values
        .map((service) => ((service['bwPagePrice'] ?? 0) as num).toDouble())
        .where((price) => price > 0)
        .toList();
    if (prices.isEmpty) return 0;
    prices.sort();
    return prices.first;
  }

  bool get hasNoResults =>
      (!shows(ExploreSection.courses) || visibleCourses.isEmpty) &&
          (!shows(ExploreSection.jobs) || visibleJobs.isEmpty) &&
          (!shows(ExploreSection.printing) || visiblePrintCenters.isEmpty) &&
          (!shows(ExploreSection.tutors) || visibleTutors.isEmpty);

  String providerName(String providerId) {
    final provider = _providers.firstWhereOrNull((p) => p['id'] == providerId);
    return (provider?['businessName'] ?? '').toString();
  }

  static double rating(Map<String, dynamic> item) => ((item['averageRating'] ?? 0) as num).toDouble();

  static String ratingText(double value) {
    final text = value.toStringAsFixed(2);
    return text.endsWith('0') ? text.substring(0, text.length - 1) : text;
  }

  static DateTime _date(dynamic value) => value is Timestamp ? value.toDate() : DateTime(2000);

  static int daysLeft(dynamic value) {
    if (value is! Timestamp) return 0;
    final days = value.toDate().difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  static String money(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();
    section.value = initialSection;
    _listenToCourses();
    _listenToJobs();
    _listenToProviders();
    _listenToPrintServices();
  }

  @override
  void onClose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.onClose();
  }

  void _handleError(Object error) {
    debugPrint('ExploreController: $error');
    errorMessage.value = 'حدث خطأ أثناء تحميل البيانات';
    isLoading.value = false;
  }

  void _listenToCourses() {
    final subscription = _db
        .collection('courses')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((result) {
      _courses.value = result.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .where((course) => course['serviceType'] != 'private_lesson')
          .toList();
      isLoading.value = false;
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToJobs() {
    final subscription = _db
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .listen((result) {
      _jobs.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToProviders() {
    final subscription = _db.collection('serviceProviders').snapshots().listen((result) {
      _providers.value = result.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void _listenToPrintServices() {
    final subscription = _db.collection('printServices').snapshots().listen((result) {
      _printServices.value = {
        for (final doc in result.docs) (doc.data()['providerId'] ?? '').toString(): doc.data(),
      };
    }, onError: _handleError);

    _subscriptions.add(subscription);
  }

  void changeSection(ExploreSection value) => section.value = value;

  void changeSearch(String value) => searchText.value = value;

  void _toggle(RxString selected, String value) =>
      selected.value = selected.value == value ? '' : value;

  void changeCourseCategory(String value) => _toggle(courseCategory, value);

  void changeJobType(String value) => _toggle(jobType, value);

  void changeTutorSubject(String value) => _toggle(tutorSubject, value);

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