import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white10 : Colors.black.withOpacity(0.06);
    final highlight = isDark ? Colors.white12 : Colors.black.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, base, highlight, base, base],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            ).createShader(Rect.fromLTWH(
              -bounds.width + (bounds.width * 2 * _controller.value),
              0,
              bounds.width,
              bounds.height,
            ));
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonProfileCard extends StatelessWidget {
  const SkeletonProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonCircle(size: 100),
              SizedBox(height: 28),
              SkeletonLine(width: 180, height: 24),
              SizedBox(height: 10),
              SkeletonLine(width: 250, height: 16),
              SizedBox(height: 28),
              SkeletonLine(width: 160, height: 32, borderRadius: 20),
              SizedBox(height: 32),
              SkeletonLine(height: 55, borderRadius: 18),
              SizedBox(height: 16),
              SkeletonLine(height: 55, borderRadius: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonAdminList extends StatelessWidget {
  final int itemCount;

  const SkeletonAdminList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return ShimmerLoading(
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: const Row(
                children: [
                  SkeletonCircle(size: 52),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonLine(width: 140, height: 18),
                        SizedBox(height: 8),
                        SkeletonLine(width: 200, height: 14),
                        SizedBox(height: 8),
                        SkeletonLine(width: 80, height: 16, borderRadius: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
