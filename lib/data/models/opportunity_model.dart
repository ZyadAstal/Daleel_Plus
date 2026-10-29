import 'package:cloud_firestore/cloud_firestore.dart';

class OpportunityModel {
  final String id;
  final String providerId;
  final String title;
  final String opportunityType; // 'internship', 'job_fulltime', 'job_parttime', 'volunteering'
  final String description;
  final List<String> requirements;
  final double? stipendSalary;
  final String? stipendSalaryText; // Custom text like '600 ₪ / شهر'
  final String workMode; // 'remote', 'on_site', 'hybrid'
  final String cityLocation;
  final DateTime? deadlineDate;
  final String applicationLinkOrEmail;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;

  const OpportunityModel({
    required this.id,
    required this.providerId,
    required this.title,
    this.opportunityType = 'internship',
    required this.description,
    this.requirements = const [],
    this.stipendSalary,
    this.stipendSalaryText,
    this.workMode = 'hybrid',
    required this.cityLocation,
    this.deadlineDate,
    required this.applicationLinkOrEmail,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
  });

  // Arabic Display for Opportunity Type
  String get opportunityTypeText {
    switch (opportunityType) {
      case 'job_fulltime':
        return 'عمل دوام كامل';
      case 'job_parttime':
        return 'عمل دوام جزئي';
      case 'volunteering':
        return 'عمل تطوعي';
      case 'internship':
      default:
        return 'تدريب منتهي بالتوظيف';
    }
  }

  // Arabic Display for Work Mode
  String get workModeText {
    switch (workMode) {
      case 'remote':
        return 'عن بُعد (Remote)';
      case 'on_site':
        return 'وجاهي بمقر الشركة';
      case 'hybrid':
      default:
        return 'نظام هجين / عن بعد';
    }
  }

  // Formatted Stipend Display
  String get formattedSalary {
    if (stipendSalaryText != null && stipendSalaryText!.trim().isNotEmpty) {
      return stipendSalaryText!;
    }
    if (stipendSalary != null && stipendSalary! > 0) {
      return '${stipendSalary!.toStringAsFixed(0)} ₪ / شهر';
    }
    return 'غير مدفوع الأجر / تطوعي';
  }

  // Calculate Remaining Days until deadline
  int get remainingDays {
    if (deadlineDate == null) return 0;
    final now = DateTime.now();
    final difference = deadlineDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Check if deadline has passed
  bool get isExpired {
    if (deadlineDate == null) return false;
    return DateTime.now().isAfter(deadlineDate!);
  }

  factory OpportunityModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      if (val is String && val.trim().isNotEmpty) {
        return [val.trim()];
      }
      return [];
    }

    return OpportunityModel(
      id: docId ?? (map['id'] ?? map['document_id'] ?? '').toString(),
      providerId: (map['provider_id'] ?? map['providerId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      opportunityType: (map['opportunity_type'] ?? 'internship').toString(),
      description: (map['description'] ?? '').toString(),
      requirements: parseList(map['requirements']),
      stipendSalary: map['stipend_salary'] is num
          ? (map['stipend_salary'] as num).toDouble()
          : double.tryParse(map['stipend_salary']?.toString() ?? ''),
      stipendSalaryText: map['stipend_salary_text']?.toString() ?? map['allowance']?.toString(),
      workMode: (map['work_mode'] ?? 'hybrid').toString(),
      cityLocation: (map['city_location'] ?? map['location'] ?? 'غزة - الرمال').toString(),
      deadlineDate: parseDate(map['deadline_date'] ?? map['deadline']),
      applicationLinkOrEmail: (map['application_link_or_email'] ?? map['applicationLink'] ?? '').toString(),
      isFeatured: map['is_featured'] ?? false,
      isActive: map['is_active'] ?? true,
      createdAt: parseDate(map['created_at']),
    );
  }

  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OpportunityModel.fromMap(data, docId: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'provider_id': providerId,
      'title': title,
      'opportunity_type': opportunityType,
      'description': description,
      'requirements': requirements,
      'stipend_salary': stipendSalary,
      'stipend_salary_text': stipendSalaryText,
      'work_mode': workMode,
      'city_location': cityLocation,
      'deadline_date': deadlineDate != null ? Timestamp.fromDate(deadlineDate!) : null,
      'application_link_or_email': applicationLinkOrEmail,
      'is_featured': isFeatured,
      'is_active': isActive,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
    };
  }

  OpportunityModel copyWith({
    String? id,
    String? providerId,
    String? title,
    String? opportunityType,
    String? description,
    List<String>? requirements,
    double? stipendSalary,
    String? stipendSalaryText,
    String? workMode,
    String? cityLocation,
    DateTime? deadlineDate,
    String? applicationLinkOrEmail,
    bool? isFeatured,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      opportunityType: opportunityType ?? this.opportunityType,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      stipendSalary: stipendSalary ?? this.stipendSalary,
      stipendSalaryText: stipendSalaryText ?? this.stipendSalaryText,
      workMode: workMode ?? this.workMode,
      cityLocation: cityLocation ?? this.cityLocation,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      applicationLinkOrEmail:
          applicationLinkOrEmail ?? this.applicationLinkOrEmail,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
