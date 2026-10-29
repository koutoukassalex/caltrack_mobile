# 🥑 CaLtrack-AI — Complete System Overview & Feature Guide

> **Production-Grade AI-Powered Calorie, Macro, and Weight Loss Pace Tracker for Android & iOS**  
> *Built with Flutter • Material 3 • Google Gemini Vision & AI Coach • Offline-First Persistence*

---

## 📖 What is CaLtrack-AI?

**CaLtrack-AI** is a mobile health, nutrition, and body composition application designed to eliminate the friction of traditional calorie counting. 

Instead of tedious manual entry, CaLtrack-AI integrates **multimodal AI computer vision** to detect food from photos, calculates personalized energy expenditure using clinical **Mifflin-St Jeor biometrics**, allows users to choose **how fast they want to lose weight per week**, tracks daily progress with mood and energy indicators, and provides **intelligent coaching messages** that evaluate whether the user is on track, in a surplus, undereating, or in a temporary scale plateau.

---

## 🌟 Core Features & Modules

### 1. ⚡ Choose Your Weekly Loss Speed (Pace Selector)
Users have total control over their weight loss or muscle gain timeline:
* **Custom Pace Options**:
  * 🐢 **Relaxed:** `-0.25 kg / week` (mild `-275 kcal/day` deficit)
  * ⚡ **Standard (Recommended):** `-0.50 kg / week` (`-550 kcal/day` deficit)
  * 🔥 **Active:** `-0.75 kg / week` (`-825 kcal/day` deficit)
  * 🚀 **Aggressive:** `-1.00 kg / week` (`-1,100 kcal/day` deficit)
* **Interactive Fine-Tuning Slider:** Adjust anywhere from `0.10` to `1.50 kg / week`.
* **Scientific Formula:** Grounded in energy balance:
  $$\text{Daily Deficit} = \frac{\text{Weekly Pace (kg)} \times 7,700\text{ kcal}}{7} = \text{Weekly Pace} \times 1,100\text{ kcal/day}$$
* **Metabolic Floor Protection:** Enforces minimum safe calorie intake ($1,200\text{ kcal}$ for females, $1,500\text{ kcal}$ for males) to prevent metabolic slowdown.
* **Goal Milestone Estimator:** Automatically projects the estimated number of weeks and exact target date to reach the user's goal weight.

---

### 2. 📝 Dedicated "Progress" Tab & Daily Logging Hub
The navigation bar features a dedicated **Progress** tab (`Icons.trending_up_rounded`) dedicated to body composition tracking:
* **Quick Progress Logger:**
  * One-tap weight entry with numeric stepper (`-0.1` and `+0.1 kg`).
  * Date picker to record today's weigh-in or backfill past dates.
  * **Daily Feeling & Energy Selector:**
    * 🚀 *High Energy*
    * 😊 *Great & Light*
    * ⚖️ *Consistent*
    * 🥱 *Fatigued / Sore*
    * 💧 *Water Retention / Bloated*
  * **Reflection Notes:** Log notes like *"Morning fasted weigh-in, post-leg day"*.
* **Weigh-in History List:** Chronological card list showing weigh-in date, body weight, diff compared to previous weigh-in (e.g., `-0.4 kg` 📉), feeling tag, notes, and delete capability.

---

### 3. 🧠 Smart Coaching Feedback Engine ("Doing Good or Not")
Powered by the intelligent `ProgressEvaluator` engine, the app actively assesses calorie adherence and weight velocity against the user's chosen speed:

| Status Badge | Condition | Coaching Feedback Message |
| :--- | :--- | :--- |
| 🟢 **On Track (Optimal)** | Actual deficit within $\pm 15\%$ of chosen target pace | *"Crushing It! Your average daily deficit matches your chosen weekly pace. At this rate, you're projected to hit your goal weight right on schedule!"* |
| 🟡 **Needs Adjustment** | Intake is over budget, reducing weekly deficit | *"Intake is slightly over your target budget (~280 kcal above deficit). Quick fix: Watch liquid calories, trim salad oils, and add a 20-min post-dinner walk!"* |
| 🔵 **Eating Too Little** | Calories below safe floor or deficit $> 1,200\text{ kcal}$ | *"Careful: Calorie deficit is too aggressive. Undereating slows down metabolism and burns muscle. Fuel up with clean healthy fats or protein today."* |
| 🟣 **Plateau Notice** | Scale unchanged for $7+$ days despite deficit | *"Temporary scale stall. Muscle inflammation and water retention often mask fat loss for 1–2 weeks. Trust the math—the scale drop will follow!"* |
| 🏆 **Milestone Achieved** | Reached a 2.5 kg loss mark or 50%/75% goal | *"Milestone celebration! You've completed a major portion of your journey. Celebrate your discipline with a non-food reward!"* |
| ⚪ **Need More Data** | Fewer than 2 days logged this week | *"Log more meals to unlock full AI insights. Consistent logging is the #1 predictor of long-term body recomposition success."* |

---

### 4. 📊 Rich Statistics & Interactive Analytics
* **Goal Journey Milestone Tracker:**
  * Starting Weight $\rightarrow$ Current Weight $\rightarrow$ Goal Weight.
  * Animated progress bar with percentage complete and kilograms remaining.
* **Interactive Weight History Chart:**
  * Powered by `fl_chart` with smooth bezier curve interpolation.
  * Dashed horizontal green reference line for target goal weight.
  * Timeframe filter chips: **7D**, **30D**, **90D**, **ALL**.
* **Weekly Calorie Adherence Bar Chart:**
  * 7-day intake breakdown color-coded by adherence:
    * 🟢 Green: Within deficit target
    * 🟡 Amber: Borderline / near maintenance
    * 🔴 Red: Caloric surplus
* **Macronutrient Ratio Breakdown:**
  * Protein, Carbohydrate, and Fat intake averages vs daily gram targets.

---

### 5. 📸 Multimodal AI Food Scanner (Gemini Vision)
* Take a photo or upload an image of any meal.
* Google Gemini 1.5/2.0 Flash scans the visual components, estimates serving sizes, identifies macronutrients, and returns structured suggestions.
* Add detected items with 1-tap directly to Breakfast, Lunch, Dinner, or Snacks.

---

### 6. 🤖 Interactive AI Nutritionist Coach
* Context-grounded nutritional assistant.
* Automatically incorporates the user's name, biometrics, target goals, calories eaten, and burned energy into each prompt.
* Provides tailored meal suggestions, recipes, and motivation.

---

### 7. 🎨 Personalization & Aesthetics
* **Dynamic Material 3 UI:** Custom cards, fluid animations, and clean contrast.
* **Dark Mode & Light Mode:** Seamless toggle.
* **6 Accent Palettes:** Emerald, Electric Blue, Violet, Rose, Amber, Teal.
* **100% Offline-First:** Fast local storage via `shared_preferences` with JSON export/import backup.

---

## 📂 Architecture & Directory Map

```
lib/
├── main.dart                           # App entry point, MultiProvider & Theme routing
├── core/
│   ├── constants.dart                  # Accent palettes, UI tokens, storage keys
│   ├── theme.dart                      # Material 3 theme configurations
│   ├── utils.dart                      # Mifflin-St Jeor equation & weekly pace math
│   └── progress_evaluator.dart         # Smart coaching & progress feedback engine
├── data/
│   └── food_database.dart              # 200+ built-in foods with verified calories & macros
├── models/
│   ├── ai_message.dart                 # AI chat messages & suggested food items
│   ├── daily_log.dart                  # Daily food diary & water aggregate entity
│   ├── exercise_entry.dart             # Workout logging model
│   ├── food_entry.dart                 # Meal entry model with macros
│   ├── food_item.dart                  # Food database item model
│   ├── user_profile.dart               # User biometrics, weekly pace & goal targets
│   └── weight_entry.dart               # Weigh-in entry with mood & reflection notes
├── providers/
│   ├── app_provider.dart               # Global app state, logging methods, persistence
│   └── ai_chat_provider.dart           # AI chat state & Gemini vision photo analyzer
├── screens/
│   ├── main_navigation_screen.dart     # 4-tab bottom navigation (Home, Progress, AI, Profile)
│   ├── home/
│   │   └── home_screen.dart            # Calorie ring, budget math, macros, hydration
│   ├── stats/
│   │   └── stats_screen.dart           # Progress Hub: smart feedback, charts, log modal
│   ├── chat/
│   │   └── ai_chat_screen.dart         # AI Nutritionist Coach chat interface
│   ├── profile/
│   │   └── profile_screen.dart         # Weekly pace slider, biometrics, themes, backup
│   ├── onboarding/
│   │   └── onboarding_screen.dart      # 3-step setup wizard with BMR & TDEE calculation
│   └── log/
│       ├── add_food_modal.dart         # Database food search & custom entry
│       └── add_exercise_modal.dart     # Workout logger with burned calories
└── services/
    ├── ai_service.dart                 # Gemini API & OpenRouter fallback integration
    └── storage_service.dart            # Local persistence & JSON export/import
```

---

## 🛠️ GitHub Actions Build & Release

The repository includes an automated CI/CD pipeline at `.github/workflows/build_pipeline.yml`:
* Automatically runs on pushes to `main`.
* Sets up Java 17, Flutter stable, and Android SDK build tools.
* Compiles release-mode APK with full R8 code shrinking and resource optimization.
* Produces ready-to-install Android APK artifact: `caltrack-ai-android-apk`.
