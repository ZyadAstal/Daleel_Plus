class PrintCenterModel {
  final String id;
  final String name;
  final String location;
  final String distance;
  final String pricePerSheet;
  final List<String> services;

  PrintCenterModel({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.pricePerSheet,
    required this.services,
  });

  factory PrintCenterModel.fromMap(Map<String, dynamic> map, String id) {
    return PrintCenterModel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      distance: map['distance'] ?? '',
      pricePerSheet: map['pricePerSheet'] ?? '',
      services: List<String>.from(map['services'] ?? []),
    );
  }
}
