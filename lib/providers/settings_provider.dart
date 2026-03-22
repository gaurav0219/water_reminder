import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    try {
      _settings = await _storageService.loadSettings();
    } catch (e) {
      debugPrint('loadSettings error – using defaults: $e');
      _settings = AppSettings();
    }
    try {
      await _notificationService.init();
      _updateReminders();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
    notifyListeners();
  }

  Future<void> updateGoal(int ml) async {
    _settings = _settings.copyWith(dailyGoalMl: ml);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateInterval(int hours) async {
    _settings = _settings.copyWith(reminderIntervalHours: hours);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  Future<void> toggleReminder(bool enabled) async {
    _settings = _settings.copyWith(isReminderEnabled: enabled);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  Future<void> toggleUnit(bool isOunces) async {
    _settings = _settings.copyWith(isOunces: isOunces);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateWakeUpTime(String time) async {
    _settings = _settings.copyWith(wakeUpTime: time);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  Future<void> updateSleepTime(String time) async {
    _settings = _settings.copyWith(sleepTime: time);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isCurrentlyDark) async {
    final newTheme = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    _settings = _settings.copyWith(themeMode: newTheme);
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  /// Toggle notification sound. Immediately persists and reschedules.
  Future<void> toggleSound(bool enabled) async {
    _settings = _settings.copyWith(isSoundEnabled: enabled);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  /// Toggle notification vibration. Immediately persists and reschedules.
  Future<void> toggleVibration(bool enabled) async {
    _settings = _settings.copyWith(isVibrationEnabled: enabled);
    await _storageService.saveSettings(_settings);
    _updateReminders();
    notifyListeners();
  }

  void pauseRemindersForToday() {
    _notificationService.cancelAll();
  }

  void resumeRemindersIfNeeded() {
    _updateReminders();
  }

  void _updateReminders() {
    if (_settings.isReminderEnabled) {
      _notificationService.scheduleSleepAwareReminders(
        intervalHours: _settings.reminderIntervalHours,
        wakeTimeStr: _settings.wakeUpTime,
        sleepTimeStr: _settings.sleepTime,
        isSoundEnabled: _settings.isSoundEnabled,
        isVibrationEnabled: _settings.isVibrationEnabled,
      );
    } else {
      _notificationService.cancelAll();
    }
  }
}

