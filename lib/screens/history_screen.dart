import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../providers/settings_provider.dart';
import '../models/beverage_type.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime d) {
    return _isSameDay(d, DateTime.now());
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Select date to view history',
      builder: (ctx, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppTheme.primaryBlue,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1A2530),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryBlue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _WaveBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Consumer2<WaterProvider, SettingsProvider>(
                      builder: (context, water, settings, _) {
                        final isOz = settings.settings.isOunces;
                        final unit = isOz ? 'oz' : 'ml';

                        // Filter records for selected date
                        final dateRecords = water.records.where((r) =>
                          _isSameDay(r.timestamp, _selectedDate)
                        ).toList()
                          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                        final dateTotal = dateRecords.fold<int>(
                          0, (sum, r) => sum + (r.amountInMl * r.beverageType.hydrationMultiplier).round(),
                        );
                        final displayTotal = isOz ? (dateTotal / 29.5735).round() : dateTotal;

                        final dateLabel = _isToday(_selectedDate)
                            ? "TODAY'S LOGS"
                            : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: AppTheme.textSecondaryDark,
                                  ),
                                ),
                                Text(
                                  '$displayTotal $unit total',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHistoryList(context, water, dateRecords, isOz, unit),
                            const SizedBox(height: 100),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isViewingToday = _isToday(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // Clear All button
              GestureDetector(
                onTap: () => _showClearAllDialog(context),
                child: GlassCard(
                  borderRadius: 999,
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.delete_sweep, size: 20, color: isDark ? Colors.redAccent[100] : Colors.redAccent),
                ),
              ),
              const SizedBox(width: 8),
              // Back to Today button (only when not viewing today)
              if (!isViewingToday)
                GestureDetector(
                  onTap: () => setState(() => _selectedDate = DateTime.now()),
                  child: GlassCard(
                    borderRadius: 999,
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.today, size: 20, color: AppTheme.primaryBlue),
                  ),
                ),
              if (!isViewingToday) const SizedBox(width: 8),
              // Calendar picker button
              GestureDetector(
                onTap: () => _pickDate(context),
                child: GlassCard(
                  borderRadius: 999,
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: isViewingToday ? AppTheme.primaryBlue : Colors.amber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final water = Provider.of<WaterProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2530) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('Clear All History', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your hydration records. Your settings will NOT be affected.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              water.clearAllRecords();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All history cleared'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WaterProvider water, List records, bool isOz, String unit) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _isToday(_selectedDate)
                ? "No logs for today yet."
                : "No logs for this date.",
            style: const TextStyle(color: AppTheme.textSecondaryDark),
          ),
        ),
      );
    }
    
    return Column(
      children: records.map<Widget>((record) {
        final amount = isOz ? (record.amountInMl / 29.5735).round() : record.amountInMl;
        final hour12 = record.timestamp.hour == 0 ? 12 : (record.timestamp.hour > 12 ? record.timestamp.hour - 12 : record.timestamp.hour);
        final amPm = record.timestamp.hour >= 12 ? 'PM' : 'AM';
        final timeStr = "${hour12.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')} $amPm";
        
        Color iconColor = AppTheme.waterColor;
        IconData iconData = Icons.water_drop;
        String typeName = "Hydration";
        String titleName = "Water Logged";

        switch (record.beverageType) {
          case BeverageType.coffee:
            iconColor = AppTheme.coffeeColor;
            iconData = Icons.coffee;
            typeName = "Caffeine";
            titleName = "Coffee";
            break;
          case BeverageType.juice:
            iconColor = AppTheme.juiceColor;
            iconData = Icons.local_drink;
            typeName = "Vitamins";
            titleName = "Juice";
            break;
          case BeverageType.tea:
            iconColor = const Color(0xFF22C55E);
            iconData = Icons.emoji_food_beverage;
            typeName = "Hydration";
            titleName = "Tea";
            break;
          case BeverageType.soda:
            iconColor = const Color(0xFFEF4444);
            iconData = Icons.fastfood;
            typeName = "Sugar";
            titleName = "Soda";
            break;
          default:
            break;
        }

        return Dismissible(
          key: ValueKey(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.redAccent, size: 24),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) {
                final dark = Theme.of(ctx).brightness == Brightness.dark;
                return AlertDialog(
                  backgroundColor: dark ? const Color(0xFF1A2530) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Delete Record?', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text('Remove $titleName ($amount $unit) logged at $timeStr?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('Cancel', style: TextStyle(color: dark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                );
              },
            ) ?? false;
          },
          onDismissed: (_) {
            water.deleteRecord(record.id);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              timeStr,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$amount $unit',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: iconColor,
                        ),
                      ),
                      Text(
                        typeName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 180,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue.withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
