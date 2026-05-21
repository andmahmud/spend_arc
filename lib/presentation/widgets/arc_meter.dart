import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spend_arc/core/constants/app_constants.dart';
import 'package:spend_arc/core/theme/app_theme.dart';

class ArcMeter extends StatefulWidget {
  final double percentage;
  final double totalAmount;
  final double spentAmount;
  final double size;

  const ArcMeter({
    super.key,
    required this.percentage,
    required this.totalAmount,
    required this.spentAmount,
    this.size = 260,
  });

  @override
  State<ArcMeter> createState() => _ArcMeterState();
}

class _ArcMeterState extends State<ArcMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animationDurationMs),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ArcMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percentage != widget.percentage) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size * 0.75,
          child: CustomPaint(
            painter: _ArcMeterPainter(
              percentage: widget.percentage * _animation.value,
              spentAmount: widget.spentAmount,
              totalAmount: widget.totalAmount,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: widget.size * 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${widget.spentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: widget.size * 0.12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of \$${widget.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: widget.size * 0.045,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArcMeterPainter extends CustomPainter {
  final double percentage;
  final double spentAmount;
  final double totalAmount;

  _ArcMeterPainter({
    required this.percentage,
    required this.spentAmount,
    required this.totalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width, size.height * 1.6) / 2;

    final startAngle = AppConstants.arcStartAngle * (math.pi / 180);
    final sweepAngle = AppConstants.arcSweepAngle * (math.pi / 180);

    _drawTrack(canvas, center, radius, startAngle, sweepAngle);

    final filledSweep = sweepAngle * percentage;
    _drawFilledArc(
        canvas, center, radius, startAngle, filledSweep, sweepAngle);

    if (percentage > 0) {
      _drawIndicator(canvas, center, radius, startAngle, filledSweep);
    }

    _drawCenterGlow(canvas, center, radius);
  }

  void _drawTrack(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
  ) {
    final paint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawFilledArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double filledSweep,
    double totalSweep,
  ) {
    final warningColor = percentage > 0.7 ? AppColors.warning : AppColors.accent;
    final errorColor = percentage > 0.9 ? AppColors.error : warningColor;

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + totalSweep,
      colors: [
        AppColors.primary,
        AppColors.accent,
        warningColor,
        errorColor,
      ],
      stops: [0.0, 0.33, 0.66, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius + 10),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      filledSweep,
      false,
      paint,
    );
  }

  void _drawIndicator(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double filledSweep,
  ) {
    final indicatorAngle = startAngle + filledSweep;
    final indicatorX = center.dx + radius * math.cos(indicatorAngle);
    final indicatorY = center.dy + radius * math.sin(indicatorAngle);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(indicatorX, indicatorY), 6, paint);

    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(indicatorX, indicatorY), 12, glowPaint);
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double radius) {
    final glowRadius = radius * 0.15;
    final gradient = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.08),
        AppColors.primary.withValues(alpha: 0),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );

    canvas.drawCircle(center, glowRadius, paint);
  }

  @override
  bool shouldRepaint(_ArcMeterPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.spentAmount != spentAmount ||
        oldDelegate.totalAmount != totalAmount;
  }
}
