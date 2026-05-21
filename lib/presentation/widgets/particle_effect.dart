import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:spend_arc/core/theme/app_theme.dart';

class ParticleBurst extends StatefulWidget {
  final Widget child;
  final Color? color;

  const ParticleBurst({
    super.key,
    required this.child,
    this.color,
  });

  @override
  ParticleBurstState createState() => ParticleBurstState();
}

class ParticleBurstState extends State<ParticleBurst>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _showBurst = false;

  void trigger() {
    _particles.clear();
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        x: 0,
        y: 0,
        velocityX: (_random.nextDouble() - 0.5) * 4,
        velocityY: (_random.nextDouble() - 0.5) * 4 - 2,
        size: _random.nextDouble() * 4 + 2,
        color: _random.nextBool()
            ? (widget.color ?? AppColors.primary)
            : AppColors.accent,
        life: 1.0,
      ));
    }
    _showBurst = true;
    _controller.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _controller.addListener(() {
      setState(() {
        for (final particle in _particles) {
          particle.x += particle.velocityX;
          particle.y += particle.velocityY;
          particle.velocityY += 0.08;
          particle.life = 1.0 - _controller.value;
          particle.size *= 0.98;
        }
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _showBurst = false;
        _particles.clear();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_showBurst)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(_particles.toList()),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x, y, velocityX, velocityY, size, life;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
    required this.life,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.life <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life * 0.8)
        ..style = PaintingStyle.fill;

      final center = Offset(
        size.width / 2 + p.x,
        size.height / 2 + p.y,
      );

      canvas.drawCircle(center, p.size * p.life, paint);

      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: p.life * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, p.size * p.life * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
