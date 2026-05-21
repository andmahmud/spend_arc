import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spend_arc/core/theme/app_theme.dart';

class SpendingLineChart extends StatefulWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final double height;
  final Color lineColor;
  final Color fillColor;

  const SpendingLineChart({
    super.key,
    required this.dataPoints,
    required this.labels,
    this.height = 200,
    this.lineColor = AppColors.primary,
    this.fillColor = AppColors.primary,
  });

  @override
  State<SpendingLineChart> createState() => _SpendingLineChartState();
}

class _SpendingLineChartState extends State<SpendingLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SpendingLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataPoints != widget.dataPoints) {
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
        return CustomPaint(
          size: Size.infinite,
          painter: _LineChartPainter(
            dataPoints: widget.dataPoints,
            labels: widget.labels,
            animationValue: _animation.value,
            lineColor: widget.lineColor,
            fillColor: widget.fillColor,
          ),
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> labels;
  final double animationValue;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter({
    required this.dataPoints,
    required this.labels,
    required this.animationValue,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    const padding = EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30);
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;

    final maxVal = dataPoints.reduce(math.max);
    final minVal = 0.0;
    final range = maxVal - minVal;

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = padding.left + (i / (dataPoints.length - 1)) * chartWidth;
      final y = padding.top +
          chartHeight -
          ((dataPoints[i] - minVal) / (range > 0 ? range : 1)) * chartHeight;
      points.add(Offset(x, y));
    }

    final visibleCount = (dataPoints.length * animationValue).ceil();
    final visiblePoints = points.take(visibleCount).toList();

    if (visiblePoints.isEmpty) return;

    if (visiblePoints.length > 1) {
      _drawFill(canvas, size, visiblePoints, padding, chartHeight);
      _drawLine(canvas, visiblePoints);
    }

    _drawDots(canvas, visiblePoints);

    if (visiblePoints.isNotEmpty) {
      _drawLabels(canvas, size, visiblePoints, padding);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final ctrlX = (prev.dx + curr.dx) / 2;
      path.cubicTo(ctrlX, prev.dy, ctrlX, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  void _drawFill(
    Canvas canvas,
    Size size,
    List<Offset> points,
    EdgeInsets padding,
    double chartHeight,
  ) {
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor.withValues(alpha: 0.2),
        fillColor.withValues(alpha: 0.0),
      ],
    );

    final fillPath = Path();
    fillPath.moveTo(points[0].dx, padding.top + chartHeight);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final ctrlX = (prev.dx + curr.dx) / 2;
      fillPath.cubicTo(
          ctrlX, prev.dy, ctrlX, curr.dy, curr.dx, curr.dy);
    }

    fillPath.lineTo(
        points.last.dx, padding.top + chartHeight);
    fillPath.close();

    final paint = Paint()
      ..shader = fillGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawPath(fillPath, paint);
  }

  void _drawDots(Canvas canvas, List<Offset> points) {
    for (final point in points) {
      final bgPaint = Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 4, bgPaint);

      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  void _drawLabels(
    Canvas canvas,
    Size size,
    List<Offset> points,
    EdgeInsets padding,
  ) {
    for (int i = 0; i < labels.length && i < points.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          points[i].dx - textPainter.width / 2,
          size.height - padding.bottom / 2 - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.dataPoints != dataPoints;
  }
}
