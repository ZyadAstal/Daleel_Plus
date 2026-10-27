import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/job_opportunity_model.dart';
import '../models/tutor_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CourseModel>> getFeaturedCourses() async {
    final snapshot = await _firestore.collection('Courses').limit(5).get();
    return snapshot.docs.map((doc) => CourseModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<JobOpportunityModel>> getLatestJobs() async {
    final snapshot = await _firestore.collection('JobOpportunities').limit(5).get();
    return snapshot.docs.map((doc) => JobOpportunityModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<TutorModel>> getTopTutors() async {
    final snapshot = await _firestore.collection('Tutors').limit(5).get();
    return snapshot.docs.map((doc) => TutorModel.fromMap(doc.data(), doc.id)).toList();
  }
}