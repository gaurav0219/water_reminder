import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'providers/settings_provider.dart';
import 'providers/water_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsProvider = SettingsProvider();
  final waterProvider = WaterProvider();

  await settingsProvider.loadSettings();
  await waterProvider.loadRecords();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: waterProvider),
        ],
        child: const WaterReminderApp(),
      ),
    ),
  );
}

class WaterReminderApp extends StatefulWidget {
  const WaterReminderApp({super.key});

  @override
  State<WaterReminderApp> createState() => _WaterReminderAppState();
}

class _WaterReminderAppState extends State<WaterReminderApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final waterProvider = Provider.of<WaterProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      waterProvider.loadRecords().then((_) {
        if (mounted && waterProvider.getTodayProgress(settingsProvider.settings.dailyGoalMl) < 1.0) {
          settingsProvider.resumeRemindersIfNeeded();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().settings.themeMode;

    return MaterialApp(
      title: 'Water Reminder',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
