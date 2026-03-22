import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/water_record.dart';

class StorageService {
  static const String _settingsKey = 'app_settings';
  static const String _recordsKey = 'water_records';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      try {
        return AppSettings.fromJson(jsonDecode(settingsJson));
      } catch (e) {
        debugPrint("Error parsing settings: $e");
      }
    }
    return AppSettings(); // Default settings
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<List<WaterRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_recordsKey);
    
    if (recordsJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(recordsJson);
        return decodedList.map((item) => WaterRecord.fromJson(item)).toList();
      } catch (e) {
        debugPrint("Error parsing water records: $e");
      }
    }
    return [];
  }

  Future<void> saveRecords(List<WaterRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final String recordsJson = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_recordsKey, recordsJson);
  }
}
