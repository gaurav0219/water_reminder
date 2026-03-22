import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LiquidBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Consumer<SettingsProvider>(
                    builder: (context, provider, _) {
                      final s = provider.settings;
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                        child: Column(
                          children: [
                            _buildHydrationGoalSection(context, provider, s, isDark),
                            const SizedBox(height: 32),
                            _buildRemindersSection(context, provider, s, isDark),
                            const SizedBox(height: 32),
                            _buildScheduleSection(context, provider, s, isDark),
                            const SizedBox(height: 32),
                            _buildDangerZone(context, provider),
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            child: Icon(Icons.arrow_back, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
          ),
          Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Provider.of<SettingsProvider>(context, listen: false).toggleTheme(isDark),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
              child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.primaryBlue.withValues(alpha: 0.8))),
          const SizedBox(width: 16),
          Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryBlue.withValues(alpha: 0.2), Colors.transparent])))),
        ],
      ),
    );
  }

  // ── Hydration Goal Section ──
  Widget _buildHydrationGoalSection(BuildContext context, SettingsProvider provider, dynamic s, bool isDark) {
    return Column(
      children: [
        _buildSectionHeader('HYDRATION GOAL'),
        GlassCard(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Daily Goal Row — tappable to edit
              InkWell(
                onTap: () => _showGoalDialog(context, provider, s),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        _iconBox(Icons.track_changes),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Daily Goal', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          Text('Target intake per day', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                        ]),
                      ]),
                      Row(children: [
                        Container(
                          width: 80, height: 40, alignment: Alignment.centerRight,
                          decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            s.isOunces ? (s.dailyGoalMl / 29.5735).round().toString() : s.dailyGoalMl.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(s.isOunces ? 'OZ' : 'ML', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                      ]),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              // Units Toggle
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _iconBox(Icons.straighten),
                      const SizedBox(width: 16),
                      Text('Measurement Units', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ]),
                    _buildSegmentedToggle(isDark, !s.isOunces, 'ML', 'OZ',
                      () => provider.toggleUnit(false),
                      () => provider.toggleUnit(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Goal Edit Dialog ──
  void _showGoalDialog(BuildContext context, SettingsProvider provider, dynamic s) {
    final controller = TextEditingController(text: s.dailyGoalMl.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2530) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Set Daily Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your daily hydration goal in milliliters.', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: 'ml',
                suffixStyle: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight))),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 500 && val <= 10000) {
                provider.updateGoal(val);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Reminders Section ──
  Widget _buildRemindersSection(BuildContext context, SettingsProvider provider, dynamic s, bool isDark) {
    return Column(
      children: [
        _buildSectionHeader('REMINDERS'),
        GlassCard(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _iconBox(Icons.notifications_active),
                      const SizedBox(width: 16),
                      Text('Smart Reminders', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ]),
                    Switch(
                      value: s.isReminderEnabled,
                      onChanged: (val) => provider.toggleReminder(val),
                      activeTrackColor: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          _iconBox(Icons.schedule),
                          const SizedBox(width: 16),
                          Text('Reminder Interval', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2))),
                          child: Text('Every ${s.reminderIntervalHours}h', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primaryBlue,
                        inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        thumbColor: AppTheme.primaryBlue,
                        overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        trackHeight: 8.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                      ),
                      child: Slider(
                        value: s.reminderIntervalHours.toDouble(),
                        min: 1, max: 4, divisions: 3,
                        onChanged: (val) => provider.updateInterval(val.toInt()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1h', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                          Text('2h', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                          Text('3h', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                          Text('4h', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                        ],
                  ),
                ),
                  ],
                ),
              ),
              // ── Notification Sound ──
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _iconBox(Icons.volume_up_rounded),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Notification Sound', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text('Play sound with reminders', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                      ]),
                    ]),
                    Switch(
                      value: s.isSoundEnabled,
                      onChanged: s.isReminderEnabled ? (val) => provider.toggleSound(val) : null,
                      activeTrackColor: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
              // ── Vibration ──
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _iconBox(Icons.vibration_rounded),
                      const SizedBox(width: 16),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Vibration', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        Text('Vibrate on reminder', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                      ]),
                    ]),
                    Switch(
                      value: s.isVibrationEnabled,
                      onChanged: s.isReminderEnabled ? (val) => provider.toggleVibration(val) : null,
                      activeTrackColor: AppTheme.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Daily Schedule Section — now with time pickers ──
  Widget _buildScheduleSection(BuildContext context, SettingsProvider provider, dynamic s, bool isDark) {
    return Column(
      children: [
        _buildSectionHeader('DAILY SCHEDULE'),
        GlassCard(
          borderRadius: 24,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _scheduleRow(context, isDark,
                icon: Icons.light_mode,
                title: 'Wake Up Time',
                subtitle: 'First reminder starts after',
                value: s.wakeUpTime,
                onTap: () => _pickTime(context, provider, s.wakeUpTime, isWakeUp: true),
              ),
              Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
              _scheduleRow(context, isDark,
                icon: Icons.dark_mode,
                title: 'Bedtime',
                subtitle: 'Mutes reminders at night',
                value: s.sleepTime,
                onTap: () => _pickTime(context, provider, s.sleepTime, isWakeUp: false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleRow(BuildContext context, bool isDark, {
    required IconData icon, required String title, required String subtitle, required String value, required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              _iconBox(icon),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
              ]),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Time Picker ──
  Future<void> _pickTime(BuildContext context, SettingsProvider provider, String currentTime, {required bool isWakeUp}) async {
    final parts = currentTime.split(':');
    final hour = int.tryParse(parts[0]) ?? (isWakeUp ? 7 : 22);
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isWakeUp) {
        await provider.updateWakeUpTime(timeStr);
      } else {
        await provider.updateSleepTime(timeStr);
      }
    }
  }

  // ── Danger Zone — with confirmation dialog ──
  Widget _buildDangerZone(BuildContext context, SettingsProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showResetDialog(context, provider),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restart_alt, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('Reset All Settings', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2530) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Reset Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'This will reset all settings to their default values. Your hydration records will not be affected.',
          style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateGoal(2500);
              provider.toggleUnit(false);
              provider.updateInterval(2);
              provider.toggleReminder(true);
              provider.updateWakeUpTime('08:00');
              provider.updateSleepTime('22:00');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Segmented Toggle ──
  Widget _buildSegmentedToggle(bool isDark, bool leftActive, String leftLabel, String rightLabel, VoidCallback onLeft, VoidCallback onRight) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        _segmentButton(leftLabel, leftActive, isDark, onLeft),
        _segmentButton(rightLabel, !leftActive, isDark, onRight),
      ]),
    );
  }

  Widget _segmentButton(String label, bool active, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8)] : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? Colors.white : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight))),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppTheme.primaryBlue),
    );
  }
}

// ── Animated Liquid Background ──
class _LiquidBackground extends StatefulWidget {
  const _LiquidBackground();
  @override
  State<_LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<_LiquidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat(reverse: true);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = isDark ? 0.15 : 0.4;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(children: [
          Positioned(
            top: -40 + (_controller.value * 20), left: -40 + (_controller.value * 20),
            child: Container(width: 256, height: 256, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue.withValues(alpha: opacity), boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: opacity), blurRadius: 60)])),
          ),
          Positioned(
            bottom: -40 + ((1 - _controller.value) * 20), right: -40 + ((1 - _controller.value) * 20),
            child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[400]?.withValues(alpha: opacity), boxShadow: [BoxShadow(color: Colors.blue[400]!.withValues(alpha: opacity), blurRadius: 60)])),
          ),
        ]);
      },
    );
  }
}
