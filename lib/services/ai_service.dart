import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/ai_message.dart';

class AIService {
  static const String defaultGeminiKey =
      'AIzaSyCop9pBfm-Hxbbqu4o4GGjwjJ5gcXptUMU';

  static const List<String> geminiModels = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
  ];

  /// Get active API key (user-configured or default)
  static String getActiveKey(String? userKey) {
    if (userKey != null && userKey.trim().isNotEmpty) {
      return userKey.trim();
    }
    return defaultGeminiKey;
  }

  /// System context prompt builder
  static String buildSystemPrompt({
    required UserProfile profile,
    required DailyLog todayLog,
  }) {
    return '''
You are the CaLtrack-AI Coach & Certified Sports Nutritionist.
User Name: ${profile.name}
Goal: ${profile.goal.name.toUpperCase()}
Daily Goals:
- Target Calories: ${profile.targetCalories.round()} kcal
- Target Protein: ${profile.targetProtein.round()}g
- Target Carbs: ${profile.targetCarbs.round()}g
- Target Fat: ${profile.targetFat.round()}g
- Target Water: ${profile.targetWaterMl}ml

Today's Progress:
- Calories Eaten: ${todayLog.totalCalories.round()} kcal
- Calories Burned: ${todayLog.totalBurnedCalories.round()} kcal
- Net Calories: ${todayLog.netCalories.round()} kcal
- Protein: ${todayLog.totalProtein.round()}g / ${profile.targetProtein.round()}g
- Carbs: ${todayLog.totalCarbs.round()}g / ${profile.targetCarbs.round()}g
- Fat: ${todayLog.totalFat.round()}g / ${profile.targetFat.round()}g
- Water: ${todayLog.waterMl}ml / ${profile.targetWaterMl}ml

Abilities:
- Identify food & calculate macros accurately.
- Provide advice for macro-friendly recipes and healthy substitutions.
- Estimate exercise calories burned based on body stats.
- Keep answers encouraging, concise, actionable, and formatted nicely.
''';
  }

  /// Ask general AI question with context
  static Future<String> askAI({
    required String prompt,
    required UserProfile profile,
    required DailyLog todayLog,
  }) async {
    final systemPrompt = buildSystemPrompt(profile: profile, todayLog: todayLog);
    final fullPrompt = '$systemPrompt\n\nUser Question: $prompt';
    final apiKey = getActiveKey(profile.geminiApiKey);

    // Try Gemini models first
    for (final model in geminiModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': fullPrompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null &&
              (data['candidates'] as List).isNotEmpty) {
            final text =
                data['candidates'][0]['content']['parts'][0]['text'] as String;
            return text.trim();
          }
        }
      } catch (_) {
        // Try next model
      }
    }

    // Fallback: OpenRouter
    return await _callOpenRouter(fullPrompt);
  }

  /// Analyze food photo and extract suggested food options
  static Future<List<SuggestedFoodOption>> analyzeFoodPhoto({
    required String base64Image,
    required String mimeType,
    required UserProfile profile,
  }) async {
    final apiKey = getActiveKey(profile.geminiApiKey);
    const prompt = '''
Identify the food in this image. Provide 3 likely options with estimated portion (g), calories (kcal), protein (g), carbs (g), and fat (g), and appropriate meal type (breakfast, lunch, dinner, or snacks), and an emoji.
Format the output strictly as a JSON array of objects with keys: name, portion, calories, protein, carbs, fat, mealType, emoji.
Example:
[
  {"name": "Grilled Chicken Caesar Salad", "portion": 250, "calories": 380, "protein": 34, "carbs": 12, "fat": 22, "mealType": "lunch", "emoji": "🥗"},
  {"name": "Garden Salad with Dressing", "portion": 200, "calories": 220, "protein": 4, "carbs": 16, "fat": 15, "mealType": "lunch", "emoji": "🥗"}
]
Return ONLY the JSON array without backticks or markdown.
''';

    for (final model in geminiModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt},
                  {
                    'inline_data': {
                      'mime_type': mimeType,
                      'data': base64Image,
                    }
                  }
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['candidates'] != null &&
              (data['candidates'] as List).isNotEmpty) {
            String raw =
                data['candidates'][0]['content']['parts'][0]['text'] as String;
            raw = raw.replaceAll('```json', '').replaceAll('```', '').trim();
            final List<dynamic> list = jsonDecode(raw);
            return list
                .map((item) =>
                    SuggestedFoodOption.fromJson(item as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {
        // Try next model
      }
    }

    // Default mock suggestion if network/API limits reached
    return [
      SuggestedFoodOption(
        name: 'Detected Meal',
        calories: 450,
        protein: 28,
        carbs: 45,
        fat: 16,
        grams: 300,
        emoji: '🍽️',
      ),
    ];
  }

  /// Estimate calories burned for exercise
  static Future<double> estimateExerciseCalories({
    required String activityName,
    required int durationMinutes,
    required double userWeightKg,
    required UserProfile profile,
  }) async {
    final apiKey = getActiveKey(profile.geminiApiKey);
    final prompt =
        'Estimate calories burned for a ${userWeightKg.round()}kg person doing "$activityName" for $durationMinutes minutes. Respond only with the single integer number of kcal burned, nothing else.';

    for (final model in ['gemini-2.0-flash', 'gemini-1.5-flash']) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text =
              data['candidates'][0]['content']['parts'][0]['text'] as String;
          final match = RegExp(r'\d+').firstMatch(text);
          if (match != null) {
            return double.tryParse(match.group(0)!) ?? 200.0;
          }
        }
      } catch (_) {}
    }

    // Fallback formula: ~7 MET average
    return ((7 * 3.5 * userWeightKg) / 200) * durationMinutes;
  }

  /// Daily nutrition spark tip
  static Future<String> getDailySparkTip({
    required UserProfile profile,
    required DailyLog todayLog,
  }) async {
    final remainingCals = (profile.targetCalories - todayLog.netCalories).round();
    final remainingProtein = (profile.targetProtein - todayLog.totalProtein).round();

    final prompt = '''
Give a 1-sentence quick, encouraging daily nutrition or fitness spark tip for ${profile.name}.
Target: ${profile.targetCalories.round()} kcal. Remaining today: $remainingCals kcal, $remainingProtein g protein.
Keep it punchy, motivating, and include 1 emoji. Maximum 18 words.
''';

    try {
      final res = await askAI(
        prompt: prompt,
        profile: profile,
        todayLog: todayLog,
      );
      return res.replaceAll('"', '').trim();
    } catch (_) {
      return 'Stay hydrated and hit your protein target today! 💪';
    }
  }

  /// OpenRouter fallback
  static Future<String> _callOpenRouter(String prompt) async {
    try {
      final url =
          Uri.parse('https://openrouter.ai/api/v1/chat/completions');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openRouterKey',
        },
        body: jsonEncode({
          'model': 'meta-llama/llama-3.2-3b-instruct:free',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['choices'][0]['message']['content'] as String;
      }
    } catch (_) {}
    return "I'm having trouble connecting to AI services right now. Please check your internet connection or update your Gemini API key in settings.";
  }
}
