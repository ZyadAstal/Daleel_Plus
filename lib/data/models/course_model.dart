import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String providerId;
  final String title;
  final String categorySubtag;
  final String description;
  final String? syllabusPdfUrl;
  final String coverImageUrl;
  final double originalPrice;
  final double? discountedPrice;
  final String attendanceMode; // 'in_person', 'online', 'hybrid'
  final String? venueName;
  final String? virtualMeetingUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> scheduleDays;
  final String startTime;
  final String endTime;
  final int totalHours;
  final String targetLevel; // 'beginner', 'intermediate', 'advanced'
  final String? prerequisites;
  final List<String> targetAudiences;
  final String? instructorName;
  final String? instructorAvatar;
  final bool hasAccreditedCertificate;
  final String cancellationPolicy; // 'Full_Refund_48h', 'half_Refund_First_session', 'Custom'
  final bool isActive;
  final DateTime? createdAt;

  const CourseModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.categorySubtag,
    required this.description,
    this.syllabusPdfUrl,
    required this.coverImageUrl,
    required this.originalPrice,
    this.discountedPrice,
    this.attendanceMode = 'in_person',
    this.venueName,
    this.virtualMeetingUrl,
    this.startDate,
    this.endDate,
    this.scheduleDays = const [],
    this.startTime = '',
    this.endTime = '',
    this.totalHours = 0,
    this.targetLevel = 'beginner',
    this.prerequisites,
    this.targetAudiences = const [],
    this.instructorName,
    this.instructorAvatar,
    this.hasAccreditedCertificate = true,
    this.cancellationPolicy = 'Full_Refund_48h',
    this.isActive = true,
    this.createdAt,
  });

  // Effective price after discount
  double get effectivePrice => discountedPrice ?? originalPrice;

  // Saved amount
  double get savedAmount =>
      (discountedPrice != null && discountedPrice! < originalPrice)
          ? originalPrice - discountedPrice!
          : 0.0;

  // Check if course has active discount
  bool get hasDiscount =>
      discountedPrice != null && discountedPrice! < originalPrice;

  // Percentage discount
  int get discountPercentage => hasDiscount
      ? (((originalPrice - discountedPrice!) / originalPrice) * 100).round()
      : 0;

  // Arabic display for Attendance Mode
  String get attendanceModeText {
    switch (attendanceMode) {
      case 'online':
        return 'عن بُعد (أونلاين)';
      case 'hybrid':
        return 'مختلط (هجين)';
      case 'in_person':
      default:
        return 'وجاهي بالمركز';
    }
  }

  // Arabic display for Target Level
  String get targetLevelText {
    switch (targetLevel) {
      case 'intermediate':
        return 'مستوى متوسط';
      case 'advanced':
        return 'مستوى متقدم';
      case 'beginner':
      default:
        return 'مستوى مبتدئ';
    }
  }

  // Arabic display for Cancellation Policy
  String get cancellationPolicyText {
    switch (cancellationPolicy) {
      case 'half_refund_first_session':
      case 'half_Refund_First_session':
        return 'استرداد 50% بعد الجلسة الأولى';
      case 'custom':
      case 'Custom':
        return 'سياسة إلغاء مخصصة للمركز';
      case 'full_refund_48h':
      case 'Full_Refund_48h':
      default:
        return 'استرداد كامل قبل 48 ساعة';
    }
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    double parseNumToDouble(dynamic value, [double fallback = 0.0]) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? fallback;
      return fallback;
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int parseNumToInt(dynamic value, [int fallback = 0]) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return CourseModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      providerId: (map['provider_id'] ?? map['providerId'] ?? '').toString(),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      categorySubtag: (map['categorySubtag'] ?? map['category_subtag'] ?? map['category'] ?? '').toString(),
      description: (map['description'] ?? map['details'] ?? '').toString(),
      syllabusPdfUrl: (map['syllabusPdfUrl'] ?? map['syllabus_pdf_url'])?.toString(),
      coverImageUrl: (() {
        final raw = (map['coverImageUrl'] ?? map['cover_image_url'] ?? map['imageUrl'] ?? map['image'] ?? '').toString();
        return raw.trim().isNotEmpty
            ? raw
            : 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80';
      })(),
      originalPrice: parseNumToDouble(map['originalPrice'] ?? map['original_price'] ?? map['price']),
      discountedPrice: parseNullableDouble(map['discountedPrice'] ?? map['discounted_price']),
      attendanceMode: (map['attendanceMode'] ?? map['attendance_mode'] ?? 'in_person').toString(),
      venueName: (map['venueName'] ?? map['venue_name'])?.toString(),
      virtualMeetingUrl: (map['virtualMeetingUrl'] ?? map['virtual_meeting_url'])?.toString(),
      startDate: parseDate(map['startDate'] ?? map['start_date']),
      endDate: parseDate(map['endDate'] ?? map['end_date']),
      scheduleDays: ((map['scheduleDays'] ?? map['schedule_days']) as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      startTime: (map['startTime'] ?? map['start_time'] ?? '').toString(),
      endTime: (map['endTime'] ?? map['end_time'] ?? '').toString(),
      totalHours: parseNumToInt(map['totalHours'] ?? map['total_hours'] ?? map['duration']),
      targetLevel: (map['targetLevel'] ?? map['target_level'] ?? 'beginner').toString(),
      prerequisites: (map['prerequisites'])?.toString(),
      targetAudiences: ((map['targetAudiences'] ?? map['target_audiences']) as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructorName: (map['instructorName'] ?? map['instructor_name'])?.toString(),
      instructorAvatar: (map['instructorAvatar'] ?? map['instructor_avatar'])?.toString(),
      hasAccreditedCertificate: map['hasAccreditedCertificate'] ?? map['has_accredited_certificate'] ?? true,
      cancellationPolicy:
          (map['cancellationPolicy'] ?? map['cancellation_policy'] ?? 'Full_Refund_48h').toString(),
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
    );
  }

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CourseModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'title': title,
      'category_subtag': categorySubtag,
      'description': description,
      'syllabus_pdf_url': syllabusPdfUrl,
      'cover_image_url': coverImageUrl,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'attendance_mode': attendanceMode,
      'venue_name': venueName,
      'virtual_meeting_url': virtualMeetingUrl,
      'start_date': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'schedule_days': scheduleDays,
      'start_time': startTime,
      'end_time': endTime,
      'total_hours': totalHours,
      'target_level': targetLevel,
      'prerequisites': prerequisites,
      'target_audiences': targetAudiences,
      'instructor_name': instructorName,
      'instructor_avatar': instructorAvatar,
      'has_accredited_certificate': hasAccreditedCertificate,
      'cancellation_policy': cancellationPolicy,
      'is_active': isActive,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  CourseModel copyWith({
    String? id,
    String? providerId,
    String? title,
    String? categorySubtag,
    String? description,
    String? syllabusPdfUrl,
    String? coverImageUrl,
    double? originalPrice,
    double? discountedPrice,
    String? attendanceMode,
    String? venueName,
    String? virtualMeetingUrl,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? scheduleDays,
    String? startTime,
    String? endTime,
    int? totalHours,
    String? targetLevel,
    String? prerequisites,
    List<String>? targetAudiences,
    String? instructorName,
    String? instructorAvatar,
    bool? hasAccreditedCertificate,
    String? cancellationPolicy,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      categorySubtag: categorySubtag ?? this.categorySubtag,
      description: description ?? this.description,
      syllabusPdfUrl: syllabusPdfUrl ?? this.syllabusPdfUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      attendanceMode: attendanceMode ?? this.attendanceMode,
      venueName: venueName ?? this.venueName,
      virtualMeetingUrl: virtualMeetingUrl ?? this.virtualMeetingUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      targetLevel: targetLevel ?? this.targetLevel,
      prerequisites: prerequisites ?? this.prerequisites,
      targetAudiences: targetAudiences ?? this.targetAudiences,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      hasAccreditedCertificate:
          hasAccreditedCertificate ?? this.hasAccreditedCertificate,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, title: $title, categorySubtag: $categorySubtag, originalPrice: $originalPrice, discountedPrice: $discountedPrice, attendanceMode: $attendanceMode, totalHours: $totalHours, instructorName: $instructorName, coverImageUrl: $coverImageUrl)';
  }
}
