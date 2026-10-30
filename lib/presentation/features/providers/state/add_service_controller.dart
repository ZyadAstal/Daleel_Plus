import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'provider_helpers.dart';

class AddServiceController extends GetxController {
  final Map<String, dynamic>? editingCourse;

  AddServiceController({this.editingCourse});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get providerId => currentProviderId;
  bool get isEditing => editingCourse != null;

  static const Map<String, String> categories = {
    'برمجة وتطوير تقني وحوسبة': 'دورات وتعليم',
    'تصميم ومهارات رقمية': 'تصميم ومهارات رقمية',
    'لغات ومهارات تواصل': 'لغات ومهارات تواصل',
    'إدارة أعمال وريادة': 'إدارة أعمال وريادة',
    'تدريب مهني واستشارات': 'تدريب مهني واستشارات',
    'تحضير جامعي ومساقات': 'تحضير جامعي ومساقات',
  };

  static const Map<String, String> levels = {
    'beginner': 'مبتدئ (لا يتطلب خبرة)',
    'intermediate': 'متوسط (أساسيات سابقة)',
    'advanced': 'متقدم (احترافي)',
  };

  static const Map<String, String> audienceOptions = {
    'students': 'طلبة الجامعات والمعاهد التقنية',
    'graduates': 'الخريجون الجدد والباحثون عن عمل',
    'employees': 'الموظفون وأصحاب المشاريع الناشئة',
  };

  final serviceType = 'course'.obs;
  final titleController = TextEditingController();
  final category = categories.keys.first.obs;
  final descriptionController = TextEditingController();
  final coverImageUrl = ''.obs;
  final priceController = TextEditingController();
  final studentPriceController = TextEditingController();
  final price = 0.0.obs;
  final studentPrice = 0.0.obs;
  final supportInstallments = false.obs;
  final attendanceMode = 'in_person'.obs;
  final seatsController = TextEditingController();
  final hoursController = TextEditingController();
  final hasCertificate = true.obs;

  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final scheduleDays = <String>[].obs;
  final startTime = const TimeOfDay(hour: 16, minute: 0).obs;
  final endTime = const TimeOfDay(hour: 18, minute: 0).obs;
  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final meetingUrlController = TextEditingController();
  final targetLevel = 'beginner'.obs;
  final audiences = <String>['students'].obs;
  final prerequisitesController = TextEditingController();
  final instructors = <Map<String, dynamic>>[].obs;
  final selectedInstructor = Rxn<Map<String, dynamic>>();

  final cancellationPolicy = 'full_refund_48h'.obs;
  final syllabusUrl = ''.obs;
  final brochureUrl = ''.obs;
  final notifyStudents = false.obs;
  final allowPartialPayment = false.obs;

  final provider = <String, dynamic>{}.obs;
  final isSaving = false.obs;

  double get discountAmount =>
      studentPrice.value > 0 && studentPrice.value < price.value ? price.value - studentPrice.value : 0;

  int get discountPercent =>
      price.value == 0 ? 0 : (discountAmount / price.value * 100).round();

  double get sessionHours {
    final start = startTime.value.hour * 60 + startTime.value.minute;
    final end = endTime.value.hour * 60 + endTime.value.minute;
    return end > start ? (end - start) / 60 : 0;
  }

  double get weeklyHours => sessionHours * scheduleDays.length;

  int get totalProgramHours {
    final start = startDate.value;
    final end = endDate.value;
    if (start == null || end == null || end.isBefore(start)) return 0;
    final weeks = (end.difference(start).inDays + 1) / 7;
    return (weeklyHours * weeks).round();
  }

  @override
  void onInit() {
    super.onInit();
    priceController.addListener(
          () => price.value = double.tryParse(priceController.text) ?? 0,
    );
    studentPriceController.addListener(
          () => studentPrice.value = double.tryParse(studentPriceController.text) ?? 0,
    );
    _loadProvider();
    if (isEditing) _fillFromCourse(editingCourse!);
  }

  @override
  void onClose() {
    for (final controller in [
      titleController,
      descriptionController,
      priceController,
      studentPriceController,
      seatsController,
      hoursController,
      venueController,
      addressController,
      meetingUrlController,
      prerequisitesController,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> _loadProvider() async {
    try {
      final snapshot = await _db.collection('serviceProviders').doc(providerId).get();
      provider.value = snapshot.data() ?? {};

      final List list = provider['instructors'] ?? [];
      instructors.value = list.map((item) => Map<String, dynamic>.from(item)).toList();

      if (selectedInstructor.value == null && instructors.isNotEmpty) {
        selectedInstructor.value = instructors.first;
      }
      if (addressController.text.isEmpty) {
        addressController.text = (provider['addressDetails'] ?? '').toString();
      }
    } catch (e) {
      debugPrint('AddServiceController: $e');
    }
  }

  void _fillFromCourse(Map<String, dynamic> course) {
    String text(String key) => (course[key] ?? '').toString();
    num number(String key) => course[key] ?? 0;

    serviceType.value =
        course['serviceType'] ?? (course['pricingUnit'] == 'hour' ? 'private_lesson' : 'course');
    titleController.text = text('title');
    if (categories.containsKey(course['category'])) category.value = course['category'];
    descriptionController.text = text('description');
    coverImageUrl.value = text('coverImageUrl');
    priceController.text = number('originalPrice') == 0 ? '' : number('originalPrice').toString();
    if (course['discountedPrice'] != null) {
      studentPriceController.text = course['discountedPrice'].toString();
    }
    supportInstallments.value = course['supportInstallments'] ?? false;
    attendanceMode.value = course['attendanceMode'] ?? 'in_person';
    seatsController.text = number('maxSeats') == 0 ? '' : number('maxSeats').toString();
    hoursController.text = number('totalHours') == 0 ? '' : number('totalHours').toString();
    hasCertificate.value = course['hasAccreditedCertificate'] ?? true;

    startDate.value = (course['startDate'] as Timestamp?)?.toDate();
    endDate.value = (course['endDate'] as Timestamp?)?.toDate();
    scheduleDays.value = List<String>.from(course['scheduleDays'] ?? []);
    startTime.value = _parseTime(text('startTime')) ?? startTime.value;
    endTime.value = _parseTime(text('endTime')) ?? endTime.value;
    venueController.text = text('venueName');
    addressController.text = text('venueAddress');
    meetingUrlController.text = text('virtualMeetingUrl');
    targetLevel.value = course['targetLevel'] ?? 'beginner';
    audiences.value = List<String>.from(course['targetAudiences'] ?? ['students']);
    prerequisitesController.text = text('prerequisites');
    if (text('instructorName').isNotEmpty) {
      selectedInstructor.value = {
        'name': text('instructorName'),
        'title': text('instructorTitle'),
        'avatarUrl': text('instructorAvatar'),
      };
    }

    cancellationPolicy.value = course['cancellationPolicy'] ?? 'full_refund_48h';
    syllabusUrl.value = text('syllabusPdfUrl');
    brochureUrl.value = text('brochureUrl');
    notifyStudents.value = course['notifyInterestedStudents'] ?? false;
    allowPartialPayment.value = course['allowPartialPayment'] ?? false;
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String timeText(TimeOfDay time) => ProviderFormat.time12h(_formatTime(time));

  String dateText(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void toggleDay(String day) {
    if (scheduleDays.contains(day)) {
      scheduleDays.remove(day);
    } else {
      scheduleDays.add(day);
    }
  }

  void toggleAudience(String audience) {
    if (audiences.contains(audience)) {
      audiences.remove(audience);
    } else {
      audiences.add(audience);
    }
  }

  String? validateBasicInfo() {
    if (titleController.text.trim().isEmpty) return 'اكتب عنوان الخدمة أو الدورة';
    if (descriptionController.text.trim().length < 30) {
      return 'اكتب وصفًا واضحًا للمحتوى (30 حرفًا على الأقل)';
    }
    if (price.value <= 0) return 'أدخل السعر الأساسي';
    if (studentPrice.value > price.value) return 'سعر الطلاب يجب أن يكون أقل من السعر الأساسي';
    return null;
  }

  String? validateSchedule() {
    if (startDate.value == null || endDate.value == null) return 'حدد تاريخ البدء والانتهاء';
    if (endDate.value!.isBefore(startDate.value!)) return 'تاريخ الانتهاء قبل تاريخ البدء';
    if (scheduleDays.isEmpty) return 'اختر يوم انعقاد واحد على الأقل';
    if (sessionHours <= 0) return 'وقت النهاية يجب أن يكون بعد وقت البداية';
    if (attendanceMode.value != 'online' && venueController.text.trim().isEmpty) {
      return 'اكتب اسم القاعة أو المقر';
    }
    return null;
  }

  Map<String, dynamic> _buildData(String status) {
    final instructor = selectedInstructor.value;
    final hours = int.tryParse(hoursController.text) ?? totalProgramHours;

    return {
      'providerId': providerId,
      'serviceType': serviceType.value,
      'pricingUnit': serviceType.value == 'private_lesson' ? 'hour' : 'course',
      'title': titleController.text.trim(),
      'category': category.value,
      'categorySubtag': categories[category.value],
      'description': descriptionController.text.trim(),
      'coverImageUrl': coverImageUrl.value,
      'originalPrice': price.value,
      'discountedPrice': discountAmount > 0 ? studentPrice.value : null,
      'supportInstallments': supportInstallments.value,
      'attendanceMode': attendanceMode.value,
      'maxSeats': int.tryParse(seatsController.text) ?? 0,
      'totalHours': hours,
      'hasAccreditedCertificate': hasCertificate.value,
      'startDate': startDate.value == null ? null : Timestamp.fromDate(startDate.value!),
      'endDate': endDate.value == null ? null : Timestamp.fromDate(endDate.value!),
      'scheduleDays': scheduleDays.toList(),
      'startTime': _formatTime(startTime.value),
      'endTime': _formatTime(endTime.value),
      'venueName': venueController.text.trim(),
      'venueAddress': addressController.text.trim(),
      'virtualMeetingUrl': meetingUrlController.text.trim(),
      'targetLevel': targetLevel.value,
      'targetAudiences': audiences.toList(),
      'prerequisites': prerequisitesController.text.trim(),
      'instructorName': instructor?['name'] ?? '',
      'instructorTitle': instructor?['title'] ?? '',
      'instructorAvatar': instructor?['avatarUrl'] ?? '',
      'cancellationPolicy': cancellationPolicy.value,
      'syllabusPdfUrl': syllabusUrl.value,
      'brochureUrl': brochureUrl.value,
      'notifyInterestedStudents': notifyStudents.value,
      'allowPartialPayment': allowPartialPayment.value,
      'status': status,
      'isActive': status == 'published',
      'updatedAt': Timestamp.now(),
    };
  }

  Future<bool> save({required bool publish}) async {
    if (isSaving.value) return false;
    isSaving.value = true;

    try {
      final data = _buildData(publish ? 'published' : 'draft');

      if (isEditing) {
        await _db.collection('Courses').doc(editingCourse!['id']).update(data);
      } else {
        await _db.collection('Courses').add({
          ...data,
          'bookedSeats': 0,
          'waitlistCount': 0,
          'createdAt': Timestamp.now(),
        });
      }

      Get.snackbar('تم', publish ? 'تم نشر الخدمة بنجاح' : 'تم حفظ الخدمة كمسودة');
      return true;
    } catch (e) {
      debugPrint('AddServiceController: $e');
      Get.snackbar('خطأ', 'لم يتم الحفظ، حاول مرة أخرى');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> addInstructor({required String name, required String title}) async {
    final instructor = {'name': name, 'title': title, 'avatarUrl': '', 'isActive': true};

    try {
      await _db.collection('serviceProviders').doc(providerId).update({
        'instructors': FieldValue.arrayUnion([instructor]),
        'updatedAt': Timestamp.now(),
      });
      instructors.add(instructor);
      selectedInstructor.value = instructor;
    } catch (e) {
      debugPrint('AddServiceController: $e');
      Get.snackbar('خطأ', 'لم تتم إضافة المدرب، حاول مرة أخرى');
    }
  }
}