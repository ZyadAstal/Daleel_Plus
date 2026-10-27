import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// ✅ استيراد ملف الخيارات الذي يولده FlutterFire
import 'firebase_options.dart';

import 'presentation/features/navigation/screens/main_layout_screen.dart';
import 'presentation/shared/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String initialUid = 'jVqNtoSxQTN1igw5okW1MwXGltp2';

    return GetMaterialApp(
      title: 'Daleel Plus',
      debugShowCheckedModeBanner: false,
      textDirection: TextDirection.rtl,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.surfaceSubdued,
        fontFamily: 'Cairo',
      ),
      home: MainLayoutScreen(targetUid: initialUid),
    );
  }
}
