import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/player_profile_provider.dart';
import '../widgets/andean_background.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/entities/exercise_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LevelSelectionScreen — TAREA 3
//
// Muestra 3 tarjetas de dificultad:
//   • Fácil   → ejercicio ex_001 a ex_003 (índices 0-2)
//   • Medio   → ex_004 a ex_007 (índices 3-6)
//   • Difícil → ex_008 a ex_011 (índices 7-10), incluye el ejercicio de potencias
//
// Al pulsar una tarjeta, navega a /practice/:index con el ejercicio asignado.
// ─────────────────────────────────────────────────────────────────────────────

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      body: AndeanBackgroundWidget(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── AppBar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Text(
                        'Elige tu Nivel',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                    // Monedas disponibles
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white38, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Text('🌟',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.availableCoins}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Subtítulo ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Practica la jerarquía de operaciones\ncon ejercicios de distintos niveles.',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Tarjetas de nivel ─────────────────────────────────────────
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final repo = ref.watch(exerciseRepositoryProvider);
                    final easyExs = repo.easyExercises;
                    final medExs = repo.mediumExercises;
                    final hardExs = repo.hardExercises;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      children: [
                        _LevelCard(
                          emoji: '🌱',
                          title: 'Fácil',
                          subtitle: 'Sumas y restas con un paréntesis',
                          description:
                              '• Operaciones de un solo paso\n'
                              '• Núcleos básicos de jerarquía\n'
                              '• Ideal para calentar motores',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          badgeColor: const Color(0xFF81C784),
                          allLevelExercises: easyExs,
                          completedExerciseIds: profile.completedExerciseIds,
                          level: 1,
                          unlockedLevel: profile.highestUnlockedLevel,
                        ),
                        const SizedBox(height: 16),
                        _LevelCard(
                          emoji: '⚡',
                          title: 'Medio',
                          subtitle: 'Dos paréntesis y múltiples operadores',
                          description:
                              '• Jerarquía con 3 operaciones\n'
                              '• Dos grupos con paréntesis\n'
                              '• Resolver de izquierda a derecha',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          badgeColor: const Color(0xFF64B5F6),
                          allLevelExercises: medExs,
                          completedExerciseIds: profile.completedExerciseIds,
                          level: 2,
                          unlockedLevel: profile.highestUnlockedLevel,
                        ),
                        const SizedBox(height: 16),
                        _LevelCard(
                          emoji: '🔥',
                          title: 'Difícil',
                          subtitle: 'Potencias, división, paréntesis anidados',
                          description:
                              '• Expresión con potencia (^)\n'
                              '• 8+ tokens, 6 pasos pedagógicos\n'
                              '• Resolución completa paso a paso',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          badgeColor: const Color(0xFFEF9A9A),
                          allLevelExercises: hardExs,
                          completedExerciseIds: profile.completedExerciseIds,
                          level: 3,
                          unlockedLevel: profile.highestUnlockedLevel,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LevelCard
// ─────────────────────────────────────────────────────────────────────────────

class _LevelCard extends ConsumerStatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final LinearGradient gradient;
  final Color badgeColor;
  final List<ExerciseEntity> allLevelExercises;
  final List<String> completedExerciseIds;
  final int level;
  final int unlockedLevel;

  const _LevelCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradient,
    required this.badgeColor,
    required this.allLevelExercises,
    required this.completedExerciseIds,
    required this.level,
    required this.unlockedLevel,
  });

  @override
  ConsumerState<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends ConsumerState<_LevelCard> {
  bool _pressed = false;
  late ExerciseEntity _targetExercise;

  @override
  void initState() {
    super.initState();
    _pickNextExercise();
  }

  @override
  void didUpdateWidget(covariant _LevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la lista de ejercicios o el progreso cambió, re-elegir
    if (oldWidget.allLevelExercises != widget.allLevelExercises ||
        oldWidget.completedExerciseIds != widget.completedExerciseIds) {
      _pickNextExercise();
    }
  }

  /// Elige el siguiente ejercicio en orden secuencial (el primero no completado).
  void _pickNextExercise() {
    final pool = widget.allLevelExercises;
    if (pool.isEmpty) return;
    
    final uncompleted = pool.where((e) => !widget.completedExerciseIds.contains(e.id)).toList();
    
    if (uncompleted.isNotEmpty) {
      _targetExercise = uncompleted.first;
    } else {
      // Si ya completó todos los de este nivel, escoge uno al azar para repasar
      final random = Random();
      _targetExercise = pool[random.nextInt(pool.length)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetExercise = _targetExercise;

    // Calcular progreso
    final completedCount = widget.allLevelExercises.where(
      (ex) => widget.completedExerciseIds.contains(ex.id)
    ).length;
    final totalCount = widget.allLevelExercises.length;
    final bool allDone = completedCount >= totalCount;

    final isLocked = widget.level > widget.unlockedLevel;

    return GestureDetector(
      onTapDown: isLocked ? null : (_) => setState(() => _pressed = true),
      onTapUp: isLocked ? null : (_) {
        setState(() => _pressed = false);
        
        // 1. Resetear progreso para el nuevo ejercicio (Evitar RangeError)
        ref.read(playerProfileProvider.notifier).updateLastPlayedProgress(
          level: widget.level,
          exerciseId: targetExercise.id,
          stepIndex: 0,
        );
        
        // 2. Buscar índice global y navegar
        final repo = ref.read(exerciseRepositoryProvider);
        final all = repo.getAll();
        final globalIndex = all.indexOf(targetExercise);
        
        // Al regresar de la pantalla de práctica, actualizar el progreso
        context.push('/practice/$globalIndex').then((_) {
          if (mounted) {
            setState(() {
              _pickNextExercise();
            });
          }
        });
      },
      onTapCancel: isLocked ? null : () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _pressed ? 4.0 : 0.0,
          bottom: _pressed ? 0.0 : 4.0,
        ),
        decoration: BoxDecoration(
          gradient: isLocked
              ? const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)])
              : widget.gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _pressed || isLocked
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [
                  BoxShadow(
                      color: widget.gradient.colors.last
                          .withValues(alpha: 0.50),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 0,
                      offset: const Offset(0, 4)),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // ── Emoji grande ──────────────────────────────────────
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5),
                    ),
                    child: Center(
                      child: Text(isLocked ? '🔒' : widget.emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (allDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.25),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Text('✓ Hecho',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight.w800)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Progreso Visual (TAREA 2)
                        Text(
                          'Progreso: $completedCount / $totalCount completados',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                                  .withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                      isLocked
                          ? Icons.lock_outline_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white70,
                      size: 20),
                ],
              ),

              const SizedBox(height: 16),

              // ── Descripción ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                      width: 1),
                ),
                child: Text(
                  widget.description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
