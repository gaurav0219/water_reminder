import 'package:flutter/material.dart';

class AppSettings {
  final int dailyGoalMl;
  final int reminderIntervalHours;
  final bool isReminderEnabled;
  final bool isOunces;
  final String wakeUpTime; // Format: "HH:mm"
  final String sleepTime;  // Format: "HH:mm"
  final ThemeMode themeMode; // Format: ThemeMode enum
  final bool isSoundEnabled;
  final bool isVibrationEnabled;

  AppSettings({
    this.dailyGoalMl = 2500,
    this.reminderIntervalHours = 2,
    this.isReminderEnabled = true,
    this.isOunces = false,
    this.wakeUpTime = "08:00",
    this.sleepTime = "22:00",
    this.themeMode = ThemeMode.system,
    this.isSoundEnabled = true,
    this.isVibrationEnabled = true,
  });

  AppSettings copyWith({
    int? dailyGoalMl,
    int? reminderIntervalHours,
    bool? isReminderEnabled,
    bool? isOunces,
    String? wakeUpTime,
    String? sleepTime,
    ThemeMode? themeMode,
    bool? isSoundEnabled,
    bool? isVibrationEnabled,
  }) {
    return AppSettings(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      reminderIntervalHours: reminderIntervalHours ?? this.reminderIntervalHours,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      isOunces: isOunces ?? this.isOunces,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
      sleepTime: sleepTime ?? this.sleepTime,
      themeMode: themeMode ?? this.themeMode,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyGoalMl': dailyGoalMl,
        'reminderIntervalHours': reminderIntervalHours,
        'isReminderEnabled': isReminderEnabled,
        'isOunces': isOunces,
        'wakeUpTime': wakeUpTime,
        'sleepTime': sleepTime,
        'themeMode': themeMode.index,
        'isSoundEnabled': isSoundEnabled,
        'isVibrationEnabled': isVibrationEnabled,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailyGoalMl: json['dailyGoalMl'] ?? 2500,
      reminderIntervalHours: json['reminderIntervalHours'] ?? 2,
      isReminderEnabled: json['isReminderEnabled'] ?? true,
      isOunces: json['isOunces'] ?? false,
      wakeUpTime: json['wakeUpTime'] ?? "08:00",
      sleepTime: json['sleepTime'] ?? "22:00",
      themeMode: json['themeMode'] != null
          ? ThemeMode.values[json['themeMode']]
          : ThemeMode.system,
      isSoundEnabled: json['isSoundEnabled'] ?? true,
      isVibrationEnabled: json['isVibrationEnabled'] ?? true,
    );
  }
}
