import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/ai_chat_provider.dart';
import '../../models/ai_message.dart';
import '../../models/food_entry.dart';
import '../../core/constants.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final aiProvider = Provider.of<AIChatProvider>(context, listen: false);

    _scrollToBottom();
    await aiProvider.sendMessage(
      text: text,
      profile: appProvider.profile,
      todayLog: appProvider.currentLog,
    );
    _scrollToBottom();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        final aiProvider = Provider.of<AIChatProvider>(context, listen: false);

        _scrollToBottom();
        await aiProvider.analyzePhoto(
          imageFile: File(picked.path),
          profile: appProvider.profile,
        );
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load image: ${e.toString()}')),
      );
    }
  }

  void _logSuggestedFood(SuggestedFoodOption opt, MealType meal) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: opt.name,
      mealType: meal,
      calories: opt.calories,
      protein: opt.protein,
      carbs: opt.carbs,
      fat: opt.fat,
      grams: opt.grams,
      emoji: opt.emoji,
    );

    appProvider.addFood(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged ${opt.name} to ${meal.displayName}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appProvider = Provider.of<AppProvider>(context);
    final aiProvider = Provider.of<AIChatProvider>(context);
    final accentColor = appProvider.currentAccentColor;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 16, color: accentColor),
            ),
            const SizedBox(width: 8),
            const Text('AI Nutritionist'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Gemini AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: aiProvider.messages.length + (aiProvider.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == aiProvider.messages.length && aiProvider.isThinking) {
                  return _buildThinkingBubble(context, accentColor);
                }
                final msg = aiProvider.messages[index];
                return _buildMessageItem(context, msg, accentColor);
              },
            ),
          ),

          // Quick Starter Prompt Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPromptChip('🥩 High-protein snacks', accentColor),
                _buildPromptChip('🥗 500 kcal dinner idea', accentColor),
                _buildPromptChip('📊 Review my daily macros', accentColor),
                _buildPromptChip('🥑 Good fats to hit goal', accentColor),
                _buildPromptChip('🥤 Post-workout shake', accentColor),
              ],
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
              ),
            ),
            child: Row(
              children: [
                // Camera Button
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  color: accentColor,
                  tooltip: 'Take Food Photo',
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                // Gallery Button
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined),
                  color: accentColor,
                  tooltip: 'Upload Food Photo',
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                // Text Field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
                    ),
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: const InputDecoration(
                        hintText: 'Ask or snap a photo of food...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send Button
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        backgroundColor: Theme.of(context).cardColor,
        side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          _textController.text = label.substring(label.indexOf(' ') + 1);
          _handleSend();
        },
      ),
    );
  }

  Widget _buildThinkingBubble(BuildContext context, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 16, color: accentColor),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Analyzing with Gemini...',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, AIMessage msg, Color accentColor) {
    final theme = Theme.of(context);
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_outlined, size: 18, color: accentColor),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Attached Photo Preview
                if (msg.imagePath != null && File(msg.imagePath!).existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(msg.imagePath!),
                      width: 200,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Message Text Bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? accentColor : theme.cardColor,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                      bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: theme.dividerColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : theme.colorScheme.onBackground,
                      height: 1.4,
                    ),
                  ),
                ),

                // Identified Food Options Cards
                if (msg.foodOptions != null && msg.foodOptions!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...msg.foodOptions!.map((opt) {
                    return _buildFoodOptionCard(context, opt, accentColor);
                  }).toList(),
                ],

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    DateFormat('h:mm a').format(msg.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onBackground.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildFoodOptionCard(BuildContext context, SuggestedFoodOption opt, Color accentColor) {
    final theme = Theme.of(context);
    MealType selectedMeal = opt.suggestedMeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(opt.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    opt.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${opt.calories.round()} kcal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroChip('P: ${opt.protein.round()}g', AppConstants.proteinColor),
              _buildMacroChip('C: ${opt.carbs.round()}g', AppConstants.carbsColor),
              _buildMacroChip('F: ${opt.fat.round()}g', AppConstants.fatColor),
              _buildMacroChip('${opt.grams.round()}g', theme.colorScheme.onBackground.withOpacity(0.6)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: Text('Log to ${selectedMeal.displayName}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _logSuggestedFood(opt, selectedMeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
