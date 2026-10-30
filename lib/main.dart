import 'package:daleel_plus/presentation/features/academic/screens/execute_code_add20Courses.dart';
import 'package:daleel_plus/presentation/features/academic/screens/provider_details_screen.dart';

import 'data/repositories/auth_repository.dart';
import 'presentation/features/auth/screens/auth_gate.dart';
import 'presentation/features/academic/screens/course_details_screen.dart';
import 'presentation/features/academic/screens/opportunities_screen.dart';
import 'presentation/features/academic/screens/private_tutors_screen.dart';
import 'presentation/features/academic/screens/tutor_profile_screen.dart';
import 'presentation/features/profile/screens/edit_profile_screen.dart';
import 'presentation/features/profile/screens/user_profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'presentation/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final auth = FirebaseAuthRepository();
  await auth.restoreSession();
  Get.put<AuthRepository>(auth, permanent: true);
  runApp(const DaleelApp());
}

class DaleelApp extends StatelessWidget {
  const DaleelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Daleel Plus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      initialRoute: 'provider-details',
      getPages: [
        GetPage(name: '/provider-details', page: () => const ProviderDetailsScreen()),
        GetPage(name: '/course-details', page: () => const CourseDetailsScreen()),
        GetPage(name: '/private-tutors', page: () => const PrivateTutorsScreen()),
        GetPage(name: '/tutor-profile', page: () => const TutorProfileScreen()),
        GetPage(name: '/opportunities', page: () => const OpportunitiesScreen()),
        GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),
        GetPage(name: '/user-profile', page: () => const UserProfileScreen()),
        GetPage(name: '/auth-gate', page: () => const AuthGate()),
        GetPage(name: '/SeedCourses', page: () => const CoursesAdminScreen()),
      ],
    );
  }
}
