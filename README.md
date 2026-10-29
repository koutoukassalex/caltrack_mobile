# 🥑 CaLtrack-AI — AI Calorie & Macro Tracker (Flutter Mobile)

<p align="center">
  <b>Production-Grade AI-Powered Calorie, Macro, and Hydration Tracking for iOS & Android</b><br>
  Built with Flutter • Material 3 Design • Gemini AI Vision & Coaching • Offline-First Persistence
</p>

---

## 📱 Features & Highlights

- **Customizable Weekly Loss Speed (Pace Selector):**
  - Choose how fast you want to lose or gain weight per week (0.25 kg, 0.50 kg, 0.75 kg, 1.00 kg/wk or custom slider).
  - Automatically recalculates daily calorie deficit (`weekly_rate * 1,100 kcal`) and macro targets.
  - Computes exact projected weeks and target date to reach your goal weight.
- **Dedicated Progress Hub & Weigh-In Logger:**
  - Dedicated tab to log daily progress with weight stepper (`+/- 0.1 kg`), date picker, mood/energy state chips (🚀 High Energy, 😊 Great, ⚖️ Consistent, 🥱 Fatigued, 💧 Bloated), and reflection notes.
  - Complete historical weigh-in log with delta weight change (`-0.4 kg` 📉).
- **Smart Coaching Feedback Engine ("Doing Good or Not"):**
  - Dynamic evaluation compares actual daily deficit vs target pace.
  - Automatically assesses status: 🟢 On Track (Optimal), 🟡 Needs Adjustment (Surplus), 🔵 Eating Too Little (Floor Alert), 🟣 Plateau Notice (Water Retention), or 🏆 Milestone Achieved.
- **AI Food Vision (Gemini Flash):** Snap or upload a photo of your meal; the AI identifies food items, estimates portion weights, and breaks down calories, protein, carbs, and fats with 1-tap logging.
- **Dynamic Interactive Dashboard:**
  - Real-time **Calorie Ring** visualization showing net calories, goal, and burned calories.
  - **Daily Budget Math** row (`Base Goal + Exercise - Food = Remaining`).
  - **Macro Distribution Bars** for Protein, Carbohydrates, and Fats with target progress.
  - **Hydration Tracker** with quick +250ml cups and target progress.
  - **Quick Add Row** for instant logging of common foods.
- **Interactive AI Nutritionist Coach:** Full-featured chat assistant providing real-time personalized nutrition advice grounded in your daily food diary.
- **Detailed Stats & Analytics:**
  - Weight Trend line chart with smooth curves and target goal dotted line (7D / 30D / 90D / ALL).
  - 7-day Calorie Adherence Bar Chart color-coded by deficit status.
  - Macro Distribution breakdown (Protein, Carbs, Fat averages).
- **Personalized Biometrics & Onboarding:** Calculates exact BMR and TDEE via the **Mifflin-St Jeor equation**.
- **Customizable Aesthetics & Themes:** Instant Light/Dark mode and 6 vibrant accent themes.
- **Data Privacy & Portability:** Completely local persistence via `shared_preferences` with full JSON backup export & restore.

> 📖 **Full System Documentation:** For complete architectural specifications and deep-dive documentation, see [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md).

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
