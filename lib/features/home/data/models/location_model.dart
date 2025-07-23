class LocationModel {
  final String name;

  const LocationModel({required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      LocationModel(name: json['name'] as String);
}
