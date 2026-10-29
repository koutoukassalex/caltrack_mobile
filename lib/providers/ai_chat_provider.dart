import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ai_message.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../services/ai_service.dart';

class AIChatProvider extends ChangeNotifier {
  final List<AIMessage> _messages = [
    AIMessage(
      id: 'welcome_1',
      text:
          "👋 Hello! I'm your CaLtrack AI Nutritionist. Ask me about your meals, recipes, macro balance, or tap the camera icon to identify any food from a photo!",
      isUser: false,
    ),
  ];

  bool _isThinking = false;

  List<AIMessage> get messages => _messages;
  bool get isThinking => _isThinking;

  Future<void> sendMessage({
    required String text,
    required UserProfile profile,
    required DailyLog todayLog,
  }) async {
    if (text.trim().isEmpty) return;

    final userMsg = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
    );
    _messages.add(userMsg);
    _isThinking = true;
    notifyListeners();

    try {
      final reply = await AIService.askAI(
        prompt: text,
        profile: profile,
        todayLog: todayLog,
      );

      _messages.add(
        AIMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: reply,
          isUser: false,
        ),
      );
    } catch (e) {
      _messages.add(
        AIMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text: "Sorry, I ran into an error: ${e.toString()}",
          isUser: false,
        ),
      );
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  Future<void> analyzePhoto({
    required File imageFile,
    required UserProfile profile,
  }) async {
    final imagePath = imageFile.path;
    final userMsg = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: "📸 Analyzed food photo",
      isUser: true,
      imagePath: imagePath,
    );
    _messages.add(userMsg);
    _isThinking = true;
    notifyListeners();

    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = imagePath.endsWith('.png') ? 'image/png' : 'image/jpeg';

      final options = await AIService.analyzeFoodPhoto(
        base64Image: base64String,
        mimeType: mimeType,
        profile: profile,
      );

      _messages.add(
        AIMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text:
              "I identified this meal! Here are the estimated nutritional breakdowns. Tap one to log it directly to your diary:",
          isUser: false,
          foodOptions: options,
        ),
      );
    } catch (e) {
      _messages.add(
        AIMessage(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          text:
              "Could not analyze image accurately. Error: ${e.toString()}",
          isUser: false,
        ),
      );
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add(
      AIMessage(
        id: 'welcome_new',
        text: "Chat cleared! How can I help with your nutrition today?",
        isUser: false,
      ),
    );
    notifyListeners();
  }
}
