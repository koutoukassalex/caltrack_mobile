class ExerciseEntry {
  final String id;
  final String name;
  final int durationMinutes;
  final double caloriesBurned;
  final DateTime timestamp;

  ExerciseEntry({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.caloriesBurned,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      id: json['id'] as String,
      name: json['name'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
