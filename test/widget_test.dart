import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder/providers/settings_provider.dart';
import 'package:water_reminder/providers/water_provider.dart';
import 'package:water_reminder/screens/main_navigation_screen.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Create providers
    final settingsProvider = SettingsProvider();
    final waterProvider = WaterProvider();

    // Build our app with providers and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settingsProvider),
          ChangeNotifierProvider.value(value: waterProvider),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    // Verify that the app builds a MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });
}
