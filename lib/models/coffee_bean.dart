// lib/models/coffee_bean.dart
class CoffeeBean {
  final String id;
  final String name; // e.g. "Ethiopia Yirgacheffe"
  final String roaster; // e.g. "The Barn"
  final DateTime roastDate;
  final String notes;
  final bool isFinished; // To archive empty bags

  CoffeeBean({
    required this.id,
    required this.name,
    required this.roaster,
    required this.roastDate,
    required this.notes,
    this.isFinished = false,
  });

  // Helper: Calculate Freshness
  int get daysOffRoast {
    final now = DateTime.now();
    // Reset time components to compare just dates
    final dateRoast = DateTime(roastDate.year, roastDate.month, roastDate.day);
    final dateNow = DateTime(now.year, now.month, now.day);
    return dateNow.difference(dateRoast).inDays;
  }

  // JSON Serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'roaster': roaster,
    'roastDate': roastDate.toIso8601String(),
    'notes': notes,
    'isFinished': isFinished,
  };

  factory CoffeeBean.fromJson(Map<String, dynamic> json) {
    return CoffeeBean(
      id: json['id'],
      name: json['name'],
      roaster: json['roaster'],
      roastDate: DateTime.parse(json['roastDate']),
      notes: json['notes'] ?? "",
      isFinished: json['isFinished'] ?? false,
    );
  }
}
