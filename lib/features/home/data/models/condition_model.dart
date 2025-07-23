class ConditionModel {
  final String text;
  final String icon;
  final int? code;

  const ConditionModel({required this.text, required this.icon, this.code});

  factory ConditionModel.fromJson(Map<String, dynamic> json) => ConditionModel(
    text: json['text'] as String,
    icon: json['icon'] as String,
    code: json['code'] as int?,
  );
}
