class TutorModel {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final double hourlyRate;
  final String avatarUrl;

  TutorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.hourlyRate,
    required this.avatarUrl,
  });

  factory TutorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TutorModel(
      id: documentId,
      name: map['name'] ?? '',
      specialization: map['specialization'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      hourlyRate: (map['hourly_rate'] ?? 0.0).toDouble(),
      avatarUrl: map['avatar_url'] ?? '[رابط_صورة_المدرس]',
    );
  }
}