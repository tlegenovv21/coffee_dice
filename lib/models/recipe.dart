// lib/models/recipe.dart

class Recipe {
  final String method;
  final String ratio;
  final String waterTemp;
  final String brewTime;
  final String bloom;
  final String beanOrigin;
  final String rating;

  // --- NEW INTEGRATION FIELDS ---
  final String? grinderId; // Links to the specific physical grinder
  final String grindSetting; // The setting used (e.g. "14" or "3.5")
  final double doseWeight; // Grams input (e.g. 18.0)
  final int? rpm; // Optional: For high-end grinders
  final double? burrGapMicrons; // Optional: For advanced users
  final String calibrationNotes; // "Click 5 feels like 6 on my old one"

  Recipe({
    required this.method,
    required this.ratio,
    required this.waterTemp,
    required this.brewTime,
    required this.bloom,
    required this.beanOrigin,
    required this.rating,
    required this.grindSetting,
    this.grinderId,
    this.doseWeight = 0.0,
    this.rpm,
    this.burrGapMicrons,
    this.calibrationNotes = "",
  });

  Map<String, dynamic> toJson() => {
    'method': method,
    'ratio': ratio,
    'waterTemp': waterTemp,
    'brewTime': brewTime,
    'bloom': bloom,
    'beanOrigin': beanOrigin,
    'rating': rating,
    'grindSetting': grindSetting,
    'grinderId': grinderId,
    'doseWeight': doseWeight,
    'rpm': rpm,
    'burrGapMicrons': burrGapMicrons,
    'calibrationNotes': calibrationNotes,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      method: json['method'] ?? "",
      ratio: json['ratio'] ?? "",
      waterTemp: json['waterTemp'] ?? "",
      brewTime: json['brewTime'] ?? "",
      bloom: json['bloom'] ?? "",
      beanOrigin: json['beanOrigin'] ?? "",
      rating: json['rating'] ?? "",
      grindSetting: json['grindSetting'] ?? json['grind'] ?? "",
      grinderId: json['grinderId'],
      doseWeight: (json['doseWeight'] ?? 0.0).toDouble(),
      rpm: json['rpm'],
      burrGapMicrons: (json['burrGapMicrons'] ?? 0.0).toDouble(),
      calibrationNotes: json['calibrationNotes'] ?? "",
    );
  }
}
