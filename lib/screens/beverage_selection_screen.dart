import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/beverage_type.dart';
import '../providers/settings_provider.dart';

class BeverageSelectionScreen extends StatefulWidget {
  const BeverageSelectionScreen({super.key});

  @override
  State<BeverageSelectionScreen> createState() => _BeverageSelectionScreenState();
}

class _BeverageSelectionScreenState extends State<BeverageSelectionScreen> {
  BeverageType? _selected;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background blobs matching stitch_beverage.html
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.15), Colors.transparent], stops: const [0.0, 0.7]),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.15), Colors.transparent], stops: const [0.0, 0.7]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Select Beverage',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.3),
                        ),
                      ),
                      Container(
                        width: 48, height: 48,
                        alignment: Alignment.center,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                            shape: const CircleBorder(),
                          ),
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
                          onPressed: () => settingsProvider.toggleTheme(isDark),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        'How are you hydrating?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose a drink to calculate your progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                      ),
                    ],
                  ),
                ),

                // Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(24),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.0,
                    children: [
                      _card(context, 'Water', '1.0x Ratio', Icons.water_drop, AppTheme.waterColor, BeverageType.water, isDark),
                      _card(context, 'Coffee', '0.8x Ratio', Icons.coffee, const Color(0xFFF97316), BeverageType.coffee, isDark),
                      _card(context, 'Tea', '0.9x Ratio', Icons.emoji_food_beverage, const Color(0xFF22C55E), BeverageType.tea, isDark),
                      _card(context, 'Juice', '0.7x Ratio', Icons.local_drink, const Color(0xFFEAB308), BeverageType.juice, isDark),
                      _card(context, 'Soda', '0.5x Ratio', Icons.bubble_chart, const Color(0xFFEF4444), BeverageType.soda, isDark),
                      _customCard(context, isDark),
                    ],
                  ),
                ),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _selected != null ? () => Navigator.pop(context, _selected) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
                            disabledForegroundColor: Colors.white54,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                            shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Confirm Selection'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 128, height: 6,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, String ratio, IconData icon, Color color, BeverageType type, bool isDark) {
    final isSelected = _selected == type;
    return GestureDetector(
      onTap: () => setState(() => _selected = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03))
              : (isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.4) : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.4)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03), blurRadius: 30, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(ratio, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _customCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, {'action': 'custom', 'beverage': _selected});
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4), width: 1, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.6)),
              ),
              child: const Icon(Icons.add, color: AppTheme.primaryBlue, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('Custom', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Define', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}
