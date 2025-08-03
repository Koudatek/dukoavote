import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget d'animation circulaire pour les transitions d'onboarding
/// Implémente l'effet de "globe qui tourne" avec des couches qui se déplacent
class CircularTransitionWidget extends StatefulWidget {
  final Widget child;
  final Color topLayerColor;
  final Color bottomLayerColor;
  final double progress;
  final bool isForward;

  const CircularTransitionWidget({
    super.key,
    required this.child,
    required this.topLayerColor,
    required this.bottomLayerColor,
    required this.progress,
    required this.isForward,
  });

  @override
  State<CircularTransitionWidget> createState() => _CircularTransitionWidgetState();
}

class _CircularTransitionWidgetState extends State<CircularTransitionWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CircularTransitionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.progress > 0 && oldWidget.progress == 0) {
      _rotationController.forward();
      _scaleController.forward();
    } else if (widget.progress == 0 && oldWidget.progress > 0) {
      _rotationController.reverse();
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenu principal
        widget.child,
        
        // Couche supérieure animée
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(widget.isForward 
                      ? _rotationAnimation.value * math.pi * 0.5
                      : -_rotationAnimation.value * math.pi * 0.5)
                  ..translate(
                    widget.isForward 
                        ? _rotationAnimation.value * 100
                        : -_rotationAnimation.value * 100,
                    0.0,
                  ),
                child: _buildTopLayer(),
              ),
            );
          },
        ),
        
        // Couche inférieure animée
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(widget.isForward 
                      ? -_rotationAnimation.value * math.pi * 0.5
                      : _rotationAnimation.value * math.pi * 0.5)
                  ..translate(
                    widget.isForward 
                        ? -_rotationAnimation.value * 100
                        : _rotationAnimation.value * 100,
                    0.0,
                  ),
                child: _buildBottomLayer(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopLayer() {
    return CustomPaint(
      painter: TopLayerPainter(
        color: widget.topLayerColor,
        progress: widget.progress,
        isForward: widget.isForward,
      ),
      child: Container(),
    );
  }

  Widget _buildBottomLayer() {
    return CustomPaint(
      painter: BottomLayerPainter(
        color: widget.bottomLayerColor,
        progress: widget.progress,
        isForward: widget.isForward,
      ),
      child: Container(),
    );
  }
}

/// CustomPainter pour la couche supérieure avec courbe organique
class TopLayerPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isForward;

  TopLayerPainter({
    required this.color,
    required this.progress,
    required this.isForward,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Créer une courbe organique pour la séparation
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.8);
    
    // Courbe sinusoïdale pour l'effet organique
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.8 + 
                math.sin((x / size.width) * math.pi * 3 + progress * math.pi) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    // Ajouter un effet de gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: .9),
        color.withValues(alpha: .7),
      ],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, gradientPaint);
  }

  @override
  bool shouldRepaint(TopLayerPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.progress != progress ||
           oldDelegate.isForward != isForward;
  }
}

/// CustomPainter pour la couche inférieure
class BottomLayerPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isForward;

  BottomLayerPainter({
    required this.color,
    required this.progress,
    required this.isForward,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Créer la forme de la couche inférieure
    path.moveTo(0, size.height * 0.2);
    
    // Courbe inverse pour compléter la forme
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height * 0.2 + 
                math.sin((x / size.width) * math.pi * 3 + progress * math.pi + math.pi) * 20;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    
    // Ajouter un effet de gradient inversé
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: .7),
        color.withValues(alpha: .9),
      ],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, gradientPaint);
  }

  @override
  bool shouldRepaint(BottomLayerPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.progress != progress ||
           oldDelegate.isForward != isForward;
  }
}

/// Widget pour l'effet de particules lors des transitions
class ParticleEffect extends StatefulWidget {
  final Color particleColor;
  final double progress;

  const ParticleEffect({
    super.key,
    required this.particleColor,
    required this.progress,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Créer des particules aléatoires
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle(
        x: math.Random().nextDouble(),
        y: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 4 + 2,
        speed: math.Random().nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ParticleEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.progress > 0 && oldWidget.progress == 0) {
      _particleController.forward();
    } else if (widget.progress == 0 && oldWidget.progress > 0) {
      _particleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            color: widget.particleColor,
            progress: _particleController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// Classe pour représenter une particule
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  double angle = 0;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });

  void update(double deltaTime) {
    angle += speed * deltaTime;
    x += math.cos(angle) * 2;
    y += math.sin(angle) * 2;
  }
}

/// CustomPainter pour les particules
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: .6 * progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size * progress,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.progress != progress;
  }
} 