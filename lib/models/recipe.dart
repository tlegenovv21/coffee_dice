// lib/models/recipe.dart
class Recipe {
  final String id; // <--- NEW
  final String method;
  final String beanOrigin;
  final String roastLevel;
  final String grindSetting;
  final double doseWeight;
  final double waterWeight;
  final double waterTemp;
  final String ratio;
  final String brewTime;
  final String notes; // <--- NEW
  final DateTime date;
  final String grinderId;

  Recipe({
    required this.id, // <--- NEW
    required this.method,
    required this.beanOrigin,
    required this.roastLevel,
    required this.grindSetting,
    required this.doseWeight,
    required this.waterWeight,
    required this.waterTemp,
    required this.ratio,
    required this.brewTime,
    required this.notes, // <--- NEW
    required this.date,
    required this.grinderId,
  });

  // Convert to JSON (Saving)
  Map<String, dynamic> toJson() => {
    'id': id,
    'method': method,
    'beanOrigin': beanOrigin,
    'roastLevel': roastLevel,
    'grindSetting': grindSetting,
    'doseWeight': doseWeight,
    'waterWeight': waterWeight,
    'waterTemp': waterTemp,
    'ratio': ratio,
    'brewTime': brewTime,
    'notes': notes,
    'date': date.toIso8601String(),
    'grinderId': grinderId,
  };

  // Create from JSON (Loading)
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      // If 'id' is missing (old data), generate a temporary one
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      method: json['method'] ?? "",
      beanOrigin: json['beanOrigin'] ?? "",
      roastLevel: json['roastLevel'] ?? "",
      grindSetting: json['grindSetting'] ?? "",
      doseWeight: (json['doseWeight'] ?? 0).toDouble(),
      waterWeight: (json['waterWeight'] ?? 0).toDouble(),
      waterTemp: (json['waterTemp'] ?? 0).toDouble(),
      ratio: json['ratio'] ?? "",
      brewTime: json['brewTime'] ?? "",
      // If 'notes' is missing (old data), use empty string
      notes: json['notes'] ?? "",
      date: DateTime.tryParse(json['date'] ?? "") ?? DateTime.now(),
      grinderId: json['grinderId'] ?? "",
    );
  }
}
