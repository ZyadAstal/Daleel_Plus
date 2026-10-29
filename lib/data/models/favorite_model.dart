import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String id;
  final String studentId;
  final String targetId;
  final String targetType; // 'course', 'opportunity', 'tutor', 'printshop'
  final DateTime? savedAt;

  const FavoriteModel({
    required this.id,
    required this.studentId,
    required this.targetId,
    required this.targetType,
    this.savedAt,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return FavoriteModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      targetId: (map['target_id'] ?? map['targetId'] ?? '').toString(),
      targetType: (map['target_type'] ?? map['targetType'] ?? 'course').toString(),
      savedAt: parseDate(map['saved_at'] ?? map['savedAt']),
    );
  }

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FavoriteModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'target_id': targetId,
      'target_type': targetType,
      'saved_at': savedAt != null ? Timestamp.fromDate(savedAt!) : Timestamp.now(),
    };
  }

  FavoriteModel copyWith({
    String? id,
    String? studentId,
    String? targetId,
    String? targetType,
    DateTime? savedAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
