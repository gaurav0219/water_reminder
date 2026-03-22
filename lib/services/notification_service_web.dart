class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Web notifications not supported in this app
  }

  Future<void> scheduleSleepAwareReminders({
    required int intervalHours,
    required String wakeTimeStr,
    required String sleepTimeStr,
    bool isSoundEnabled = true,
    bool isVibrationEnabled = true,
  }) async {
    // Web notifications not supported
  }

  Future<void> cancelAll() async {
    // Web notifications not supported
  }
}
