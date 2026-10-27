import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../state/base_state_controller.dart';
import '../../../../data/models/home_data_models.dart';
import '../../../../data/models/explore_data_models.dart';

class ExploreController extends BaseStateController {
  // الفلتر الرئيسي للأقسام الخمسة
  var selectedFilterIndex = 0.obs;

  // الفلتر الفرعي الخاص بقسم الوظائف والتدريب العملي
  var selectedJobSubFilter = 'الكل'.obs;

  final List<String> categories = [
    'الكل',
    '🎓 دورات وتطوير مهني',
    '💼 وظائف وتدريب عملي',
    '🖨️ أماكن طباعة وتصوير',
    '👨‍🏫 المدرسون الخصوصيون',
  ];

  final List<String> jobSubFilters = [
    'الكل',
    'تدريب صيفي',
    'وظائف دوام جزئي',
    'وظائف دوام كلي',
    'فرص تطوعية',
  ];

  void changeFilter(int index) {
    selectedFilterIndex.value = index;
  }

  void changeJobSubFilter(String subFilter) {
    selectedJobSubFilter.value = subFilter;
  }

  bool shouldShowCourses() =>
      selectedFilterIndex.value == 0 || selectedFilterIndex.value == 1;
  bool shouldShowJobs() =>
      selectedFilterIndex.value == 0 || selectedFilterIndex.value == 2;
  bool shouldShowPrintCenters() =>
      selectedFilterIndex.value == 0 || selectedFilterIndex.value == 3;
  bool shouldShowInstructors() =>
      selectedFilterIndex.value == 0 || selectedFilterIndex.value == 4;

  Stream<List<CourseModel>> getExploreCoursesStream() {
    return FirebaseFirestore.instance
        .collection('courses')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // جلب الوظائف مع إمكانية التصفية حسب الفلتر الفرعي
  Stream<List<JobModel>> getExploreJobsStream() {
    Query query = FirebaseFirestore.instance.collection('jobs');

    // إذا تم اختيار تصنيف فرعي غير "الكل"، نقوم بعمل فلترة من قاعدة البيانات
    return query.snapshots().map((snapshot) {
      var jobs = snapshot.docs
          .map(
            (doc) =>
                JobModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      if (selectedJobSubFilter.value != 'الكل') {
        jobs = jobs
            .where((job) => job.type == selectedJobSubFilter.value)
            .toList();
      }
      return jobs;
    });
  }

  Stream<List<InstructorModel>> getExploreInstructorsStream() {
    return FirebaseFirestore.instance
        .collection('instructors')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InstructorModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<PrintCenterModel>> getExplorePrintCentersStream() {
    return FirebaseFirestore.instance
        .collection('print_centers')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrintCenterModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
