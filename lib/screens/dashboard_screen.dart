import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:confetti/confetti.dart';
import '../widgets/glass_card.dart';
import '../widgets/liquid_background.dart';
import '../models/beverage_type.dart';
import '../providers/settings_provider.dart';
import '../providers/water_provider.dart';
import '../theme.dart';
import 'beverage_selection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BeverageType _selectedBeverage = BeverageType.water;
  int _customAmountMl = 250; // Tracks custom amount; updated per beverage
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _customAmountMl = _selectedBeverage.defaultAmountMl;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  int _mlToDisplay(int ml, bool isOz) {
    return isOz ? (ml / 29.5735).round() : ml;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Consumer2<WaterProvider, SettingsProvider>(
        builder: (context, water, settings, _) {
          final isOz = settings.settings.isOunces;
          final unitString = isOz ? 'oz' : 'ml';
          final dailyGoal = settings.settings.dailyGoalMl;
          final todayIntake = water.getTodayIntake();
          final progress = water.getTodayProgress(dailyGoal);

          final displayGoal = _mlToDisplay(dailyGoal, isOz);
          final displayIntake = _mlToDisplay(todayIntake, isOz);
          final streak = water.getCurrentStreak(dailyGoal);
          
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final warning = getHighAmountWarning(_selectedBeverage, _customAmountMl);

          return Stack(
            children: [
              CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildTopHeader(context, streak, settings, isDark),
                          const SizedBox(height: 32),
                          _buildProgressIndicator(context, progress, displayIntake, displayGoal, unitString, isDark),
                          const SizedBox(height: 32),
                          _buildStatsCard(displayIntake, displayGoal, unitString, isDark),
                          const SizedBox(height: 24),
                          _buildBeveragePreview(context, water, settings, isOz, unitString, isDark),
                          if (warning != null) ...[
                            const SizedBox(height: 12),
                            _buildWarningBanner(warning, isDark),
                          ],
                          const SizedBox(height: 24),
                          _buildQuickAddSection(context, water, settings, isOz, unitString, isDark),
                          const SizedBox(height: 24),
                          _buildWeeklyCard(isDark),
                          const SizedBox(height: 24),
                          _buildUndoButton(context, water, isDark),
                          const SizedBox(height: 120),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Top Header ──
  Widget _buildTopHeader(BuildContext context, int streak, SettingsProvider settings, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(8),
              borderRadius: 12,
              child: const Icon(Icons.water_drop, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'H2O Flow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => settings.toggleTheme(isDark),
              child: GlassCard(
                borderRadius: 999,
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.amber[400] : AppTheme.textSecondaryLight,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (streak > 0)
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                borderRadius: 20,
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                child: Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '$streak DAY STREAK',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── Progress Indicator ──
  Widget _buildProgressIndicator(BuildContext context, double progress, int current, int goal, String unit, bool isDark) {
     const size = 280.0;

     return Center(
       child: Stack(
         alignment: Alignment.center,
         children: [
           Container(
             width: size + 32,
             height: size + 32,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: AppTheme.primaryBlue.withValues(alpha: 0.1),
             ),
             child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                 child: const SizedBox.expand(),
             ),
           ),
           Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.blueGrey[900]!.withValues(alpha: 0.5) : Colors.blueGrey[100]!, 
                  width: 12
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                  )
                ]
              ),
           ),
           SizedBox(
             height: size - 32,
             width: size - 32,
             child: GlassCard(
               borderRadius: 999,
               padding: EdgeInsets.zero,
               border: Border.all(
                 color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5),
                 width: 2,
               ),
               child: ClipOval(
                 child: LiquidCircularProgressIndicator(
                     value: progress, 
                     valueColor: const AlwaysStoppedAnimation(Color(0xFF0284C7)),
                     backgroundColor: Colors.transparent,
                     borderColor: Colors.transparent,
                     borderWidth: 0,
                     direction: Axis.vertical, 
                     center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                             '${(progress * 100).toInt()}%',
                             style: Theme.of(context).textTheme.displayLarge?.copyWith(
                               color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                               fontWeight: FontWeight.bold,
                               fontSize: 48,
                               letterSpacing: -1,
                             ),
                           ),
                           Text(
                             'HYDRATED',
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: isDark ? Colors.white70 : AppTheme.textSecondaryLight,
                               fontWeight: FontWeight.w600,
                               letterSpacing: 2,
                               fontSize: 12,
                             ),
                           ),
                        ],
                     ),
                 ),
               ),
             ),
           ),
         ],
       ),
     );
  }

  // ── Stats Card ──
  Widget _buildStatsCard(int current, int goal, String unit, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT INTAKE',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 40,
            width: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.blueGrey[300]!.withValues(alpha: 0.5),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DAILY GOAL',
                style: TextStyle(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$goal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bug 1 Fix: Beverage Preview Card ──
  Widget _buildBeveragePreview(BuildContext context, WaterProvider water, SettingsProvider settings, bool isOz, String unit, bool isDark) {
    final displayAmount = _mlToDisplay(_customAmountMl, isOz);
    final bevColor = _selectedBeverage.color;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: bevColor.withValues(alpha: 0.3)),
      child: Row(
        children: [
          // Beverage icon
          GestureDetector(
            onTap: () => _openBeverageSelector(context),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: bevColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_selectedBeverage.icon, color: bevColor, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Beverage name + amount
          Expanded(
            child: GestureDetector(
              onTap: () => _openBeverageSelector(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedBeverage.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$displayAmount $unit selected  •  Tap to change',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Custom amount button
          GestureDetector(
            onTap: () => _showCustomAmountPicker(context, isOz, unit),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bevColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: bevColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$displayAmount $unit',
                style: TextStyle(
                  color: bevColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Add button
          GestureDetector(
            onTap: () => _onAddWater(water, settings, _customAmountMl, _selectedBeverage),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bevColor, bevColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: bevColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _openBeverageSelector(BuildContext context) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const BeverageSelectionScreen()),
    );
    if (!context.mounted || result == null) return;

    if (result is Map && result['action'] == 'custom') {
      final BeverageType selectedBev = result['beverage'];
      setState(() {
        _selectedBeverage = selectedBev;
        _customAmountMl = selectedBev.defaultAmountMl;
      });

      // Trigger the custom amount picker after returning
      final isOz = Provider.of<SettingsProvider>(context, listen: false).settings.isOunces;
      final unit = isOz ? 'oz' : 'ml';
      _showCustomAmountPicker(context, isOz, unit);
    } else if (result is BeverageType) {
      setState(() {
        _selectedBeverage = result;
        _customAmountMl = result.defaultAmountMl;
      });
    }
  }

  // ── Bug 2 Fix: Custom Amount Picker ──
  void _showCustomAmountPicker(BuildContext context, bool isOz, String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempAmount = _customAmountMl;
    final controller = TextEditingController(
      text: isOz ? (tempAmount / 29.5735).round().toString() : tempAmount.toString(),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A2530) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bevColor = _selectedBeverage.color;
            final displayAmount = isOz ? (tempAmount / 29.5735).round() : tempAmount;

            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Row(
                    children: [
                      Icon(_selectedBeverage.icon, color: bevColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Custom ${_selectedBeverage.displayName} Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stepper row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stepperButton(Icons.remove, () {
                        final step = isOz ? 30 : 25; // ~1oz or 25ml
                        if (tempAmount > step) {
                          setSheetState(() {
                            tempAmount -= step;
                            controller.text = isOz ? (tempAmount / 29.5735).round().toString() : tempAmount.toString();
                          });
                        }
                      }, bevColor, isDark),
                      const SizedBox(width: 16),
                      // Manual input
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: bevColor,
                          ),
                          decoration: InputDecoration(
                            suffixText: unit,
                            suffixStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : AppTheme.textSecondaryLight),
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed > 0) {
                              setSheetState(() {
                                tempAmount = isOz ? (parsed * 29.5735).round() : parsed;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      _stepperButton(Icons.add, () {
                        final step = isOz ? 30 : 25;
                        if (tempAmount < 2000) {
                          setSheetState(() {
                            tempAmount += step;
                            controller.text = isOz ? (tempAmount / 29.5735).round().toString() : tempAmount.toString();
                          });
                        }
                      }, bevColor, isDark),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isOz ? "${(tempAmount / 29.5735).round()} oz" : "$tempAmount ml"} will be added',
                    style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight),
                  ),
                  // Live warning inside picker
                  Builder(builder: (_) {
                    final pickerWarning = getHighAmountWarning(_selectedBeverage, tempAmount);
                    if (pickerWarning == null) return const SizedBox.shrink();
                    final isPickerExtreme = tempAmount > _selectedBeverage.extremeThresholdMl;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isPickerExtreme ? Colors.red : Colors.amber).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (isPickerExtreme ? Colors.redAccent : Colors.amber).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPickerExtreme ? Icons.warning_rounded : Icons.info_outline,
                              color: isPickerExtreme ? Colors.redAccent : Colors.amber[700],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pickerWarning,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Read final value from text field
                        final finalParsed = int.tryParse(controller.text);
                        if (finalParsed != null && finalParsed > 0) {
                          tempAmount = isOz ? (finalParsed * 29.5735).round() : finalParsed;
                        }
                        Navigator.pop(ctx);
                        setState(() {
                          _customAmountMl = tempAmount.clamp(10, 3000);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bevColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Set $displayAmount $unit',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap, Color color, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  // ── Quick Add (now beverage-aware) ──
  Widget _buildQuickAddSection(BuildContext context, WaterProvider water, SettingsProvider settings, bool isOz, String unit, bool isDark) {
    final presets = _selectedBeverage.quickAddPresetsMl;
    final labels = _selectedBeverage.quickAddLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'QUICK ADD • ${_selectedBeverage.displayName.toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(3, (i) {
            final amountMl = presets[i];
            final displayAmt = _mlToDisplay(amountMl, isOz);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 12.0 : 0),
                child: _StitchQuickAddBtn(
                  amount: '+$displayAmt',
                  label: labels[i],
                  bevColor: _selectedBeverage.color,
                  onPressed: () => _onAddWater(water, settings, amountMl, _selectedBeverage),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Weekly Card ──
  Widget _buildWeeklyCard(bool isDark) {
    return Consumer2<WaterProvider, SettingsProvider>(
      builder: (context, water, settings, _) {
        final weeklyData = water.getWeeklyIntake();
        final dailyGoal = settings.settings.dailyGoalMl;
        int daysGoalMet = 0;
        for (final v in weeklyData.values) {
          if (v >= dailyGoal) daysGoalMet++;
        }
        
        String message;
        if (daysGoalMet == 7) {
          message = 'Perfect week! You hit your goal every day! 🎉';
        } else if (daysGoalMet >= 5) {
          message = "Excellent! You've hit your goal $daysGoalMet out of 7 days this week.";
        } else if (daysGoalMet >= 3) {
          message = "You've hit your goal $daysGoalMet out of 7 days this week.";
        } else if (daysGoalMet >= 1) {
          message = "You've hit your goal $daysGoalMet out of 7 days. Keep going!";
        } else {
          message = "Start hydrating to build your streak!";
        }

        String title = daysGoalMet >= 5 ? 'Outstanding Performance' : (daysGoalMet >= 3 ? 'Consistent Performance' : 'Keep Going');

        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryBlue.withValues(alpha: 0.2) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: AppTheme.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight)),
                    const SizedBox(height: 4),
                    Text(message, style: TextStyle(fontSize: 12, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // ── Warning Banner ──
  Widget _buildWarningBanner(String warning, bool isDark) {
    final isExtreme = _customAmountMl > _selectedBeverage.extremeThresholdMl;
    final bgColor = isExtreme
        ? Colors.red.withValues(alpha: 0.12)
        : Colors.amber.withValues(alpha: 0.12);
    final borderColor = isExtreme
        ? Colors.redAccent.withValues(alpha: 0.4)
        : Colors.amber.withValues(alpha: 0.4);
    final iconColor = isExtreme ? Colors.redAccent : Colors.amber[700]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isExtreme ? Icons.warning_rounded : Icons.info_outline, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddWater(WaterProvider water, SettingsProvider settings, int amountMl, BeverageType type) async {
    // If extreme amount, require confirmation
    if (amountMl > type.extremeThresholdMl) {
      final confirmed = await _showExtremeAmountDialog(amountMl, type);
      if (!confirmed || !mounted) return;
    }

    final oldProgress = water.getTodayProgress(settings.settings.dailyGoalMl);
    water.addWater(amountMl, beverageType: type).then((_) {
      if (!mounted) return;
      final newProgress = water.getTodayProgress(settings.settings.dailyGoalMl);
      if (oldProgress < 1.0 && newProgress >= 1.0) {
        _confettiController.play();
      }
      if (newProgress >= 1.0) {
        settings.pauseRemindersForToday();
      } else {
        settings.resumeRemindersIfNeeded();
      }
    });

    // Show mild warning as SnackBar if above warning threshold but not extreme
    if (mounted && amountMl > type.warningThresholdMl && amountMl <= type.extremeThresholdMl) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.displayName} added — ${getHighAmountWarning(type, amountMl) ?? ""}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _showExtremeAmountDialog(int amountMl, BeverageType type) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2530) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Very High Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${amountMl}ml of ${type.displayName.toLowerCase()} at once is unusually high.\n\n'
          'Are you sure you want to log this?',
          style: TextStyle(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Anyway', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Widget _buildUndoButton(BuildContext context, WaterProvider water, bool isDark) {
      return TextButton.icon(
         onPressed: () => water.removeLastRecord(),
         icon: const Icon(Icons.undo, size: 18),
         label: const Text("Undo Last"),
         style: TextButton.styleFrom(
            foregroundColor: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
         ),
      );
  }
}

class _StitchQuickAddBtn extends StatelessWidget {
  final String amount;
  final String label;
  final Color bevColor;
  final VoidCallback onPressed;

  const _StitchQuickAddBtn({required this.amount, required this.label, required this.onPressed, this.bevColor = AppTheme.primaryBlue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onPressed,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 16,
        child: Column(
          children: [
            Text(amount, style: TextStyle(color: bevColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isDark ? Colors.white54 : AppTheme.textSecondaryLight, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
