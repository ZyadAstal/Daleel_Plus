class UserModel {
  final String uid;
  final String name;
  final String university;
  final String specialty;

  UserModel({
    required this.uid,
    required this.name,
    required this.university,
    required this.specialty,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? 'مستخدم جديد',
      university: map['university'] ?? 'الجامعة غير محددة',
      specialty: map['specialty'] ?? 'التخصص غير محدد',
    );
  }
}
