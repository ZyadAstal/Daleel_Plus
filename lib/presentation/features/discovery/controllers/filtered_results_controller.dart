import 'package:get/get.dart';

import '../state/base_state_controller.dart';

class FilteredResultsController extends BaseStateController {
  // الفلاتر الديناميكية المحددة من المستخدم فقط
  var activeCategory = ''.obs;
  var activeMinPrice = 0.0.obs;
  var activeMaxPrice = 1000.0.obs;
  var activeLocations = <String>[].obs;
  var activeAttendanceModes = <String>[].obs;
  var activeMinRating = 0.0.obs;

  var resultsList = <Map<String, dynamic>>[].obs;
  var comparedItems = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // استلام الخيارات والنتائج الديناميكية الممررة
    if (Get.arguments != null) {
      final args = Get.arguments;
      if (args['category'] != null && args['category'] != 'الكل') {
        activeCategory.value = args['category'];
      }
      if (args['minPrice'] != null) activeMinPrice.value = args['minPrice'];
      if (args['maxPrice'] != null) activeMaxPrice.value = args['maxPrice'];
      if (args['locations'] != null)
        activeLocations.assignAll(List<String>.from(args['locations']));
      if (args['attendanceModes'] != null)
        activeAttendanceModes.assignAll(
          List<String>.from(args['attendanceModes']),
        );
      if (args['minRating'] != null) activeMinRating.value = args['minRating'];

      if (args['results'] != null) {
        resultsList.assignAll(List<Map<String, dynamic>>.from(args['results']));
      }
    }
  }

  void removeCategoryFilter() => activeCategory.value = '';
  void removeLocationFilter(String loc) => activeLocations.remove(loc);
  void removeAttendanceFilter(String mode) =>
      activeAttendanceModes.remove(mode);
  void removePriceFilter() {
    activeMinPrice.value = 0.0;
    activeMaxPrice.value = 1000.0;
  }

  void removeRatingFilter() => activeMinRating.value = 0.0;

  void clearAllFilters() {
    activeCategory.value = '';
    activeLocations.clear();
    activeAttendanceModes.clear();
    activeMinPrice.value = 0.0;
    activeMaxPrice.value = 1000.0;
    activeMinRating.value = 0.0;
  }

  void toggleCompareItem(String itemId) {
    if (comparedItems.contains(itemId)) {
      comparedItems.remove(itemId);
    } else {
      if (comparedItems.length < 2) {
        comparedItems.add(itemId);
      } else {
        Get.snackbar(
          'المقارنة',
          'يمكنك مقارنة خدمتين كحد أقصى في نفس الوقت',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
