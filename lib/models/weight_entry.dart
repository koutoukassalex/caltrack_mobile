class WeightEntry {
  final String id;
  final double weightKg;
  final DateTime date;

  WeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'date': date.toIso8601String(),
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
