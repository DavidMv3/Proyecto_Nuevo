import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/robot_accessory_entity.dart';
import '../providers/player_profile_provider.dart';
import '../providers/practice_notifier.dart';
import '../widgets/interactive_equation.dart';
import '../widgets/andean_progress_banner.dart';
import '../widgets/math_notebook_line.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final int exerciseIndex;
  const PracticeScreen({super.key, required this.exerciseIndex});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exerciseIndex = widget.exerciseIndex;
    final state    = ref.watch(practiceProvider(exerciseIndex));
    final notifier = ref.read(practiceProvider(exerciseIndex).notifier);
    final profile  = ref.watch(playerProfileProvider);

    // ── TAREA 1: SnackBar GENÉRICO cuando lives > 0 ──────────────────────
    // Usamos errorSnackVersion como discriminador para detectar nuevos errores
    // aunque el texto sea igual.
    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      final prevVer = prev?.errorSnackVersion ?? 0;
      if (next.errorSnackVersion > prevVer &&
          next.errorSnackMessage.isNotEmpty &&
          !next.showSolutionDialog) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      next.errorSnackMessage,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 2),
            ),
          );
      }
    });

    // ── Ejercicio finalizado → diálogo (TAREA 3: botón "Volver a Niveles") ─
    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      if (!next.exerciseFinished || (prev?.exerciseFinished ?? false)) return;
      _showCompletionDialog(
        context: context,
        rewardCoins: next.exercise.rewardCoins,
        unlockedAccessory: next.newlyUnlockedAccessory,
        onRestart: () => notifier.loadLevel(next.exercise.difficulty),
        // TAREA 3: siempre vuelve a /levels al terminar
        onGoLevels: () => context.go('/levels'),
      );
    });

    // ── Vida 0 → BottomSheet de solución ────────────────────────────────
    // TAREA 2: el onDismiss sólo hace Navigator.pop(); el notifier avanza solo.
    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      if (!next.showSolutionDialog || (prev?.showSolutionDialog ?? false)) {
        return;
      }
      _showSolutionSheet(
        context: context,
        correctValues: next.correctTokenValues,
        explanation: next.currentStep.feedbackError,
        onDismiss: () {
          // 1. Cierra el modal de forma segura usando el context local (NO rootNavigator)
          Navigator.of(context).pop();

          // 2. Esperamos 150ms para que la animación de cierre termine
          //    antes de mutar el estado de la pantalla.
          Future.delayed(const Duration(milliseconds: 150), () {
            notifier.forceNextStep();
          });
        },
      );
    });

    // ── Auto-scroll al cambiar de paso ───────────────────────────────────────
    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      if (prev != null && prev.currentStepIndex != next.currentStepIndex) {
        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Fondo
          const DecoratedBox(
            decoration:
                BoxDecoration(gradient: AppTheme.scaffoldGradient),
            child: SizedBox.expand(),
          ),

          SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                final topBar = _PracticeTopBar(
                  isTutorial: state.exercise.difficulty == 0,
                  title: state.exercise.title,
                  pieces: profile.availableCoins,
                  currentStep: state.displayStep,
                  totalSteps: state.totalSteps,
                  llamaMood: state.llamaMood,
                  lives: state.lives,
                  onBack: () => context.go('/levels'),
                );

                final llamaAndInstruction = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AndeanProgressBanner(
                        completedSteps: state.currentStepIndex +
                            (state.stepCompleted ? 1 : 0),
                        totalSteps: state.totalSteps,
                        mood: state.llamaMood,
                        coins: profile.availableCoins,
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: orientation == Orientation.landscape 
                              ? MediaQuery.of(context).size.height * 0.35 
                              : MediaQuery.of(context).size.height * 0.25,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(state.currentStepIndex + 1, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _InstructionCard(
                                  instruction: state.exercise.steps[index].instruction,
                                  isDimmed: index < state.currentStepIndex,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final interactiveArea = Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1), // Color crema para el cuaderno
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Historial de Pasos Resueltos
                      _EquationHistory(exerciseIndex: exerciseIndex),
                      const SizedBox(height: 16),

                      // 💡 BOTÓN DE PISTA (TAREA 2)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: (state.hintActive || state.isProcessing) ? null : notifier.buyHint,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: state.hintActive
                                      ? Colors.grey.shade300
                                      : const Color(0xFFFFD600),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    if (!state.hintActive)
                                      BoxShadow(
                                        color: const Color(0xFFFFD600)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                  ],
                                  border: Border.all(
                                    color: state.hintActive
                                        ? Colors.grey
                                        : Colors.orange.shade700,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('💡',
                                        style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pista (20 🪙)',
                                      style: TextStyle(
                                        color: state.hintActive
                                            ? Colors.grey.shade600
                                            : Colors.brown.shade900,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (!state.currentStep.isMultipleChoice)
                        const Center(
                          child: Text(
                            'TOCA LOS ELEMENTOS CORRECTOS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppTheme.earthBrown,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),

                      if (!state.currentStep.isMultipleChoice)
                        Opacity(
                          opacity: (state.isProcessing && !state.hintActive) ? 0.6 : 1.0,
                          child: InteractiveEquation(
                            tokens: state.tokens,
                            selectedIds: state.selectedTokenIds,
                            correctIds: state.correctIds,
                            onTokenTapped: notifier.onTokenTapped,
                            isStepDone: state.stepCompleted,
                            errorTokenId: state.lastErrorTokenId,
                            hintIds: state.hintTokenIds,
                            isEnabled: !state.isProcessing,
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Área de Opción Múltiple (Complemento)
                      if (state.currentStep.isMultipleChoice) ...[
                        const Center(
                          child: Text(
                            'ELIGE LA RESPUESTA CORRECTA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppTheme.earthBrown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        IgnorePointer(
                          ignoring: state.isProcessing,
                          child: Opacity(
                            opacity: state.isProcessing ? 0.7 : 1.0,
                            child: _MultipleChoiceArea(
                              options: state.currentStep.options!,
                              onSelected: notifier.checkMultipleChoiceAnswer,
                              isStepDone: state.stepCompleted,
                              feedbackError: state.currentStep.feedbackError,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              );

                final bottomAction = _BottomActionArea(
                  stepCompleted: state.stepCompleted,
                  isLastStep: state.isLastStep,
                  onAdvance: notifier.advanceStep,
                );

                if (orientation == Orientation.landscape) {
                  return Column(
                    children: [
                      topBar,
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: constraints.maxWidth,
                                        ),
                                        child: llamaAndInstruction,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Expanded(child: interactiveArea),
                                  bottomAction,
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // Layout Vertical original
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    topBar,
                    llamaAndInstruction,
                    Expanded(child: interactiveArea),
                    bottomAction,
                  ],
                );
              },
            ),
          ),

          // ── Combo flotante (no empuja el layout) ─────────────────────────
          if (state.comboActive)
            Positioned(
              top: MediaQuery.of(context).padding.top + 72,
              left: 0,
              right: 0,
              child: Center(
                child: _ComboBadge(
                  key: ValueKey('combo_${state.comboCount}'),
                  count: state.comboCount,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Diálogo de finalización ───────────────────────────────────────────────

  static void _showCompletionDialog({
    required BuildContext context,
    required int rewardCoins,
    required RobotAccessoryEntity? unlockedAccessory,
    required VoidCallback onRestart,
    required VoidCallback onGoLevels,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        title: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 8),
            const Text('¡Ejercicio Completado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('¡Excelente trabajo, pequeño Chaski! 🌋',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF689F38),
                    fontWeight: FontWeight.w700)),
            if (unlockedAccessory != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(unlockedAccessory.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('¡Nuevo accesorio!',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w700)),
                          Text(unlockedAccessory.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        content: Text(
          '¡Ganaste $rewardCoins punto(s)! 🌟',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // TAREA 3: botón principal siempre vuelve a /levels
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogCtx, rootNavigator: true).pop();
                onGoLevels();
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Volver a los Niveles'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(dialogCtx, rootNavigator: true).pop();
                // TAREA 4: Carga un ejercicio aleatorio real
                onRestart();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(
                    color: AppTheme.primaryGreen, width: 2),
                foregroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Jugar de Nuevo'),
            ),
          ),
        ],
      ),
    );
  }

  // ── BottomSheet de solución (TAREA 2: solo pop) ──────────────────────────

  static void _showSolutionSheet({
    required BuildContext context,
    required List<String> correctValues,
    required String explanation,
    required VoidCallback onDismiss,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SolutionBottomSheet(
        correctValues: correctValues,
        explanation: explanation,
        onDismiss: onDismiss,
      ),
    );
  }

}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

// ── Diálogo de Solución ───────────────────────────────────────────────────────

class _SolutionBottomSheet extends StatelessWidget {
  final List<String> correctValues;
  final String explanation;
  final VoidCallback onDismiss;

  const _SolutionBottomSheet({
    required this.correctValues,
    required this.explanation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 30,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5B9BD5), Color(0xFF3A78B5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF5B9BD5)
                              .withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Center(
                      child:
                          Text('🦙', style: TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¡Tu amigo la llamita te ayuda!',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textDark)),
                      Text(
                        'No pasa nada. ¡Aprendemos juntos! 🌟',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMedium
                                .withValues(alpha: 0.80)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Respuesta correcta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.40),
                    width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryGreen, size: 20),
                      SizedBox(width: 8),
                      Text('La respuesta correcta era:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryGreenDk)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: correctValues
                        .map((val) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius:
                                    BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.15),
                                      blurRadius: 0,
                                      offset: const Offset(0, 3))
                                ],
                              ),
                              child: Text(val,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Justificación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color:
                        AppTheme.accentOrange.withValues(alpha: 0.35),
                    width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(explanation,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                            height: 1.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA — TAREA 2: SOLO pop(). El notifier avanza solo después.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDismiss, // <- Navigator.pop() + autoCompleteStep()
                icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                label: const Text('¡Entendido, continuar!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  textStyle: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── TopBar ──────────────────────────────────────────────────────────────────

class _PracticeTopBar extends StatelessWidget {
  final bool isTutorial;
  final String title;
  final int pieces;
  final int currentStep;
  final int totalSteps;
  final LlamaMood llamaMood;
  final int lives;
  final VoidCallback onBack;

  const _PracticeTopBar({
    this.isTutorial = false,
    required this.title,
    required this.pieces,
    required this.currentStep,
    required this.totalSteps,
    required this.llamaMood,
    required this.lives,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF33691E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 28),
                ),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800),
                      overflow: isTutorial ? TextOverflow.visible : TextOverflow.ellipsis),
                ),
                const SizedBox(width: 6),
                if (!isTutorial) _LivesIndicator(lives: lives),
                const SizedBox(width: 8),
                if (!isTutorial) _AvatarMiniature(mood: llamaMood),
                if (!isTutorial) const SizedBox(width: 10),
                if (!isTutorial) _PointsCounter(pieces: pieces),
              ],
            ),
          ),
          _StepProgressBar(current: currentStep, total: totalSteps),
        ],
      ),
    );
  }
}

// ── Corazones de vidas ──────────────────────────────────────────────────────

class _LivesIndicator extends StatelessWidget {
  final int lives;
  const _LivesIndicator({required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < lives;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            key: ValueKey('heart_${i}_$filled'),
            filled
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: filled
                ? const Color(0xFFFF5252)
                : Colors.white.withValues(alpha: 0.45),
            size: 22,
          ),
        );
      }),
    );
  }
}

// ── Avatar miniatura ──────────────────────────────────────────────────────────

class _AvatarMiniature extends StatefulWidget {
  final LlamaMood mood;
  const _AvatarMiniature({required this.mood});
  @override
  State<_AvatarMiniature> createState() => _AvatarMiniatureState();
}

class _AvatarMiniatureState extends State<_AvatarMiniature>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450));
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 60),
    ]).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_AvatarMiniature old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood &&
        (widget.mood == LlamaMood.happy ||
            widget.mood == LlamaMood.victory)) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _glowColor => switch (widget.mood) {
        LlamaMood.happy   => const Color(0xFF00E676),
        LlamaMood.error   => AppTheme.errorRed,
        LlamaMood.victory => const Color(0xFFFFD700),
        _                 => Colors.white38,
      };

  String get _moodEmoji => switch (widget.mood) {
        LlamaMood.happy   => '✨',
        LlamaMood.victory => '🏆',
        LlamaMood.error   => '😢',
        _                 => '🦙',
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.translate(
          offset: Offset(0, _bounce.value), child: child),
      child: SizedBox(
        width: 36,
        height: 36,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                  color: _glowColor.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 1)
            ],
          ),
          child: Center(child: Text(_moodEmoji, style: const TextStyle(fontSize: 18))),
        ),
      ),
    );
  }
}

// ── Contador de puntos ───────────────────────────────────────────────────────

class _PointsCounter extends StatelessWidget {
  final int pieces;
  const _PointsCounter({required this.pieces});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌟', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text('$pieces',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Progress bar ─────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _StepProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: current / total),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) => LinearProgressIndicator(
        value: value,
        minHeight: 7,
        backgroundColor: Colors.white24,
        valueColor:
            const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

// ── Burbuja de instrucción ───────────────────────────────────────────────────

// ── Burbuja de instrucción ───────────────────────────────────────────────────

class _InstructionCard extends StatelessWidget {
  final String instruction;
  final bool isDimmed;

  const _InstructionCard({
    required this.instruction,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDimmed ? 0.6 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDk],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Center(
              child: Text('🦙', style: TextStyle(fontSize: 22))),
        ),
        CustomPaint(
            painter: _BubbleTailPainter(),
            size: const Size(12, 20)),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: AppTheme.speechBubbleDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    MathTokenWidget.formatMathText(instruction), // TAREA 4
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = AppTheme.primaryGreen.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final path = Path()
      ..moveTo(size.width, size.height * 0.25)
      ..lineTo(0, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.75)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter old) => false;
}

// ── Área de Opción Múltiple ──────────────────────────────────────────────────

class _MultipleChoiceArea extends StatelessWidget {
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool isStepDone;
  final String feedbackError;

  const _MultipleChoiceArea({
    required this.options,
    required this.onSelected,
    required this.isStepDone,
    required this.feedbackError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...options.map((opt) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isStepDone ? null : () => onSelected(opt),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.textDark,
                  elevation: 6,
                  shadowColor: AppTheme.skyBlue.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: AppTheme.skyBlue.withValues(alpha: 0.2),
                        width: 2),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    MathTokenWidget.formatMathText(opt),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Nunito'),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Botón de avance ──────────────────────────────────────────────────────────

class _BottomActionArea extends StatelessWidget {
  final bool stepCompleted;
  final bool isLastStep;
  final Future<void> Function() onAdvance;

  const _BottomActionArea({
    required this.stepCompleted,
    required this.isLastStep,
    required this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.12),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -4)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, -2)),
        ],
      ),
      child: AnimatedOpacity(
        opacity: stepCompleted ? 1.0 : 0.32,
        duration: const Duration(milliseconds: 400),
        child: Center(
          child: ElevatedButton.icon(
            onPressed: stepCompleted ? onAdvance : null,
            icon: Icon(
                isLastStep
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                size: 26),
            label: Text(isLastStep
                ? '¡Terminar Ejercicio!'
                : 'Siguiente Paso  →'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Combo Badge flotante ──────────────────────────────────────────────────────

class _ComboBadge extends StatelessWidget {
  final int count;
  const _ComboBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFFF6F00).withValues(alpha: 0.55),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¡COMBO!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        height: 1)),
                Text('x2 puntos  •  racha $count',
                    style: const TextStyle(
                        color: Color(0xFFFFE082),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2)),
              ],
            ),
            const SizedBox(width: 8),
            const Text('⭐', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

// ── Historial de Pasos Optimizados ──────────────────────────────────────────

class _EquationHistory extends ConsumerWidget {
  final int exerciseIndex;

  const _EquationHistory({required this.exerciseIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo se reconstruye cuando la lista de historial cambia
    final history = ref.watch(practiceProvider(exerciseIndex).select((s) => s.equationHistory));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(history.length, (index) {
        final equationText = history[index];
        
        String formattedEquation = equationText;
        if (index == 0) {
          formattedEquation = '$equationText =';
        } else {
          formattedEquation = '= $equationText';
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Center(
            child: MathNotebookLine(
              equation: formattedEquation,
              showBoxesAndColors: index == 0,
            ),
          ),
        );
      }),
    );
  }
}
