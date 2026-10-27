import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../../shared/constants/app_colors.dart';
import 'filter_screen.dart';

class HomeScreen extends StatelessWidget {
  final String? targetUid;

  HomeScreen({Key? key, this.targetUid}) : super(key: key);

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    if (targetUid != null &&
        targetUid!.isNotEmpty &&
        targetUid != controller.currentUid.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchUserDataByUid(targetUid!);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSubdued,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.userName.value == 'مرحباً بزائر'
                              ? 'مرحباً بزائر'
                              : 'مرحباً بك ${controller.userName.value} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => controller.userUniversity.value.isNotEmpty
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.school_outlined,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.userUniversity.value,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textHint,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Badge(
                          label: Text('2'),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textHint,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onPressed: () => Get.to(() => FilterScreen()),
                icon: const Icon(Icons.search, color: AppColors.primary),
                label: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ابحث عن دورة، مدرس، مطبعة، أو فرصة...',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'أسبوع التوفير الطلابي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        const Text(
                          'ينتهي خلال 3 أيام',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'خصم 50% على طباعة المشاريع والدورات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A00E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'تفعيل العرض',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'الخدمات الأكاديمية الرئيسية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildServiceCard(
                    'دورات وتعليم',
                    '120+ دورة معتمدة',
                    Icons.school,
                    Colors.green,
                  ),
                  _buildServiceCard(
                    'وظائف وتدريب',
                    '45 فرصة شاغرة',
                    Icons.work_outline,
                    Colors.teal,
                  ),
                  _buildServiceCard(
                    'مراكز الطباعة',
                    '18 مركز طباعة',
                    Icons.print,
                    Colors.orange,
                  ),
                  _buildServiceCard(
                    'مدرسون خصوصيون',
                    '80+ مدرس معتمد',
                    Icons.people_outline,
                    Colors.indigo,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- قسم الدورات التدريبية المميزة ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'دورات تدريبية مميزة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'الكل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 225,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.coursesList.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا يوجد شيء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.coursesList.length,
                    itemBuilder: (context, index) {
                      var course = controller.coursesList[index];
                      return Container(
                        width: 170,
                        margin: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      course['category_subtag'] ?? 'تدريب',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Text(
                                      course['title'] ?? 'دورة',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    Text(
                                      '${course['discounted_price'] ?? course['original_price'] ?? 0} شيكل',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),

              // --- قسم أحدث فرص التدريب والوظائف ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أحدث فرص التدريب والوظائف',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.opportunitiesList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'لا يوجد شيء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.opportunitiesList.length,
                  itemBuilder: (context, index) {
                    var opp = controller.opportunitiesList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opp['title'] ?? 'فرصة عمل',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  opp['stipend_salary'] != null
                                      ? 'مكافأة ${opp['stipend_salary']} شيكل'
                                      : 'بدون مكافأة',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              minimumSize: const Size(60, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'تقديم',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 24),

              // --- قسم أفضل المدرسين ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أفضل المدرسين',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.tutorsList.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا يوجد شيء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.tutorsList.length,
                    itemBuilder: (context, index) {
                      var tutor = controller.tutorsList[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.indigo,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tutor['business_name'] ??
                                  tutor['fullname'] ??
                                  'مدرس',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tutor['hourly_rate'] ?? 40} شيكل/ساعة',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
