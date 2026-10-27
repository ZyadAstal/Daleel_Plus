class CourseModel {
  final String id;
  final String title;
  final String categorySubtag;
  final String coverImageUrl;
  final double originalPrice;
  final double? discountedPrice;
  final String instructorName;
  final double rating;

  CourseModel({
    required this.id,
    required this.title,
    required this.categorySubtag,
    required this.coverImageUrl,
    required this.originalPrice,
    this.discountedPrice,
    required this.instructorName,
    required this.rating,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CourseModel(
      id: documentId,
      title: map['title'] ?? '',
      categorySubtag: map['category_subtag'] ?? '',
      coverImageUrl: map['cover_image_url'] ?? '[رابط_صورة_الغلاف]',
      originalPrice: (map['original_price'] ?? 0).toDouble(),
      discountedPrice: map['discounted_price']?.toDouble(),
      instructorName: map['instructor_name'] ?? 'محاضر معتمد',
      rating: 4.9,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category_subtag': categorySubtag,
      'cover_image_url': coverImageUrl,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'instructor_name': instructorName,
    };
  }
}