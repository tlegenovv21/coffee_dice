// lib/models/grinder.dart

enum GrinderType { conicalBurr, flatBurr, blade }

enum AdjustmentType { stepped, stepless }

class Grinder {
  final String id; // Unique ID (e.g., "g1", "g2")
  final String brand; // e.g., "Baratza"
  final String model; // e.g., "Sette 270"
  final GrinderType type; // Burr vs Blade
  final AdjustmentType adjustmentType; // Clicks vs Infinite
  final double minRange; // Lowest setting (e.g., 1)
  final double maxRange; // Highest setting (e.g., 30)

  // LOGIC GOAL: Save defaults per method
  // Key: Method Name (e.g. "V60"), Value: Setting (e.g. 14.0)
  final Map<String, double> methodDefaults;

  Grinder({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.adjustmentType,
    required this.minRange,
    required this.maxRange,
    this.methodDefaults = const {},
  });

  // --- LOGIC: GET DEFAULT SETTING ---
  double getSuggestedSetting(String method) {
    // 1. Check if user saved a specific default
    if (methodDefaults.containsKey(method)) {
      return methodDefaults[method]!;
    }
    // 2. Fallback: Intelligent guess based on method type
    // (This matches your "Micron Size" logic loosely mapped to range)
    double range = maxRange - minRange;
    switch (method.toLowerCase()) {
      case 'espresso':
        return minRange + (range * 0.1); // Fine
      case 'v60':
      case 'aeropress':
        return minRange + (range * 0.4); // Medium-Fine
      case 'french press':
        return minRange + (range * 0.9); // Coarse
      default:
        return minRange + (range * 0.5); // Medium
    }
  }

  // --- JSON SERIALIZATION (Saving/Loading) ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'brand': brand,
    'model': model,
    'type': type.index, // Save enum as integer
    'adjustmentType': adjustmentType.index,
    'minRange': minRange,
    'maxRange': maxRange,
    'methodDefaults': methodDefaults,
  };

  factory Grinder.fromJson(Map<String, dynamic> json) {
    return Grinder(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      type: GrinderType.values[json['type']],
      adjustmentType: AdjustmentType.values[json['adjustmentType']],
      minRange: (json['minRange'] as num).toDouble(),
      maxRange: (json['maxRange'] as num).toDouble(),
      methodDefaults: Map<String, double>.from(json['methodDefaults'] ?? {}),
    );
  }
}
