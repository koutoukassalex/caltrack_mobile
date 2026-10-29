class WeightEntry {
  final String id;
  final double weightKg;
  final DateTime date;
  final String? note;
  final String? feeling; // 'energetic', 'great', 'normal', 'tired', 'bloated'

  WeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
    this.note,
    this.feeling,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightKg': weightKg,
      'date': date.toIso8601String(),
      'note': note,
      'feeling': feeling,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      feeling: json['feeling'] as String?,
    );
  }
}
