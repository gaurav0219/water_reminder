import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class LiquidBlob extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Offset initialPosition;
  final Offset targetPosition;
  final Duration duration;

  const LiquidBlob({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.initialPosition,
    required this.targetPosition,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<LiquidBlob> createState() => _LiquidBlobState();
}

class _LiquidBlobState extends State<LiquidBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<Offset>(
      begin: widget.initialPosition,
      end: widget.targetPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine opacity based on theme similar to Stitch HTML
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = isDark ? 0.15 : 0.4;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: _animation.value.dx,
          top: _animation.value.dy,
          width: widget.width,
          height: widget.height,
          child: Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScreenBackground extends StatelessWidget {
  final Widget child;

  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Base background
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
        ),
        
        // Settings/Dashboard style blobs
        LiquidBlob(
          width: 256,
          height: 256,
          color: AppTheme.primaryBlue,
          initialPosition: const Offset(-40, 0),
          targetPosition: Offset(-40 + size.width * 0.1, size.height * 0.1),
        ),
        LiquidBlob(
          width: 320,
          height: 320,
          color: Colors.blue[400] ?? AppTheme.primaryBlue,
          initialPosition: Offset(size.width - 280, size.height - 320),
          targetPosition: Offset(size.width - 280 - size.width * 0.1, size.height - 320 - size.height * 0.1),
          duration: const Duration(seconds: 25), // slight offset in duration
        ),
        
        // The actual screen content
        SafeArea(
          bottom: false,
          child: child,
        ),
      ],
    );
  }
}
