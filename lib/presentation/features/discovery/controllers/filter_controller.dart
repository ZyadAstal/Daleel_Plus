import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../state/base_state_controller.dart';
import '../screens/filtered_results_screen.dart';

class FilterController extends BaseStateController {
  // 1. الفئات الرئيسية
  var selectedCategory = 'الكل'.obs;
  final List<String> categories = [
    'الكل',
    '🎓 دورات وتطوير مهني',
    '💼 وظائف وتدريب عملي',
    '🖨️ أماكن طباعة وتصوير',
    '👨‍🏫 المدرسون الخصوصيون',
  ];

  // 2. السعر والطريقة
  var minPrice = 0.0.obs;
  var maxPrice = 1000.0.obs;
  var selectedAttendanceModes = <String>[].obs;

  // 3. المواقع والتقييم
  var availableLocations = <String>[].obs;
  var selectedLocations = <String>[].obs;
  var isLoadingLocations = false.obs;
  var minRating = 0.0.obs;

  // 4. الميزات الإضافية
  var hasCertifiedCertificate = false.obs;
  var hasStudentDiscount = false.obs;
  var hasLimitedSeats = false.obs;

  // 5. قائمة النتائج الديناميكية المجلوبة من Firestore
  var filteredResults = <Map<String, dynamic>>[].obs;
  var isFiltering = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocationsFromFirebase();
    applyDynamicFiltering();
  }

  // جلب المواقع المتاحة من Firestore
  Future<void> fetchLocationsFromFirebase() async {
    await safeExecute(() async {
      isLoadingLocations.value = true;
      Set<String> locationsSet = {};
      List<String> collections = [
        'courses',
        'jobs',
        'print_centers',
        'instructors',
      ];

      for (String col in collections) {
        var snapshot = await FirebaseFirestore.instance.collection(col).get();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          if (data['location'] != null &&
              data['location'].toString().trim().isNotEmpty) {
            locationsSet.add(data['location'].toString().trim());
          }
        }
      }

      availableLocations.assignAll(locationsSet.toList());
    });
    isLoadingLocations.value = false;
  }

  // استعلام ديناميكي بحسب مدخلات الفلترة
  void applyDynamicFiltering() async {
    await safeExecute(() async {
      isFiltering.value = true;
      List<Map<String, dynamic>> tempResults = [];

      List<String> collectionsToSearch = [];
      if (selectedCategory.value.contains('دورات')) {
        collectionsToSearch = ['courses'];
      } else if (selectedCategory.value.contains('وظائف')) {
        collectionsToSearch = ['jobs'];
      } else if (selectedCategory.value.contains('طباعة')) {
        collectionsToSearch = ['print_centers'];
      } else if (selectedCategory.value.contains('المدرسون')) {
        collectionsToSearch = ['instructors'];
      } else {
        collectionsToSearch = [
          'courses',
          'jobs',
          'print_centers',
          'instructors',
        ];
      }

      for (String col in collectionsToSearch) {
        var snapshot = await FirebaseFirestore.instance.collection(col).get();
        for (var doc in snapshot.docs) {
          var data = doc.data();

          // فلترة السعر
          double price = (data['price'] ?? 0.0).toDouble();
          if (price > 0 && (price < minPrice.value || price > maxPrice.value)) {
            continue;
          }

          // فلترة الموقع الجغرافي
          String loc = data['location'] ?? '';
          if (selectedLocations.isNotEmpty &&
              !selectedLocations.contains(loc)) {
            continue;
          }

          // فلترة التقييم
          double rating = (data['rating'] ?? 0.0).toDouble();
          if (minRating.value > 0 && rating < minRating.value) {
            continue;
          }

          tempResults.add({...data, 'collection': col, 'id': doc.id});
        }
      }

      filteredResults.assignAll(tempResults);
    });
    isFiltering.value = false;
  }

  void toggleAttendanceMode(String mode) {
    if (selectedAttendanceModes.contains(mode)) {
      selectedAttendanceModes.remove(mode);
    } else {
      selectedAttendanceModes.add(mode);
    }
    applyDynamicFiltering();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    applyDynamicFiltering();
  }

  void toggleLocation(String location) {
    if (selectedLocations.contains(location)) {
      selectedLocations.remove(location);
    } else {
      selectedLocations.add(location);
    }
    applyDynamicFiltering();
  }

  void resetFilters() {
    selectedCategory.value = 'الكل';
    minPrice.value = 0.0;
    maxPrice.value = 1000.0;
    selectedAttendanceModes.clear();
    selectedLocations.clear();
    minRating.value = 0.0;
    hasCertifiedCertificate.value = false;
    hasStudentDiscount.value = false;
    hasLimitedSeats.value = false;
    applyDynamicFiltering();
  }

  // الانتقال إلى شاشة النتائج وتمرير الاختيارات والنتائج الفعلية من Firestore
  void applyFiltersAndNavigate() {
    Get.to(
      () => FilteredResultsScreen(),
      arguments: {
        'category': selectedCategory.value,
        'minPrice': minPrice.value,
        'maxPrice': maxPrice.value,
        'attendanceModes': selectedAttendanceModes.toList(),
        'locations': selectedLocations.toList(),
        'minRating': minRating.value,
        'results': filteredResults.toList(),
      },
    );
  }
}
