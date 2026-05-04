import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/robot_accessory_entity.dart';
import '../providers/practice_notifier.dart';

/// Widget que renderiza el "Robot Guardián" con estados visuales animados.
///
/// - [mood]        Estado emocional del robot (idle/happy/error/thinking/victory).
/// - [accessories] Lista de IDs de accesorios desbloqueados y activos.
class RobotVisualizer extends StatefulWidget {
  final LlamaMood mood;
  final List<String> unlockedAccessoryIds;

  const RobotVisualizer({
    super.key,
    required this.mood,
    required this.unlockedAccessoryIds,
  });

  @override
  State<RobotVisualizer> createState() => _RobotVisualizerState();
}

class _RobotVisualizerState extends State<RobotVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(RobotVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Disparar animación al cambiar el mood
    if (oldWidget.mood != widget.mood) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Datos visuales por estado ─────────────────────────────────────────────

  String get _robotEmoji {
    return switch (widget.mood) {
      LlamaMood.idle     => '🤖',
      LlamaMood.happy    => '😄',
      LlamaMood.error    => '😣',
      LlamaMood.thinking => '🤔',
      LlamaMood.victory  => '🏆',
    };
  }

  Color get _glowColor {
    return switch (widget.mood) {
      LlamaMood.happy   => AppTheme.primaryGreen,
      LlamaMood.error   => AppTheme.errorRed,
      LlamaMood.victory => const Color(0xFFFFD700), // oro
      _                 => Colors.transparent,
    };
  }

  String get _moodLabel {
    return switch (widget.mood) {
      LlamaMood.idle     => '¡Toca un elemento!',
      LlamaMood.happy    => '¡Correcto! 🎉',
      LlamaMood.error    => '¡Inténtalo de nuevo!',
      LlamaMood.thinking => '¡Sigue así!',
      LlamaMood.victory  => '¡Ejercicio completado!',
    };
  }

  // ── Accesorios activos (los últimos 3 desbloqueados se muestran) ──────────

  List<RobotAccessoryEntity> get _activeAccessories {
    return RobotAccessoryCatalog.all
        .where((a) => widget.unlockedAccessoryIds.contains(a.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnim.value),
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cuerpo del robot con aura de color
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _glowColor.withValues(alpha: 0.12),
              boxShadow: _glowColor != Colors.transparent
                  ? [
                      BoxShadow(
                        color: _glowColor.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Robot central
                Text(
                  _robotEmoji,
                  style: const TextStyle(fontSize: 72),
                ),
                // Accesorios superpuestos (esquina superior)
                if (_activeAccessories.isNotEmpty)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: _AccessoryBadges(accessories: _activeAccessories),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Etiqueta de estado (animada)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _moodLabel,
              key: ValueKey(widget.mood),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.mood == LlamaMood.error
                    ? AppTheme.errorRed
                    : AppTheme.earthBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra pequeñas insignias de accesorios activos superpuestas al robot.
class _AccessoryBadges extends StatelessWidget {
  final List<RobotAccessoryEntity> accessories;
  const _AccessoryBadges({required this.accessories});

  @override
  Widget build(BuildContext context) {
    // Máximo 3 accesorios visibles simultáneamente
    final visible = accessories.take(3).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: visible
          .map((a) => Text(a.emoji, style: const TextStyle(fontSize: 18)))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIÁLOGO "ARMARIO" — Wardrobe del Robot
// ─────────────────────────────────────────────────────────────────────────────

/// Muestra el armario completo del robot: accesorios desbloqueados y bloqueados.
void showRobotWardrobeDialog(
    BuildContext context, List<String> unlockedAccessoryIds) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RobotWardrobeSheet(unlockedIds: unlockedAccessoryIds),
  );
}

class _RobotWardrobeSheet extends StatelessWidget {
  final List<String> unlockedIds;
  const _RobotWardrobeSheet({required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    final unlocked =
        RobotAccessoryCatalog.all.where((a) => unlockedIds.contains(a.id));
    final locked =
        RobotAccessoryCatalog.all.where((a) => !unlockedIds.contains(a.id));

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            '🤖 Armario del Robot',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),

          if (unlocked.isNotEmpty) ...[
            const Text('✅ Accesorios desbloqueados',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: unlocked.map((a) => _AccessoryChip(a, true)).toList(),
            ),
            const SizedBox(height: 20),
          ],

          if (locked.isNotEmpty) ...[
            const Text('🔒 Por desbloquear',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.earthBrown)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: locked.map((a) => _AccessoryChip(a, false)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessoryChip extends StatelessWidget {
  final RobotAccessoryEntity accessory;
  final bool isUnlocked;
  const _AccessoryChip(this.accessory, this.isUnlocked);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnlocked ? AppTheme.primaryGreen : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              isUnlocked ? accessory.emoji : '❓',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 4),
            Text(
              isUnlocked ? accessory.name : '???',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? AppTheme.textDark : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
