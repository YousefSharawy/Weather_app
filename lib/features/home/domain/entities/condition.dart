class Condition {
  final String icon;

  const Condition({required this.icon});

  factory Condition.fromJson(Map<String, dynamic> json) =>
      Condition(icon: json['icon'] as String);
}
