import 'package:flutter/foundation.dart';
import '../models/water_record.dart';
import '../models/beverage_type.dart';
import '../services/storage_service.dart';

class WaterProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<WaterRecord> _records = [];

  List<WaterRecord> get records => _records;

  Future<void> loadRecords() async {
    _records = await _storageService.loadRecords();
    notifyListeners();
  }

  int getTodayIntake() {
    final now = DateTime.now();
    return _records
        .where((r) => 
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month &&
            r.timestamp.day == now.day)
        .fold(0, (sum, record) => sum + (record.amountInMl * record.beverageType.hydrationMultiplier).round());
  }

  double getTodayProgress(int dailyGoal) {
    if (dailyGoal == 0) return 0;
    return (getTodayIntake() / dailyGoal).clamp(0.0, 1.0);
  }

  int getCurrentStreak(int dailyGoal) {
    if (dailyGoal == 0) return 0;
    if (_records.isEmpty) return 0;
    
    final Map<DateTime, int> dailyIntake = {};
    for (var r in _records) {
      final date = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
      final hydration = (r.amountInMl * r.beverageType.hydrationMultiplier).round();
      dailyIntake[date] = (dailyIntake[date] ?? 0) + hydration;
    }

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    
    bool todayMet = (dailyIntake[checkDate] ?? 0) >= dailyGoal;
    if (todayMet) streak++;
    
    checkDate = checkDate.subtract(const Duration(days: 1));
    while (true) {
      if ((dailyIntake[checkDate] ?? 0) >= dailyGoal) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<void> addWater(int amountInMl, {BeverageType beverageType = BeverageType.water}) async {
    final record = WaterRecord(
      timestamp: DateTime.now(),
      amountInMl: amountInMl,
      beverageType: beverageType,
    );
    _records.add(record);
    await _storageService.saveRecords(_records);
    notifyListeners();
  }
  
  /// Delete a single record by its unique ID.
  Future<void> deleteRecord(String recordId) async {
    _records.removeWhere((r) => r.id == recordId);
    await _storageService.saveRecords(_records);
    notifyListeners();
  }

  /// Remove the most recent record added today (undo).
  Future<void> removeLastRecord() async {
    if (_records.isNotEmpty) {
      final now = DateTime.now();
      final todayRecords = _records.where((r) => 
          r.timestamp.year == now.year &&
          r.timestamp.month == now.month &&
          r.timestamp.day == now.day).toList();
          
      if (todayRecords.isNotEmpty) {
        todayRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _records.remove(todayRecords.first);
        await _storageService.saveRecords(_records);
        notifyListeners();
      }
    }
  }

  /// Clear ALL history records. Does NOT touch app settings.
  Future<void> clearAllRecords() async {
    _records.clear();
    await _storageService.saveRecords(_records);
    notifyListeners();
  }

  Map<DateTime, int> getWeeklyIntake() {
    final Map<DateTime, int> weeklyData = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      weeklyData[date] = 0;
    }

    for (var record in _records) {
      final recordDate = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      if (weeklyData.containsKey(recordDate)) {
        weeklyData[recordDate] = weeklyData[recordDate]! + (record.amountInMl * record.beverageType.hydrationMultiplier).round();
      }
    }

    return weeklyData;
  }
}
