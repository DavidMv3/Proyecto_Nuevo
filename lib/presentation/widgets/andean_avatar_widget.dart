import 'package:flutter/material.dart';
import '../providers/practice_notifier.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AndeanAvatarWidget — La Llamita de MateAndina
//
// Reemplaza al robot. La llamita se "viste" o se "anima" con el progreso:
//   • level 0: Solo el pasto
//   • level 1-2: Patas
//   • level 3-4: Cuerpo
//   • level final: Cabeza y accesorios
// ─────────────────────────────────────────────────────────────────────────────

class AndeanAvatarWidget extends StatefulWidget {
  final int currentStepIndex;
  final int totalSteps;
  final LlamaMood mood;

  const AndeanAvatarWidget({
    super.key,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.mood,
  });

  @override
  State<AndeanAvatarWidget> createState() => _AndeanAvatarWidgetState();
}

class _AndeanAvatarWidgetState extends State<AndeanAvatarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _jumpCtrl;
  late final Animation<double> _jumpAnim;

  late final AnimationController _popCtrl;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();

    _jumpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _jumpAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _jumpCtrl, curve: Curves.easeOut));

    _popCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _popScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 45),
    ]).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(AndeanAvatarWidget old) {
    super.didUpdateWidget(old);
    if (widget.currentStepIndex > old.currentStepIndex) {
      _popCtrl.forward(from: 0);
    }
    if (widget.mood == LlamaMood.victory && old.mood != LlamaMood.victory) {
      _jumpCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _jumpCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_jumpCtrl, _popCtrl]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _jumpAnim.value),
          child: ScaleTransition(
            scale: _popScale.isAnimating ? _popScale : const AlwaysStoppedAnimation(1.0),
            child: child,
          ),
        );
      },
      child: _LlamaVisual(
        currentStep: widget.currentStepIndex,
        totalSteps: widget.totalSteps,
        mood: widget.mood,
      ),
    );
  }
}

class _LlamaVisual extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final LlamaMood mood;

  const _LlamaVisual({
    required this.currentStep,
    required this.totalSteps,
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    // ── Lógica de Formación Dinámica (Matemática de Porcentajes) ───────────
    final double progress = totalSteps > 1 
        ? currentStep / (totalSteps - 1) 
        : 1.0;
    
    final bool showLegs = progress > 0.0;
    final bool showBody = progress >= 0.33;
    final bool showHead = progress >= 0.66;
    final bool isFinal = progress >= 1.0;
    
    // Configuración común de animación
    const duration = Duration(milliseconds: 400);
    const curve = Curves.easeInOut;

    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ── BASE: PASTO BLOQUY ──────────────────────────────
          Positioned(
            bottom: 0,
            child: Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF7CB342),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // ── PATITAS GORDITAS ────────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: showLegs ? 1.0 : 0.0,
              duration: duration,
              curve: curve,
              child: Stack(
                children: [
                  // Patas traseras
                  Positioned(bottom: 12, left: 35, child: _BlockyLeg(isFront: false)),
                  Positioned(bottom: 12, right: 35, child: _BlockyLeg(isFront: false)),
                  // Patas delanteras
                  Positioned(bottom: 8, left: 40, child: _BlockyLeg(isFront: true)),
                  Positioned(bottom: 8, right: 40, child: _BlockyLeg(isFront: true)),
                ],
              ),
            ),
          ),

          // ── CUERPO ESPONJOSO (BLOCKY) ──────────────────────────────────────
          Positioned(
            bottom: 28,
            child: AnimatedOpacity(
              opacity: showBody ? 1.0 : 0.0,
              duration: duration,
              curve: curve,
              child: Container(
                width: 70,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      offset: const Offset(0, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CUELLO Y CABEZA ────────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: showHead ? 1.0 : 0.0,
              duration: duration,
              curve: curve,
              child: Stack(
                children: [
                  // Cuello
                  Positioned(
                    bottom: 65,
                    left: 30,
                    child: Container(
                      width: 22,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            offset: const Offset(4, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cabeza
                  Positioned(
                    bottom: 95,
                    left: 20,
                    child: Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        children: [
                          // Ojos y Orejas (Solo si hay cabeza)
                          Positioned(
                            top: 10,
                            left: 8,
                            child: _LlamaEyeBlocky(mood: mood, active: showHead),
                          ),
                          Positioned(
                            top: 10,
                            right: 18,
                            child: _LlamaEyeBlocky(mood: mood, active: showHead),
                          ),
                          Positioned(
                            top: -10,
                            left: 10,
                            child: _BlockyEar(),
                          ),
                          Positioned(
                            top: -10,
                            right: 10,
                            child: _BlockyEar(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── ACCESORIOS (PONCHO DE CELEBRACIÓN) ──────────────────────────────
          Positioned(
            bottom: 30,
            child: AnimatedOpacity(
              opacity: isFinal ? 1.0 : 0.0,
              duration: duration,
              curve: curve,
              child: Container(
                width: 74,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.purple],
                    stops: [0.2, 0.4, 0.5, 0.7, 0.9],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                ),
                child: CustomPaint(
                  painter: _PonchoPatternPainter(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockyLeg extends StatelessWidget {
  final bool isFront;
  const _BlockyLeg({required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 22,
      decoration: BoxDecoration(
        color: isFront ? Colors.white : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
    );
  }
}

class _BlockyEar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _LlamaEyeBlocky extends StatelessWidget {
  final LlamaMood mood;
  final bool active;
  const _LlamaEyeBlocky({required this.mood, required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) return const SizedBox.shrink();
    if (mood == LlamaMood.error) {
      return const Text('x', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54));
    }
    if (mood == LlamaMood.victory) {
      return const Text('^', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue));
    }
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PonchoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double i = 0; i < size.width; i += 6) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

