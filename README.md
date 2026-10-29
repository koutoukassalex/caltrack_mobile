# 🥑 CaLtrack-AI — AI Calorie & Macro Tracker (Flutter Mobile)

<p align="center">
  <b>Production-Grade AI-Powered Calorie, Macro, and Hydration Tracking for iOS & Android</b><br>
  Built with Flutter • Material 3 Design • Gemini AI Vision & Coaching • Offline-First Persistence
</p>

---

## 📱 Features & Highlights

- **AI Food Vision (Gemini 1.5 Flash):** Snap or upload a photo of your meal; the on-device AI identifies food items, estimates portion weights, and breaks down calories, protein, carbs, and fats with 1-tap logging directly to your diary.
- **Dynamic Interactive Dashboard:**
  - Real-time **Calorie Ring** visualization showing net calories, goal, and burned calories.
  - **Daily Budget Math** row (`Base Goal + Exercise - Food = Remaining`).
  - **Macro Distribution Bars** for Protein, Carbohydrates, and Fats with target progress.
  - **Hydration Tracker** with quick +250ml cups and target progress.
  - **Quick Add Row** for instant logging of common foods (Banana, Boiled Eggs, Whey Scoop, Coffee, Greek Yogurt).
  - Four organized meal categories: **Breakfast, Lunch, Dinner, Snacks**.
- **Interactive AI Nutritionist Coach:**
  - Full-featured chat assistant providing real-time personalized nutrition advice, recipe recommendations, and macro auditing grounded in your daily food diary.
- **Detailed Stats & Analytics:**
  - 7-day Calorie Bar Chart rendered with `fl_chart` comparing daily intake to target.
  - Macro Distribution Pie Chart with interactive slice percentages.
  - Weekly averages calculation (Average Calories, Protein, Carbs, Fat).
  - Weight logging and historical weight trend tracker.
- **Personalized Biometrics & Onboarding:**
  - 4-step onboarding wizard calculating exact Basal Metabolic Rate (BMR) and Total Daily Energy Expenditure (TDEE) via the **Mifflin-St Jeor equation**.
  - Goal adjustments for Fat Loss (-500 kcal), Maintenance, or Muscle Building (+350 kcal).
- **Customizable Aesthetics & Themes:**
  - Instant Light Mode / Dark Mode switching.
  - 6 vibrant accent color themes (Emerald, Blue, Violet, Rose, Amber, Teal).
- **Data Privacy & Portability:**
  - Completely local persistence using `shared_preferences`.
  - Full JSON backup export (copy to clipboard) and 1-tap JSON restore.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── main.dart                          # Root app entrypoint, MultiProvider, theme routing
├── core/
│   ├── constants.dart                 # Color palettes, accent swatches, storage keys
│   ├── theme.dart                     # Material 3 dynamic theme generator
│   └── utils.dart                     # Mifflin-St Jeor nutrition calculator & date helpers
├── data/
│   └── food_database.dart             # 200+ built-in food items with verified macros
├── models/
│   ├── ai_message.dart                # Chat messages and suggested food vision options
│   ├── daily_log.dart                 # Daily food log aggregate entity
│   ├── exercise_entry.dart            # Logged workout/exercise entry
│   ├── food_entry.dart                # Logged food item with meal type & macros
│   ├── food_item.dart                 # Food database item entity
│   ├── user_profile.dart              # User profile, goals, biometrics, settings
│   └── weight_entry.dart              # Weight tracking history entry
├── providers/
│   ├── app_provider.dart              # Global app state, logs, profile, theme, persistence
│   └── ai_chat_provider.dart          # AI chat sessions, Gemini photo vision analyzer
├── services/
│   ├── ai_service.dart                # Google Gemini API connector (chat, vision, tips)
│   └── storage_service.dart           # SharedPreferences JSON persistence layer
└── screens/
    ├── home/
    │   ├── home_screen.dart           # Core daily dashboard view
    │   └── widgets/                   # Modular home cards (Ring, Macros, Water, Spark, Meals)
    ├── stats/
    │   └── stats_screen.dart          # Weekly bar chart, macro pie chart, weight history
    ├── chat/
    │   └── ai_chat_screen.dart        # AI Nutritionist chatbot & camera photo analyzer
    ├── profile/
    │   └── profile_screen.dart        # Biometrics calculator, themes, API keys, data backup
    ├── onboarding/
    │   └── onboarding_screen.dart     # 4-step interactive onboarding calculation flow
    ├── log/
    │   ├── add_food_modal.dart        # Search database & manual food logging modal
    │   └── add_exercise_modal.dart    # Exercise & workout logging modal with AI burn estimation
    └── main_navigation_screen.dart    # Frosted bottom navigation bar with quick add action
```

---

## 🚀 How to Run & Build

### Prerequisites:
- **Flutter SDK:** `>= 3.0.0 < 4.0.0`
- **Android Studio / Xcode** for mobile emulation or deployment

### Running Locally:
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run on connected device or simulator
flutter run
```

### Building Release APK:
```bash
flutter build apk --release
```

### Continuous Integration (CI):
The repository contains `.github/workflows/build_pipeline.yml` which automatically compiles unsigned Android Release APKs and uploads them as build artifacts on push.
