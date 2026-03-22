import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../providers/settings_provider.dart';
import '../models/beverage_type.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _WaveBackground(),
          SafeArea(
            child: Consumer2<WaterProvider, SettingsProvider>(
              builder: (context, water, settings, _) {
                final isOz = settings.settings.isOunces;
                final unit = isOz ? 'oz' : 'ml';
                final dailyGoal = settings.settings.dailyGoalMl;
                final weeklyData = water.getWeeklyIntake();
                final isDark = Theme.of(context).brightness == Brightness.dark;

                // Compute real daily average
                int totalWeekly = weeklyData.values.fold(0, (sum, v) => sum + v);
                int daysWithData = weeklyData.values.where((v) => v > 0).length;
                int avgMl = daysWithData > 0 ? totalWeekly ~/ daysWithData : 0;
                int avgDisplay = isOz ? (avgMl / 29.5735).round() : avgMl;

                // Build per-day bar data from real records
                final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final now = DateTime.now();
                final todayWeekday = now.weekday; // 1=Mon ... 7=Sun

                // Get per-beverage breakdown per day
                final barData = <_BarDay>[];
                for (final entry in weeklyData.entries) {
                  final date = entry.key;
                  final dayIdx = date.weekday - 1; // 0=Mon ... 6=Sun
                  final dayLabel = dayNames[dayIdx];
                  final isToday = date.weekday == todayWeekday && date.day == now.day;

                  // Get records for this specific day
                  final dayRecords = water.records.where((r) =>
                    r.timestamp.year == date.year &&
                    r.timestamp.month == date.month &&
                    r.timestamp.day == date.day
                  ).toList();

                  // Group by beverage type
                  final Map<BeverageType, int> byType = {};
                  for (final r in dayRecords) {
                    byType[r.beverageType] = (byType[r.beverageType] ?? 0) + (r.amountInMl * r.beverageType.hydrationMultiplier).round();
                  }

                  // Convert to segments as fraction of daily goal
                  final segments = <_BarSegment>[];
                  if (dailyGoal > 0) {
                    for (final bev in byType.entries) {
                      final fraction = (bev.value / dailyGoal).clamp(0.0, 1.5);
                      Color segColor;
                      switch (bev.key) {
                        case BeverageType.coffee:
                          segColor = AppTheme.coffeeColor;
                          break;
                        case BeverageType.tea:
                          segColor = const Color(0xFF22C55E);
                          break;
                        case BeverageType.juice:
                          segColor = AppTheme.juiceColor;
                          break;
                        case BeverageType.soda:
                          segColor = const Color(0xFFEF4444);
                          break;
                        default:
                          segColor = AppTheme.waterColor;
                      }
                      if (fraction > 0) {
                        segments.add(_BarSegment(segColor, fraction));
                      }
                    }
                  }

                  // If no data, add a tiny placeholder
                  if (segments.isEmpty) {
                    segments.add(_BarSegment(AppTheme.waterColor.withValues(alpha: 0.15), 0.03));
                  }

                  barData.add(_BarDay(dayLabel, segments, isToday));
                }

                // Calculate goal display for the goal line label
                final goalDisplay = isOz ? (dailyGoal / 29.5735).round() : dailyGoal;
                String goalLabel;
                if (isOz) {
                  goalLabel = 'GOAL: ${goalDisplay}oz';
                } else {
                  goalLabel = dailyGoal >= 1000 ? 'GOAL: ${(dailyGoal / 1000).toStringAsFixed(1)}L' : 'GOAL: ${dailyGoal}ml';
                }

                // Compute % change vs "previous" (just based on first vs second half of the week)
                final firstHalf = weeklyData.values.take(3).fold(0, (s, v) => s + v);
                final secondHalf = weeklyData.values.skip(3).fold(0, (s, v) => s + v);
                final pctChange = firstHalf > 0 ? (((secondHalf - firstHalf) / firstHalf) * 100).round() : 0;
                final pctLabel = pctChange >= 0 ? '+$pctChange%' : '$pctChange%';

                // Determine active beverage types for legend
                final activeBevTypes = <BeverageType>{};
                for (final r in water.records) {
                  final rDate = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
                  if (weeklyData.containsKey(rDate)) {
                    activeBevTypes.add(r.beverageType);
                  }
                }

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            _buildMainStatsCard(context, isDark, barData, goalLabel, avgDisplay, unit, pctLabel),
                            const SizedBox(height: 24),
                            _buildLegend(context, isDark, activeBevTypes),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Statistics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          GlassCard(
            borderRadius: 999,
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard(BuildContext context, bool isDark, List<_BarDay> barData, String goalLabel, int avgDisplay, String unit, String pctLabel) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Weekly Hydration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$avgDisplay $unit daily average', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                child: Text('$pctLabel vs earlier', style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Chart
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Goal line at 70% height
                Positioned(bottom: 140, left: 0, right: 0, child: Row(children: [
                  Expanded(child: CustomPaint(painter: _DashedLinePainter(), child: const SizedBox(height: 1))),
                  const SizedBox(width: 8),
                  Text(goalLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue.withValues(alpha: 0.6), letterSpacing: 1.5)),
                ])),
                // Bars
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: barData.map((d) => _buildBarCol(d)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCol(_BarDay day) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: day.segments.reversed.map((s) {
                return Flexible(
                  flex: (s.fraction * 100).round().clamp(1, 150),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: day.isToday ? s.color.withValues(alpha: 0.6) : s.color,
                      borderRadius: s == day.segments.first
                          ? const BorderRadius.vertical(top: Radius.circular(4))
                          : BorderRadius.circular(2),
                      boxShadow: s.color == AppTheme.waterColor
                          ? [BoxShadow(color: AppTheme.waterColor.withValues(alpha: 0.2), offset: const Offset(0, -4), blurRadius: 12)]
                          : null,
                      border: day.isToday && s == day.segments.first
                          ? Border.all(color: AppTheme.waterColor.withValues(alpha: 0.6), width: 1)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(day.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: day.isToday ? AppTheme.primaryBlue : AppTheme.textSecondaryDark, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, bool isDark, Set<BeverageType> activeBevTypes) {
    final allLegend = <(Color, String)>[
      (AppTheme.waterColor, 'Water'),
      (AppTheme.coffeeColor, 'Coffee'),
      (const Color(0xFF22C55E), 'Tea'),
      (AppTheme.juiceColor, 'Juice'),
      (const Color(0xFFEF4444), 'Soda'),
    ];

    // Only show legend items that appear in the data, or at least Water
    final filteredLegend = allLegend.where((item) {
      if (item.$2 == 'Water') return true;
      return activeBevTypes.any((b) => b.displayName == item.$2);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filteredLegend.map((b) => Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: b.$1, shape: BoxShape.circle, boxShadow: [BoxShadow(color: b.$1.withValues(alpha: 0.5), blurRadius: 8)])),
            const SizedBox(width: 8),
            Text(b.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
          ]),
        )).toList(),
      ),
    );
  }
}

// ── Helper model classes ──
class _BarSegment {
  final Color color;
  final double fraction;
  const _BarSegment(this.color, this.fraction);
}

class _BarDay {
  final String label;
  final List<_BarSegment> segments;
  final bool isToday;
  const _BarDay(this.label, this.segments, this.isToday);
}

// ── Wave Background ──
class _WaveBackground extends StatelessWidget {
  const _WaveBackground();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0, height: 180,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.primaryBlue.withValues(alpha: 0.15), Colors.transparent]),
        ),
      ),
    );
  }
}

// ── Dashed Line Painter ──
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint = Paint()..color = AppTheme.primaryBlue.withValues(alpha: 0.4)..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
