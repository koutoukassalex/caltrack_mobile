import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/food_entry.dart';
import '../models/exercise_entry.dart';
import '../models/weight_entry.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class AppProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  DateTime _currentDate = DateTime.now();
  DailyLog _currentLog = DailyLog(date: DateUtilsHelper.formatDateKey(DateTime.now()));
  Map<String, DailyLog> _allLogs = {};
  List<WeightEntry> _weightLogs = [];
  String _sparkTip = 'Hit your protein target and drink plenty of water today! 💧';
  bool _isLoading = true;

  // Getters
  UserProfile get profile => _profile;
  DateTime get currentDate => _currentDate;
  DailyLog get currentLog => _currentLog;
  Map<String, DailyLog> get allLogs => _allLogs;
  List<WeightEntry> get weightLogs => _weightLogs;
  String get sparkTip => _sparkTip;
  bool get isLoading => _isLoading;

  Color get currentAccentColor => AppConstants.accentColors[_profile.accentColorIndex.clamp(0, AppConstants.accentColors.length - 1)];

  AppProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.init();

    // Load Profile
    final savedProfile = await StorageService.getProfile();
    if (savedProfile != null) {
      _profile = savedProfile;
    }

    // Load Logs
    _allLogs = await StorageService.getAllLogs();
    final todayKey = DateUtilsHelper.formatDateKey(_currentDate);
    _currentLog = _allLogs[todayKey] ?? DailyLog(date: todayKey);

    // Load Weight
    _weightLogs = await StorageService.getWeightEntries();

    _isLoading = false;
    notifyListeners();

    // Fetch spark tip in background
    refreshSparkTip();
  }

  // Date Navigation
  void setDate(DateTime date) {
    _currentDate = date;
    final key = DateUtilsHelper.formatDateKey(date);
    _currentLog = _allLogs[key] ?? DailyLog(date: key);
    notifyListeners();
  }

  void previousDay() {
    setDate(_currentDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    final tomorrow = _currentDate.add(const Duration(days: 1));
    final now = DateTime.now();
    // Allow viewing up to today or future if needed
    if (tomorrow.isBefore(DateTime(now.year, now.month, now.day + 1))) {
      setDate(tomorrow);
    }
  }

  // Food Logging
  Future<void> addFood(FoodEntry entry) async {
    _currentLog.foods.add(entry);
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  Future<void> deleteFood(String id) async {
    _currentLog.foods.removeWhere((f) => f.id == id);
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  // Exercise Logging
  Future<void> addExercise(ExerciseEntry entry) async {
    _currentLog.exercises.add(entry);
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  Future<void> deleteExercise(String id) async {
    _currentLog.exercises.removeWhere((e) => e.id == id);
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  // Water Tracking
  Future<void> updateWater(int deltaMl) async {
    int updated = _currentLog.waterMl + deltaMl;
    if (updated < 0) updated = 0;
    _currentLog.waterMl = updated;
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  Future<void> setWater(int ml) async {
    _currentLog.waterMl = ml < 0 ? 0 : ml;
    _allLogs[_currentLog.date] = _currentLog;
    notifyListeners();
    await StorageService.saveDailyLog(_currentLog);
  }

  // Profile & Goals
  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await StorageService.saveProfile(_profile);
  }

  Future<void> toggleTheme() async {
    _profile = _profile.copyWith(isDarkMode: !_profile.isDarkMode);
    notifyListeners();
    await StorageService.saveProfile(_profile);
  }

  Future<void> setAccentColor(int index) async {
    _profile = _profile.copyWith(accentColorIndex: index);
    notifyListeners();
    await StorageService.saveProfile(_profile);
  }

  // Weight Logging
  Future<void> logWeight(double weightKg) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weightKg: weightKg,
      date: _currentDate,
    );
    await StorageService.addWeightEntry(entry);
    _weightLogs = await StorageService.getWeightEntries();

    // Also update current profile weight
    _profile = _profile.copyWith(weightKg: weightKg);
    await StorageService.saveProfile(_profile);
    notifyListeners();
  }

  // AI Spark Tip
  Future<void> refreshSparkTip() async {
    try {
      final tip = await AIService.getDailySparkTip(
        profile: _profile,
        todayLog: _currentLog,
      );
      _sparkTip = tip;
      notifyListeners();
    } catch (_) {}
  }

  // Backup & Reset
  Future<String> exportBackup() async {
    return await StorageService.exportBackupJson();
  }

  Future<bool> importBackup(String jsonStr) async {
    final success = await StorageService.importBackupJson(jsonStr);
    if (success) {
      await init();
    }
    return success;
  }

  Future<void> resetAll() async {
    await StorageService.clearAll();
    _profile = UserProfile();
    _allLogs.clear();
    _weightLogs.clear();
    final todayKey = DateUtilsHelper.formatDateKey(DateTime.now());
    _currentLog = DailyLog(date: todayKey);
    notifyListeners();
  }
}
