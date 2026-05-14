import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class SphereStyle {
  final Color color;
  final double darkOpacity;
  final double lightOpacity;
  final double horizontalAmplitude;
  final double verticalAmplitude;

  const SphereStyle({
    required this.color,
    this.darkOpacity = 0.3,
    this.lightOpacity = 0.15,
    this.horizontalAmplitude = 50,
    this.verticalAmplitude = 30,
  });
}

class GlassLayout extends StatefulWidget {
  final Widget child;
  final SphereStyle sphere1;
  final SphereStyle sphere2;
  final double sphereSize;
  final double blurSigma;

  const GlassLayout({
    super.key,
    required this.child,
    this.sphere1 = const SphereStyle(color: Colors.blueAccent),
    this.sphere2 = const SphereStyle(color: Colors.purpleAccent),
    this.sphereSize = 400,
    this.blurSigma = 80,
  });

  @override
  State<GlassLayout> createState() => _GlassLayoutState();
}

class _GlassLayoutState extends State<GlassLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s1 = widget.sphere1;
    final s2 = widget.sphere2;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -100 + (math.sin(_controller.value * math.pi * 2) * s1.verticalAmplitude),
                    left: -50 + (math.cos(_controller.value * math.pi) * s1.horizontalAmplitude),
                    child: _LuzFondo(
                      size: widget.sphereSize,
                      color: s1.color.withOpacity(isDark ? s1.darkOpacity : s1.lightOpacity),
                    ),
                  ),
                  Positioned(
                    bottom: -150 + (math.cos(_controller.value * math.pi * 2) * s2.verticalAmplitude),
                    right: -100 + (math.sin(_controller.value * math.pi) * s2.horizontalAmplitude),
                    child: _LuzFondo(
                      size: widget.sphereSize,
                      color: s2.color.withOpacity(isDark ? s2.darkOpacity : s2.lightOpacity),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(color: Colors.transparent),
        ),
        widget.child,
      ],
    );
  }
}

class _LuzFondo extends StatelessWidget {
  final double size;
  final Color color;

  const _LuzFondo({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
