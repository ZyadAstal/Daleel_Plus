import 'package:cloud_firestore/cloud_firestore.dart';

class TutorSubjectModel {
  final String id;
  final String tutorProfileId;
  final String subjectName;
  final String facultyBranch;

  const TutorSubjectModel({
    required this.id,
    required this.tutorProfileId,
    required this.subjectName,
    required this.facultyBranch,
  });

  factory TutorSubjectModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TutorSubjectModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      tutorProfileId: (map['tutor_profile_id'] ?? map['tutorProfileId'] ?? '').toString(),
      subjectName: (map['subject_name'] ?? map['subjectName'] ?? '').toString(),
      facultyBranch: (map['faculty_branch'] ?? map['facultyBranch'] ?? '').toString(),
    );
  }

  factory TutorSubjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TutorSubjectModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'tutor_profile_id': tutorProfileId,
      'subject_name': subjectName,
      'faculty_branch': facultyBranch,
    };
  }

  TutorSubjectModel copyWith({
    String? id,
    String? tutorProfileId,
    String? subjectName,
    String? facultyBranch,
  }) {
    return TutorSubjectModel(
      id: id ?? this.id,
      tutorProfileId: tutorProfileId ?? this.tutorProfileId,
      subjectName: subjectName ?? this.subjectName,
      facultyBranch: facultyBranch ?? this.facultyBranch,
    );
  }
}
