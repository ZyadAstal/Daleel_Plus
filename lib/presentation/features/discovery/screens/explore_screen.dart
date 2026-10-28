import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../state/explore_controller.dart';
import 'search_screen.dart'; // شاشة البحث السريع
import 'filter_screen.dart'; // شاشة تصفية وتخصيص النتائج
import '../../../../data/models/home_data_models.dart';
import '../../../../data/models/explore_data_models.dart';
import '../../../shared/constants/app_colors.dart';

class ExploreScreen extends StatelessWidget {
  ExploreScreen({Key? key}) : super(key: key);

  final ExploreController controller = Get.put(ExploreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubdued,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(), // شريط البحث وزر الفلترة الجانبي
              const SizedBox(height: 16),
              _buildCategoriesFilterBar(),
              const SizedBox(height: 20),

              // الأقسام الديناميكية المرتبطة بـ Firebase
              Obx(() {
                return Column(
                  children: [
                    if (controller.shouldShowCourses()) ...[
                      _buildSectionTitle('دورات وتطوير مهني', 'عرض الكل'),
                      const SizedBox(height: 12),
                      _buildCoursesList(),
                      const SizedBox(height: 20),
                    ],

                    if (controller.shouldShowJobs()) ...[
                      _buildSectionTitle('وظائف وتدريب عملي', 'عرض الكل'),
                      const SizedBox(height: 8),
                      _buildJobSubFiltersBar(),
                      const SizedBox(height: 12),
                      _buildJobsList(),
                      const SizedBox(height: 20),
                    ],

                    if (controller.shouldShowPrintCenters()) ...[
                      _buildSectionTitle(
                        'أماكن طباعة وتصوير معتمدة',
                        'عرض الكل',
                      ),
                      const SizedBox(height: 12),
                      _buildPrintCentersList(),
                      const SizedBox(height: 20),
                    ],

                    if (controller.shouldShowInstructors()) ...[
                      _buildSectionTitle(
                        'مدرسون خصوصيون معتمدون',
                        'تصفح المعلمين',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructorsList(),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'استكشف الأقسام الأكاديمية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'دليلك المتكامل لجميع الخدمات والفرص الجامعية',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.explore, color: AppColors.primary),
        ),
      ],
    );
  }

  // شريط البحث محدد بدقة:
  // - الضغط على مربع البحث يفتح SearchScreen
  // - الضغط على الزر الجانبي (Icons.tune) يفتح FilterScreen
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Get.to(() => SearchScreen());
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن دورة، مساق، وظيفة، أو مركز طباعة...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    fontFamily: 'Cairo',
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.tune, color: AppColors.textPrimary),
            onPressed: () {
              // فتح شاشة تصفية وتخصيص النتائج عند الضغط على الزر الجانبي
              Get.to(() => FilterScreen());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesFilterBar() {
    final List<Map<String, dynamic>> categories = [
      {'title': 'الكل', 'icon': null},
      {'title': 'دورات وتطوير مهني', 'icon': Icons.school_outlined},
      {'title': 'وظائف وتدريب عملي', 'icon': Icons.work_outline},
      {'title': 'أماكن طباعة وتصوير', 'icon': Icons.print_outlined},
      {'title': 'المدرسون الخصوصيون', 'icon': Icons.person_outline},
    ];

    return SizedBox(
      height: 45,
      child: Obx(() {
        final selectedIdx = controller.selectedFilterIndex.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIdx == index;
            return GestureDetector(
              onTap: () => controller.changeFilter(index),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    if (categories[index]['icon'] != null) ...[
                      Icon(
                        categories[index]['icon'],
                        size: 16,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      categories[index]['title'],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildJobSubFiltersBar() {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final currentSubFilter = controller.selectedJobSubFilter.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.jobSubFilters.length,
          itemBuilder: (context, index) {
            final filterName = controller.jobSubFilters[index];
            final isSelected = currentSubFilter == filterName;
            return GestureDetector(
              onTap: () => controller.changeJobSubFilter(filterName),
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  filterName,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          actionText,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList() {
    return StreamBuilder<List<CourseModel>>(
      stream: controller.getExploreCoursesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(
            child: Text(
              'لا توجد دورات',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          );
        final courses = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${course.academy} • ${course.price} شيكل',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsList() {
    return StreamBuilder<List<JobModel>>(
      stream: controller.getExploreJobsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(
            child: Text(
              'لا توجد وظائف مطابقة لهذا الفلتر',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          );
        final jobs = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '${job.company} • ${job.type}',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrintCentersList() {
    return StreamBuilder<List<PrintCenterModel>>(
      stream: controller.getExplorePrintCentersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(
            child: Text(
              'لا توجد أماكن طباعة',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          );
        final centers = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: centers.length,
          itemBuilder: (context, index) {
            final center = centers[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    center.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${center.location} • ${center.distance}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInstructorsList() {
    return StreamBuilder<List<InstructorModel>>(
      stream: controller.getExploreInstructorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const Center(
            child: Text(
              'لا يوجد مدرسون متاحون',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          );
        final instructors = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: instructors.length,
          itemBuilder: (context, index) {
            final instructor = instructors[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.surfaceSubdued,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          instructor.specialty,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
