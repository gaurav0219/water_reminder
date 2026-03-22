import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(24.0),
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Stitch CSS Exact Matches
    final bgColor = isDark 
        ? AppTheme.glassBackgroundDark
        : AppTheme.glassBackgroundLight;
    final borderColor = isDark
        ? AppTheme.glassBorderDark
        : AppTheme.glassBorderLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // 12px blur specifically from Stitch
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ?? Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }
}
