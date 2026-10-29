import 'package:cloud_firestore/cloud_firestore.dart';

class TutorProfileModel {
  final String id;
  final String providerId;
  final String academicDegree; // e.g. 'Bachelor', 'Master', 'PhD'
  final double hourlyRate;
  final String teachingMode; // 'student_home', 'tutor_office', 'online', 'hybrid'
  final int yearsOfExperience;

  const TutorProfileModel({
    required this.id,
    required this.providerId,
    required this.academicDegree,
    required this.hourlyRate,
    this.teachingMode = 'hybrid',
    this.yearsOfExperience = 1,
  });

  // Arabic display for teaching mode
  String get teachingModeText {
    switch (teachingMode) {
      case 'student_home':
        return 'منزل الطالب';
      case 'tutor_office':
        return 'مكتب المعلم / المركز';
      case 'online':
        return 'عن بُعد (أونلاين)';
      case 'hybrid':
      default:
        return 'وجاهي وعن بُعد';
    }
  }

  // Arabic display for academic degree
  String get academicDegreeText {
    switch (academicDegree.toLowerCase()) {
      case 'master':
      case 'ماجستير':
        return 'ماجستير أكاديمي';
      case 'phd':
      case 'دكتوراه':
        return 'دكتوراه في التخصص';
      case 'bachelor':
      case 'بكالوريوس':
      default:
        return 'بكالوريوس جامعي';
    }
  }

  factory TutorProfileModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TutorProfileModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      providerId: (map['provider_id'] ?? map['providerId'] ?? '').toString(),
      academicDegree: (map['academic_degree'] ?? map['academicDegree'] ?? 'بكالوريوس').toString(),
      hourlyRate: (map['hourly_rate'] ?? map['hourlyRate'] ?? 40).toDouble(),
      teachingMode: (map['teaching_mode'] ?? map['teachingMode'] ?? 'hybrid').toString(),
      yearsOfExperience: (map['years_of_experience'] ?? map['yearsOfExperience'] ?? 1) is int
          ? (map['years_of_experience'] ?? 1) as int
          : int.tryParse((map['years_of_experience'] ?? 1).toString()) ?? 1,
    );
  }

  factory TutorProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TutorProfileModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'academic_degree': academicDegree,
      'hourly_rate': hourlyRate,
      'teaching_mode': teachingMode,
      'years_of_experience': yearsOfExperience,
    };
  }

  TutorProfileModel copyWith({
    String? id,
    String? providerId,
    String? academicDegree,
    double? hourlyRate,
    String? teachingMode,
    int? yearsOfExperience,
  }) {
    return TutorProfileModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      academicDegree: academicDegree ?? this.academicDegree,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      teachingMode: teachingMode ?? this.teachingMode,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    );
  }
}
