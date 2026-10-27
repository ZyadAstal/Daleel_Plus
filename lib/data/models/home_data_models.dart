class CourseModel {
  final String id;
  final String title;
  final String academy;
  final double price;
  final double discountPrice;
  final String discountPercent;
  final double rating;

  CourseModel({
    required this.id,
    required this.title,
    required this.academy,
    required this.price,
    required this.discountPrice,
    required this.discountPercent,
    required this.rating,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      academy: map['academy'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toDouble(),
      discountPercent: map['discountPercent'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String reward;
  final String type;
  final String timeLeft;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.reward,
    required this.type,
    required this.timeLeft,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      reward: map['reward'] ?? '',
      type: map['type'] ?? '',
      timeLeft: map['timeLeft'] ?? '',
    );
  }
}

class InstructorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewsCount;
  final double pricePerHour;

  InstructorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerHour,
  });

  factory InstructorModel.fromMap(Map<String, dynamic> map, String id) {
    return InstructorModel(
      id: id,
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      pricePerHour: (map['pricePerHour'] ?? 0).toDouble(),
    );
  }
}
