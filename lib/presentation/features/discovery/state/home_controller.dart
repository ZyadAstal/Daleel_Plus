import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../state/base_state_controller.dart';

class HomeController extends BaseStateController {
  var currentUid = ''.obs;
  var userName = 'جاري التحميل...'.obs;
  var userUniversity = ''.obs;
  var isLoading = false.obs;

  var coursesList = <Map<String, dynamic>>[].obs;
  var opportunitiesList = <Map<String, dynamic>>[].obs;
  var tutorsList = <Map<String, dynamic>>[].obs;
  var printServicesList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      fetchUserDataByUid(user.uid);
    } else {
      fetchUserDataByUid('jVqNtoSxQTN1igw5okW1MwXGltp2');
    }
  }

  Future<void> fetchUserDataByUid(String uid) async {
    currentUid.value = uid;

    await safeExecute(() async {
      isLoading.value = true;

      if (uid.isEmpty) {
        userName.value = 'مرحباً بزائر';
        userUniversity.value = '';
        isLoading.value = false;
        return;
      }

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (!userDoc.exists || userDoc.data() == null) {
          userName.value = 'مرحباً بزائر';
          userUniversity.value = '';
          isLoading.value = false;
          return;
        }

        var userData = userDoc.data() as Map<String, dynamic>;
        userName.value = userData['fullname'] ?? '';

        QuerySnapshot studentProfileSnap = await FirebaseFirestore.instance
            .collection('Student_Profiles')
            .where('user_id', isEqualTo: uid)
            .limit(1)
            .get()
            .timeout(const Duration(seconds: 10));

        if (studentProfileSnap.docs.isNotEmpty) {
          var studentData =
              studentProfileSnap.docs.first.data() as Map<String, dynamic>;
          String uni = studentData['university_name'] ?? '';
          String major = studentData['major'] ?? '';

          if (uni.isNotEmpty && major.isNotEmpty) {
            userUniversity.value = '$uni - $major';
          } else {
            userUniversity.value = uni.isNotEmpty ? uni : major;
          }
        } else {
          userUniversity.value = '';
        }

        // جلب الدورات
        QuerySnapshot coursesSnap = await FirebaseFirestore.instance
            .collection('courses')
            .get()
            .timeout(const Duration(seconds: 10));
        coursesList.value = coursesSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();

        // جلب الفرص والوظائف بناءً على جدول Opportunities في الـ ERD
        QuerySnapshot oppSnap = await FirebaseFirestore.instance
            .collection('Opportunities')
            .get()
            .timeout(const Duration(seconds: 10));
        opportunitiesList.value = oppSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();

        // جلب المعلمين الخصوصيين بناءً على جدول Service_Providers أو المعلمين
        QuerySnapshot tutorsSnap = await FirebaseFirestore.instance
            .collection('Service_Providers')
            .where('provider_type', isEqualTo: 'private_tutor')
            .get()
            .timeout(const Duration(seconds: 10));

        // إذا لم توجد في Service_Providers، نجرب جدول instructors احتياطياً
        if (tutorsSnap.docs.isEmpty) {
          tutorsSnap = await FirebaseFirestore.instance
              .collection('instructors')
              .get()
              .timeout(const Duration(seconds: 10));
        }

        tutorsList.value = tutorsSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();

        QuerySnapshot printSnap = await FirebaseFirestore.instance
            .collection('Print_Services')
            .get()
            .timeout(const Duration(seconds: 10));
        printServicesList.value = printSnap.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      } catch (e) {
        userName.value = 'مرحباً بزائر';
        userUniversity.value = '';
      }
    });
    isLoading.value = false;
  }
}
