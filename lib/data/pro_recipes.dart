// lib/data/pro_recipes.dart
import '../models/recipe.dart';

class ProRecipes {
  static final List<Recipe> list = [
    Recipe(
      id: "pro_v60_hoffmann",
      method: "V60 (Hoffmann)",
      beanOrigin: "Balanced Profile",
      roastLevel: "Medium",
      grindSetting: "Medium-Fine",
      doseWeight: 30.0,
      waterWeight: 500.0,
      waterTemp: 100.0, // Boiling
      ratio: "1:16.6",
      brewTime: "3:30",
      notes:
          "1. 60g bloom (45s)\n2. Pour to 300g (by 1:15)\n3. Pour to 500g (by 1:45)\n4. Swirl and let draw down.",
      date: DateTime.now(),
      grinderId: "",
    ),
    Recipe(
      id: "pro_v60_46",
      method: "V60 (4:6 Method)",
      beanOrigin: "Fruit Bomb",
      roastLevel: "Light",
      grindSetting: "Coarse",
      doseWeight: 20.0,
      waterWeight: 300.0,
      waterTemp: 93.0,
      ratio: "1:15",
      brewTime: "3:00",
      notes:
          "Pour 5x 60g pours.\nWait 45s between each pour.\nSweetness vs Acidity balance.",
      date: DateTime.now(),
      grinderId: "",
    ),
    Recipe(
      id: "pro_aeropress_wendelboe",
      method: "Aeropress",
      beanOrigin: "Nordic Style",
      roastLevel: "Light",
      grindSetting: "Fine",
      doseWeight: 14.0,
      waterWeight: 200.0,
      waterTemp: 98.0,
      ratio: "1:14",
      brewTime: "1:00",
      notes:
          "1. Pour 200g water\n2. Stir 3 times\n3. Insert plunger, wait 60s\n4. Press gently.",
      date: DateTime.now(),
      grinderId: "",
    ),
    Recipe(
      id: "pro_french_press",
      method: "French Press",
      beanOrigin: "Classic",
      roastLevel: "Medium-Dark",
      grindSetting: "Medium-Coarse",
      doseWeight: 30.0,
      waterWeight: 500.0,
      waterTemp: 95.0,
      ratio: "1:16",
      brewTime: "4:00",
      notes:
          "1. Add water, wait 4 mins\n2. Break crust and scoop foam\n3. Wait 5 mins (particles settle)\n4. Plunge lightly.",
      date: DateTime.now(),
      grinderId: "",
    ),
    Recipe(
      id: "pro_mokapot",
      method: "Moka Pot",
      beanOrigin: "Italian Blend",
      roastLevel: "Medium",
      grindSetting: "Fine (Table Salt)",
      doseWeight: 18.0,
      waterWeight: 180.0,
      waterTemp: 99.0,
      ratio: "1:10",
      brewTime: "Variable",
      notes:
          "Use boiling water in chamber.\nLow heat.\nStop when sputtering starts.",
      date: DateTime.now(),
      grinderId: "",
    ),
  ];
}
