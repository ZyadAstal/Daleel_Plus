import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String studentId;
  final String providerId;
  final String? bookingId;
  final double rating; // between 1 and 5
  final double? contentQualityRating;
  final double? instructorRating;
  final String? comment;
  final String? providerReply;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.studentId,
    required this.providerId,
    this.bookingId,
    required this.rating,
    this.contentQualityRating,
    this.instructorRating,
    this.comment,
    this.providerReply,
    this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return ReviewModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? '').toString(),
      providerId: (map['provider_id'] ?? map['providerId'] ?? '').toString(),
      bookingId: map['booking_id']?.toString() ?? map['bookingId']?.toString(),
      rating: (map['rating'] ?? 5.0).toDouble(),
      contentQualityRating: map['content_quality_rating'] != null
          ? (map['content_quality_rating']).toDouble()
          : null,
      instructorRating: map['instructor_rating'] != null
          ? (map['instructor_rating']).toDouble()
          : null,
      comment: map['comment']?.toString(),
      providerReply: map['provider_reply']?.toString() ?? map['providerReply']?.toString(),
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
    );
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'provider_id': providerId,
      'booking_id': bookingId,
      'rating': rating,
      'content_quality_rating': contentQualityRating,
      'instructor_rating': instructorRating,
      'comment': comment,
      'provider_reply': providerReply,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? studentId,
    String? providerId,
    String? bookingId,
    double? rating,
    double? contentQualityRating,
    double? instructorRating,
    String? comment,
    String? providerReply,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      providerId: providerId ?? this.providerId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      contentQualityRating: contentQualityRating ?? this.contentQualityRating,
      instructorRating: instructorRating ?? this.instructorRating,
      comment: comment ?? this.comment,
      providerReply: providerReply ?? this.providerReply,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
