# ☕ Coffee Dice

**The app for indecisive baristas.**

Coffee Dice is a Flutter application designed to break your brewing routine. Can't decide how to brew your morning cup? Let the dice decide. Roll for a method, a ratio, and a chaotic "wildcard" instruction to spice up your coffee ritual.

## 📱 Features

### 🎲 The Dice Engine
* **Smart Randomizer:** Picks from "Gold Standard" recipes (e.g., Hoffmann V60, 4:6 Method) or generates a custom challenge.
* **User Memories:** Has a 20% chance to remind you of your *own* saved favorites instead of a random suggestion.
* **Wildcards:** Adds fun variables like "Grind one step finer" or "Trust your instincts."

### 📖 The Coffee Journal
* **Log Your Brews:** Save your best recipes with detailed notes (dose, temp, time, grind).
* **Swipe Actions:** Swipe **Right** to edit, swipe **Left** to delete entries instantly.
* **Quick Stats:** Track your total brew count and favorite methods directly from the dashboard.

### ⚙️ My Gear
* **Grinder Inventory:** Add your specific grinders (e.g., Baratza Encore, Comandante).
* **Recipe Linking:** Every journal entry remembers exactly which grinder you used.

### 🎨 Design & Feel
* **Dark Mode:** A "Dark Roast" theme that auto-adapts icons and text.
* **Audio Feedback:** Satisfying ASMR clicks and success chimes (with a mute toggle).
* **Adaptive UI:** Clean, minimalist inputs and "Soft" animations for a premium feel.

## 🛠️ Tech Stack
* **Framework:** Flutter & Dart
* **Backend:** Firebase (Auth & Core)
* **Local Storage:** `shared_preferences` (Persist recipes & settings)
* **Audio:** `audioplayers` package
* **State Management:** `setState` (Clean & effective)

## 🚀 How to Run

1.  **Clone the repo:**
    ```bash
    git clone [https://github.com/tlegenovv21/coffee_dice.git](https://github.com/tlegenovv21/coffee_dice.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the app:**
    ```bash
    flutter run
    ```

## 🔮 Roadmap & Status

### ✅ Completed (v1.2.3)
- [x] **Smart Dice Logic:** Added Pro Recipes database & "Save Roll" feature.
- [x] **Journal System:** Users can log, save, edit, and delete recipes.
- [x] **Grinder Inventory:** Full management system for coffee gear.
- [x] **Audio Effects:** Added sound feedback for interactions.
- [x] **Dark Mode:** Fully optimized "Dark Roast" theme.
- [x] **Persistent Storage:** Data saves automatically to the device.

### 🚧 Coming Soon
- [ ] **Brew Timer & Stopwatch:** A built-in timer with "Bloom" alerts to guide your pour-overs.
- [ ] **Interactive Flavor Wheel:** Tap to select tasting notes (e.g., "Berry," "Nutty," "Floral") based on the standard Coffee Taster's Flavor Wheel.
- [ ] **Bean Stash Tracker:** Track your coffee bags, roast dates, and freshness (days off-roast).
- [ ] **Smart Scale Support:** (Experimental) Connect via Bluetooth to Acaia/Timemore scales to auto-log brew weight and time.
- [ ] **Recipe Scaler:** Automatically calculate the water needed based on how much coffee you have left (or vice-versa).
- [ ] **Social Cards:** Generate beautiful, shareable images of your daily brew stats for Instagram Stories.
- [ ] **Cloud Sync:** Sync your journal and grinder settings across multiple devices..
