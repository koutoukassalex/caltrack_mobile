import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/daily_log.dart';
import '../models/weight_entry.dart';
import '../core/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // User Profile
  static Future<bool> saveProfile(UserProfile profile) async {
    await init();
    final jsonStr = jsonEncode(profile.toJson());
    return await _prefs!.setString(AppConstants.keyProfile, jsonStr);
  }

  static Future<UserProfile?> getProfile() async {
    await init();
    final jsonStr = _prefs!.getString(AppConstants.keyProfile);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserProfile.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  // Daily Logs (stored as Map of dateKey -> DailyLog JSON)
  static Future<DailyLog> getDailyLog(String dateKey) async {
    await init();
    final allLogs = await getAllLogs();
    if (allLogs.containsKey(dateKey)) {
      return allLogs[dateKey]!;
    }
    return DailyLog(date: dateKey);
  }

  static Future<Map<String, DailyLog>> getAllLogs() async {
    await init();
    final jsonStr = _prefs!.getString(AppConstants.keyLogs);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final Map<String, dynamic> rawMap = jsonDecode(jsonStr);
      final Map<String, DailyLog> logs = {};
      rawMap.forEach((key, val) {
        logs[key] = DailyLog.fromJson(val as Map<String, dynamic>);
      });
      return logs;
    } catch (e) {
      return {};
    }
  }

  static Future<bool> saveDailyLog(DailyLog log) async {
    await init();
    final allLogs = await getAllLogs();
    allLogs[log.date] = log;
    final Map<String, dynamic> rawMap = {};
    allLogs.forEach((key, value) {
      rawMap[key] = value.toJson();
    });
    return await _prefs!.setString(AppConstants.keyLogs, jsonEncode(rawMap));
  }

  // Weight Logs
  static Future<List<WeightEntry>> getWeightEntries() async {
    await init();
    final jsonStr = _prefs!.getString(AppConstants.keyWeight);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addWeightEntry(WeightEntry entry) async {
    await init();
    final entries = await getWeightEntries();
    // Replace if same date exists, else append
    entries.removeWhere((e) =>
        e.date.year == entry.date.year &&
        e.date.month == entry.date.month &&
        e.date.day == entry.date.day);
    entries.add(entry);
    entries.sort((a, b) => a.date.compareTo(b.date));
    return await _prefs!.setString(
      AppConstants.keyWeight,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }

  // Backup & Restore
  static Future<String> exportBackupJson() async {
    await init();
    final profile = await getProfile();
    final logs = await getAllLogs();
    final weight = await getWeightEntries();

    final exportMap = {
      'exported_at': DateTime.now().toIso8601String(),
      'profile': profile?.toJson(),
      'logs': logs.map((k, v) => MapEntry(k, v.toJson())),
      'weight': weight.map((w) => w.toJson()).toList(),
    };
    return jsonEncode(exportMap);
  }

  static Future<bool> importBackupJson(String jsonString) async {
    try {
      await init();
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map.containsKey('profile') && map['profile'] != null) {
        await saveProfile(UserProfile.fromJson(map['profile']));
      }
      if (map.containsKey('logs') && map['logs'] != null) {
        await _prefs!.setString(AppConstants.keyLogs, jsonEncode(map['logs']));
      }
      if (map.containsKey('weight') && map['weight'] != null) {
        await _prefs!.setString(AppConstants.keyWeight, jsonEncode(map['weight']));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}
