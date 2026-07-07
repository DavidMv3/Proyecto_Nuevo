import 'dart:async';
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
import '../widgets/latex_rich_text.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/entities/exercise_entity.dart';


class PracticeScreen extends ConsumerStatefulWidget {
  final int exerciseIndex;
  const PracticeScreen({super.key, required this.exerciseIndex});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _instructionScrollController = ScrollController();
  final GlobalKey _equationHistoryEndKey = GlobalKey();
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final state = ref.read(practiceProvider(widget.exerciseIndex));
      if (!state.exerciseFinished) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_equationHistoryEndKey.currentContext != null) {
        Scrollable.ensureVisible(
          _equationHistoryEndKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.5, // Enfocar en el medio para ver la última parte y algo de las opciones
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
      if (_instructionScrollController.hasClients) {
        _instructionScrollController.animateTo(
          _instructionScrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _instructionScrollController.dispose();
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
          !next.showGameOverDialog) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LatexRichText(
                      text: next.errorSnackMessage,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
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
              duration: const Duration(seconds: 4),
            ),
          );
      }
    });

    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      if (!next.exerciseFinished || (prev?.exerciseFinished ?? false)) return;
      _showVictoryDialog(
        context: context,
        rewardCoins: next.exercise.rewardCoins,
        unlockedAccessory: next.newlyUnlockedAccessory,
        elapsedSeconds: _elapsedSeconds,
        onGoLevels: () => context.go('/levels'),
        onRestart: () {
          final repo = ref.read(exerciseRepositoryProvider);
          final profile = ref.read(playerProfileProvider);
          final difficulty = next.exercise.difficulty;
           
          if (difficulty == 0) {
            ref.read(playerProfileProvider.notifier).updateLastPlayedProgress(
              level: 0,
              exerciseId: repo.tutorialExercise.id,
              stepIndex: 0,
            );
            ref.invalidate(practiceProvider(exerciseIndex));
            context.pushReplacement('/practice/-1');
            return;
          }
           
          List<ExerciseEntity> pool = difficulty == 1 
              ? repo.easyExercises 
              : (difficulty == 2 ? repo.mediumExercises : repo.hardExercises);
           
          if (pool.isNotEmpty) {
            final uncompleted = pool.where((e) => !profile.completedExerciseIds.contains(e.id)).toList();
             
            ExerciseEntity targetEx;
            if (uncompleted.isNotEmpty) {
              targetEx = uncompleted.first;
            } else {
              var available = pool.where((e) => e.id != next.exercise.id).toList();
              if (available.isEmpty) available = pool;
              targetEx = available[DateTime.now().millisecond % available.length];
            }
             
            final globalIndex = repo.getAll().indexOf(targetEx);
             
            ref.read(playerProfileProvider.notifier).updateLastPlayedProgress(
              level: difficulty,
              exerciseId: targetEx.id,
              stepIndex: 0,
            );
             
            if (globalIndex == exerciseIndex) {
              setState(() { _elapsedSeconds = 0; });
              ref.read(practiceProvider(exerciseIndex).notifier).restart();
            } else {
              context.pushReplacement('/practice/$globalIndex');
            }
          }
        },
      );
    });

    // ── Vida 0 → Diálogo de Game Over ────────────────────────────────
    ref.listen<PracticeState>(practiceProvider(exerciseIndex), (prev, next) {
      if (!next.showGameOverDialog || (prev?.showGameOverDialog ?? false)) {
        return;
      }
      _showGameOverDialog(
        context: context,
        onRestart: () {
          setState(() { _elapsedSeconds = 0; });
          notifier.restart();
        },
        onGoLevels: () {
          context.go('/levels');
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
      floatingActionButton: (state.isProcessing || state.hintActive) ? null : FloatingActionButton.small(
        onPressed: notifier.buyHint,
        backgroundColor: const Color(0xFFFFD600),
        child: const Text('💡', style: TextStyle(fontSize: 20)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                  elapsedSeconds: _elapsedSeconds,
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
                              ? MediaQuery.of(context).size.height * 0.15 
                              : MediaQuery.of(context).size.height * 0.12,
                        ),
                        child: SingleChildScrollView(
                          controller: _instructionScrollController,
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
                      SizedBox(key: _equationHistoryEndKey, height: 16),

                      if (!state.currentStep.isMultipleChoice)
                        Center(
                          child: Text(
                            'TOCA LOS ELEMENTOS CORRECTOS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppTheme.earthBrown.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      if (!state.currentStep.isMultipleChoice)
                        Opacity(
                          opacity: (state.isProcessing && !state.hintActive) ? 0.6 : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (state.equationHistory.length > 1 || 
                                    (state.equationHistory.length == 1 && state.equationHistory.first.replaceAll(' ', '') != state.tokens.map((t)=>t.value).join(' ').replaceAll(' ', '')))
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4.0),
                                    child: Text('=', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black54)),
                                  ),
                                Flexible(
                                  child: InteractiveEquation(
                                    tokens: state.tokens,
                                    selectedIds: state.selectedTokenIds,
                                    correctIds: state.correctIds,
                                    onTokenTapped: notifier.onTokenTapped,
                                    isStepDone: state.stepCompleted,
                                    errorTokenId: state.lastErrorTokenId,
                                    hintIds: state.hintTokenIds,
                                    isEnabled: !state.isProcessing,
                                    showBlockBoxes: state.showBoxesOnCurrentStep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (state.currentStep.isMultipleChoice)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Divider(height: 16, thickness: 1, color: Colors.black12),
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
                              const SizedBox(height: 4),
                              IgnorePointer(
                                ignoring: state.isProcessing,
                                child: Opacity(
                                  opacity: state.isProcessing ? 0.7 : 1.0,
                                  child: _MultipleChoiceArea(
                                    options: state.shuffledOptions ?? state.currentStep.options ?? [],
                                    onSelected: notifier.checkMultipleChoiceAnswer,
                                    isStepDone: state.stepCompleted,
                                    feedbackError: state.currentStep.feedbackError,
                                    incorrectAnswers: state.incorrectAnswers,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  static void _showVictoryDialog({
    required BuildContext context,
    required int rewardCoins,
    required RobotAccessoryEntity? unlockedAccessory,
    required VoidCallback onGoLevels,
    required VoidCallback onRestart,
    required int elapsedSeconds,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
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
            const Text('¡Excelente trabajo, joven Chaski! 🌋',
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Ganaste $rewardCoins punto(s)! 🌟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Tiempo total: ${(elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(elapsedSeconds % 60).toString().padLeft(2, '0')} ⏱️',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textMedium),
            ),
          ],
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
      ),
    );
  }

  // ── Diálogo de Game Over ──────────────────────────

  static void _showGameOverDialog({
    required BuildContext context,
    required VoidCallback onRestart,
    required VoidCallback onGoLevels,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          title: Column(
            children: [
              const Text('😢', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              const Text('¡Te quedaste sin vidas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Pero no pasa nada, ¡lo importante es seguir intentando!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          content: const SizedBox(height: 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(dialogCtx, rootNavigator: true).pop();
                  onRestart();
                },
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Intentar de Nuevo'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(dialogCtx, rootNavigator: true).pop();
                  onGoLevels();
                },
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Salir a Niveles'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                  foregroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ============================================================================
// WIDGETS AUXILIARES
// ============================================================================

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
  final int elapsedSeconds;

  const _PracticeTopBar({
    this.isTutorial = false,
    required this.title,
    required this.pieces,
    required this.currentStep,
    required this.totalSteps,
    required this.llamaMood,
    required this.lives,
    required this.onBack,
    this.elapsedSeconds = 0,
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
                if (!isTutorial) const SizedBox(width: 10),
                if (!isTutorial) _TimerDisplay(seconds: elapsedSeconds),
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

// ── Timer Display ─────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  const _TimerDisplay({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final minutesStr = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white38, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text('$minutesStr:$secondsStr',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
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
                  child: LatexRichText(
                    text: instruction,
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
  final Set<String> incorrectAnswers;

  const _MultipleChoiceArea({
    required this.options,
    required this.onSelected,
    required this.isStepDone,
    required this.feedbackError,
    required this.incorrectAnswers,
  });

  /// Detecta si una opción contiene notación matemática que deba
  /// renderizarse con LaTeX (potencias, raíces, operadores, etc.)
  static bool _isMathOption(String opt) {
    // Si contiene letras del alfabeto de palabras en español, no es una opción puramente matemática
    final cleanText = opt.replaceAll('sqrt', '').replaceAll(RegExp(r'root\d*'), '');
    final hasSpanishLetters = RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ]').hasMatch(cleanText);
    if (hasSpanishLetters) return false;

    // Contiene potencias, raíces o operadores aritméticos
    if (opt.contains('^') || opt.contains('sqrt')) return true;
    // Es puramente numérico (un resultado)
    if (RegExp(r'^-?\d+\.?\d*$').hasMatch(opt.trim())) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...options.map((opt) {
          final useMath = _isMathOption(opt);
          final bool isIncorrect = incorrectAnswers.contains(opt);

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isStepDone || isIncorrect) ? null : () => onSelected(opt),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  backgroundColor: isIncorrect ? const Color(0xFFFFEBEE) : Colors.white,
                  foregroundColor: isIncorrect ? const Color(0xFFC62828) : AppTheme.textDark,
                  disabledBackgroundColor: isIncorrect ? const Color(0xFFFFEBEE) : null,
                  disabledForegroundColor: isIncorrect ? const Color(0xFFC62828) : null,
                  elevation: isIncorrect ? 2 : 6,
                  shadowColor: isIncorrect
                      ? Colors.transparent
                      : AppTheme.skyBlue.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isIncorrect
                          ? const Color(0xFFEF9A9A)
                          : AppTheme.skyBlue.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isIncorrect) ...[
                        const Text('❌', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: useMath
                            ? MathNotebookLine(
                                equation: opt,
                                showBoxesAndColors: false,
                              )
                            : LatexRichText(
                                text: opt,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Nunito',
                                  height: 1.3,
                                  decoration: isIncorrect ? TextDecoration.lineThrough : null,
                                ),
                              ),
                      ),
                    ],
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
    final state = ref.watch(practiceProvider(exerciseIndex));
    final isInteractive = !state.currentStep.isMultipleChoice;

    List<Widget> lines = [];

    // ── Historial unificado: usa equationHistory + workingLine directamente ──
    {
      final history = state.equationHistory;
      final currentTokensStr = state.tokens.map((t) => t.value).join(' ');

      final List<String> rawExpressions = [];
      for (final h in history) {
        if (h.trim().isNotEmpty) {
          rawExpressions.add(h);
        }
      }

      final workingLine = state.workingLine;
      final currentOverride = state.currentStep.expressionOverride;
      String? activeLine;
      if (workingLine != null && workingLine.trim().isNotEmpty) {
        activeLine = workingLine;
      } else if (currentOverride != null && state.stepCompleted && currentOverride.trim().isNotEmpty) {
        activeLine = currentOverride;
      }

      if (activeLine != null) {
        final cleanActive = activeLine.replaceAll(' ', '').replaceAll('____', '').replaceAll('\$', '');
        final lastClean = rawExpressions.isEmpty ? '' : rawExpressions.last.replaceAll(' ', '').replaceAll('____', '').replaceAll('\$', '');
        if (rawExpressions.isEmpty || lastClean != cleanActive) {
          rawExpressions.add(activeLine);
        }
      }

      // Show all expressions from history — each was explicitly added as a meaningful step.
      // Only skip lines that duplicate the currently-interactive token row.
      final List<String> filteredExpressions = [];
      if (rawExpressions.isNotEmpty) {
        final firstExpr = rawExpressions.first;
        final isFirstDuplicate = isInteractive && firstExpr.replaceAll(' ', '') == currentTokensStr.replaceAll(' ', '');
        if (!isFirstDuplicate) {
          filteredExpressions.add(firstExpr);
        }

        for (int i = 1; i < rawExpressions.length; i++) {
          final current = rawExpressions[i];

          // Skip if interactive and it matches the interactive tokens to avoid duplicates
          if (isInteractive && current.replaceAll(' ', '') == currentTokensStr.replaceAll(' ', '')) {
            continue;
          }

          filteredExpressions.add(current);
        }
      }

      for (int i = 0; i < filteredExpressions.length; i++) {
        final equationText = filteredExpressions[i];
        final isBase = (equationText.replaceAll(' ', '') == state.exercise.baseExpression.replaceAll(' ', ''));

        String formattedEquation;
        if (isBase) {
          formattedEquation = '$equationText =';
        } else {
          formattedEquation = '= $equationText';
        }

        final isActive = (activeLine != null && equationText == activeLine);
        final showBoxes = isActive ? state.showBoxesOnCurrentStep : state.showBlockBoxes;
        lines.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Center(
              child: RepaintBoundary(
                child: MathNotebookLine(
                  equation: formattedEquation,
                  showBoxesAndColors: showBoxes,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lines,
    );
  }
}

class _TokenSegment {
  final List<String> base;
  final List<String> current;
  final List<int> baseIndices;

  bool get isModified {
    if (base.length != current.length) return true;
    for (int k = 0; k < base.length; k++) {
      if (base[k] != current[k]) return true;
    }
    return false;
  }

  _TokenSegment(this.base, this.current, this.baseIndices);
}

String getProgressiveExpression(
  String baseExpr, 
  String currentExpr, {
  required bool isCompleted,
  int? stepIndex,
  required ExerciseEntity exercise,
  int? activeStepIndex,
  bool? activeStepCompleted,
}) {
  final baseTokens = baseExpr.trim().split(RegExp(r'\s+'));
  final currentTokens = currentExpr.trim().split(RegExp(r'\s+'));

  if (currentTokens.length <= 1) {
    return isCompleted ? currentExpr : '';
  }

  // Calcular profundidades de paréntesis y corchetes en baseTokens
  final depths = <int>[];
  int currentDepth = 0;
  for (final token in baseTokens) {
    if (token == '(' || token == '[' || token == '{' || token.contains('(') || token.contains('[') || token.contains('{')) {
      currentDepth++;
    }
    depths.add(currentDepth);
    if (token == ')' || token == ']' || token == '}' || token.contains(')') || token.contains(']') || token.contains('}')) {
      currentDepth--;
    }
  }

  bool isOperatorAt(int idx) {
    if (idx < 0 || idx >= baseTokens.length) return false;
    final val = baseTokens[idx];
    if (val == '(' || val == ')' || val == '[' || val == ']' || val == '{' || val == '}') {
      return false;
    }
    if (['*', '/', '^', 'x', '×', '÷'].contains(val) || val.contains('sqrt') || val.contains('root')) {
      return true;
    }
    return false;
  }

  // ignore: unused_element
  bool isOperationToken(int idx) {
    if (idx < 0 || idx >= baseTokens.length) return false;
    final val = baseTokens[idx];
    if (val == '(' || val == ')' || val == '[' || val == ']' || val == '{' || val == '}') {
      return false;
    }
    if (isOperatorAt(idx)) return true;
    if (idx > 0 && isOperatorAt(idx - 1)) return true;
    if (idx < baseTokens.length - 1 && isOperatorAt(idx + 1)) return true;
    return false;
  }

  // Helper para identificar el bloque (separados por + o - a profundidad 0) de cada token
  int getBlockIndex(int tokenIdx) {
    int block = 0;
    for (int k = 0; k <= tokenIdx; k++) {
      final val = baseTokens[k];
      final depth = depths[k];
      if (depth == 0 && (val == '+' || val == '-')) {
        block++;
      }
    }
    return block;
  }

  // Alineación LCS
  final n = baseTokens.length;
  final m = currentTokens.length;
  final dp = List.generate(n + 1, (_) => List.filled(m + 1, 0));

  for (int i = 1; i <= n; i++) {
    for (int j = 1; j <= m; j++) {
      if (baseTokens[i - 1] == currentTokens[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
      }
    }
  }

  final baseMatched = List.filled(n, false);
  final currentMatched = List.filled(m, false);
  int i = n;
  int j = m;
  while (i > 0 && j > 0) {
    if (baseTokens[i - 1] == currentTokens[j - 1]) {
      baseMatched[i - 1] = true;
      currentMatched[j - 1] = true;
      i--;
      j--;
    } else if (dp[i - 1][j] >= dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  final segments = <_TokenSegment>[];
  int basePtr = 0;
  int currentPtr = 0;

  while (basePtr < n || currentPtr < m) {
    if (basePtr < n && currentPtr < m && baseMatched[basePtr] && currentMatched[currentPtr] && baseTokens[basePtr] == currentTokens[currentPtr]) {
      segments.add(_TokenSegment([baseTokens[basePtr]], [currentTokens[currentPtr]], [basePtr]));
      basePtr++;
      currentPtr++;
    } else {
      int nextBaseMatch = basePtr;
      while (nextBaseMatch < n && !baseMatched[nextBaseMatch]) {
        nextBaseMatch++;
      }
      int nextCurrentMatch = currentPtr;
      while (nextCurrentMatch < m && !currentMatched[nextCurrentMatch]) {
        nextCurrentMatch++;
      }

      final baseSeg = baseTokens.sublist(basePtr, nextBaseMatch);
      final currentSeg = currentTokens.sublist(currentPtr, nextCurrentMatch);
      final baseIndices = List.generate(nextBaseMatch - basePtr, (k) => basePtr + k);
      segments.add(_TokenSegment(baseSeg, currentSeg, baseIndices));

      basePtr = nextBaseMatch;
      currentPtr = nextCurrentMatch;
    }
  }

  int lastModifiedIdx = -1;
  if (isCompleted) {
    for (int k = 0; k < segments.length; k++) {
      if (segments[k].isModified) {
        lastModifiedIdx = k;
      }
    }
  } else {
    for (int k = 0; k < segments.length; k++) {
      if (segments[k].isModified) {
        lastModifiedIdx = k;
        break;
      }
    }
  }

  // Identificar cuál es el bloque de la modificación activa
  int modifiedBlockIdx = 0;
  if (lastModifiedIdx != -1) {
    for (final idx in segments[lastModifiedIdx].baseIndices) {
      final b = getBlockIndex(idx);
      if (b > modifiedBlockIdx) {
        modifiedBlockIdx = b;
      }
    }
  }

  int getSegmentBlock(int segIdx) {
    final seg = segments[segIdx];
    if (seg.baseIndices.isNotEmpty) {
      return getBlockIndex(seg.baseIndices.first);
    }
    for (int k = segIdx - 1; k >= 0; k--) {
      if (segments[k].baseIndices.isNotEmpty) {
        return getBlockIndex(segments[k].baseIndices.last);
      }
    }
    for (int k = segIdx + 1; k < segments.length; k++) {
      if (segments[k].baseIndices.isNotEmpty) {
        return getBlockIndex(segments[k].baseIndices.first);
      }
    }
    return 0;
  }

  // ignore: unused_element
  bool blockHasOperations(int bIdx) {
    for (int k = 0; k < segments.length; k++) {
      if (getSegmentBlock(k) == bIdx) {
        for (final token in segments[k].current) {
          if (['*', '/', '^', 'x', '×', '÷'].contains(token) || token.contains('sqrt') || token.contains('root')) {
            return true;
          }
        }
      }
    }
    return false;
  }

  int getModifiedBlockIdx(String bExpr, String cExpr) {
    final bTokens = bExpr.trim().split(RegExp(r'\s+'));
    final cTokens = cExpr.trim().split(RegExp(r'\s+'));

    if (cTokens.length <= 1) return 0;

    final dps = <int>[];
    int cDepth = 0;
    for (final token in bTokens) {
      if (token == '(' || token == '[' || token == '{' || token.contains('(') || token.contains('[') || token.contains('{')) {
        cDepth++;
      }
      dps.add(cDepth);
      if (token == ')' || token == ']' || token == '}' || token.contains(')') || token.contains(']') || token.contains('}')) {
        cDepth--;
      }
    }

    int getBIndex(int tokenIdx) {
      int block = 0;
      for (int k = 0; k <= tokenIdx; k++) {
        final val = bTokens[k];
        final depth = dps[k];
        if (depth == 0 && (val == '+' || val == '-')) {
          block++;
        }
      }
      return block;
    }

    final nL = bTokens.length;
    final mL = cTokens.length;
    final dpTable = List.generate(nL + 1, (_) => List.filled(mL + 1, 0));

    for (int x = 1; x <= nL; x++) {
      for (int y = 1; y <= mL; y++) {
        if (bTokens[x - 1] == cTokens[y - 1]) {
          dpTable[x][y] = dpTable[x - 1][y - 1] + 1;
        } else {
          dpTable[x][y] = dpTable[x - 1][y] > dpTable[x][y - 1] ? dpTable[x - 1][y] : dpTable[x][y - 1];
        }
      }
    }

    final bMatched = List.filled(nL, false);
    final cMatched = List.filled(mL, false);
    int x = nL;
    int y = mL;
    while (x > 0 && y > 0) {
      if (bTokens[x - 1] == cTokens[y - 1]) {
        bMatched[x - 1] = true;
        cMatched[y - 1] = true;
        x--;
        y--;
      } else if (dpTable[x - 1][y] >= dpTable[x][y - 1]) {
        x--;
      } else {
        y--;
      }
    }

    final segs = <_TokenSegment>[];
    int bPtr = 0;
    int cPtr = 0;

    while (bPtr < nL || cPtr < mL) {
      if (bPtr < nL && cPtr < mL && bMatched[bPtr] && cMatched[cPtr] && bTokens[bPtr] == cTokens[cPtr]) {
        segs.add(_TokenSegment([bTokens[bPtr]], [cTokens[cPtr]], [bPtr]));
        bPtr++;
        cPtr++;
      } else {
        int nextBaseMatch = bPtr;
        while (nextBaseMatch < nL && !bMatched[nextBaseMatch]) {
          nextBaseMatch++;
        }
        int nextCurrentMatch = cPtr;
        while (nextCurrentMatch < mL && !cMatched[nextCurrentMatch]) {
          nextCurrentMatch++;
        }

        final baseSeg = bTokens.sublist(bPtr, nextBaseMatch);
        final currentSeg = cTokens.sublist(cPtr, nextCurrentMatch);
        final baseIndices = List.generate(nextBaseMatch - bPtr, (k) => bPtr + k);
        segs.add(_TokenSegment(baseSeg, currentSeg, baseIndices));

        bPtr = nextBaseMatch;
        cPtr = nextCurrentMatch;
      }
    }

    int lastModIdx = -1;
    for (int k = 0; k < segs.length; k++) {
      if (segs[k].isModified) {
        lastModIdx = k;
      }
    }

    int modBlockIdx = 0;
    if (lastModIdx != -1) {
      for (final idx in segs[lastModIdx].baseIndices) {
        final b = getBIndex(idx);
        if (b > modBlockIdx) {
          modBlockIdx = b;
        }
      }
    }
    return modBlockIdx;
  }

  int getStepBlockIdxRelative(int j, String expr) {
    for (int idx = j; idx < exercise.steps.length; idx++) {
      final override = exercise.steps[idx].expressionOverride;
      if (override != null) {
        return getModifiedBlockIdx(expr, override);
      }
    }
    return -1;
  }

  // ignore: unused_element
  bool isBlockModifiedByPastSteps(int blockIdx) {
    if (stepIndex == null) return false;
    for (int j = 0; j <= stepIndex; j++) {
      if (getStepBlockIdxRelative(j, baseExpr) == blockIdx) {
        return true;
      }
    }
    return false;
  }

  bool isBlockIdxHidden(int blockIdx) {
    return false;
  }

  bool isGroupingSymbol(String token) {
    return token == '(' || token == '[' || token == '{';
  }

  // ignore: unused_element
  bool isOperandToken(String token) {
    final clean = token.replaceAll(RegExp(r'[\(\)\[\]\{\}\+\-\*\/x×÷\^]'), '').trim();
    return clean.isNotEmpty;
  }

  final output = <String>[];

  void addSegmentTokens(List<String> tokens, List<int> baseIndices, int blockIdx) {
    if (isBlockIdxHidden(blockIdx)) {
      for (int j = 0; j < tokens.length; j++) {
        final t = tokens[j];
        final baseIdx = (j < baseIndices.length) ? baseIndices[j] : -1;
        
        bool show = false;
        if (isGroupingSymbol(t)) {
          show = true;
        } else if (baseIdx != -1) {
          final depth = depths[baseIdx];
          if (depth == 0 && (t == '+' || t == '-')) {
            show = true;
          }
        }
        
        if (show) {
          output.add(t);
        }
      }
    } else {
      output.addAll(tokens);
    }
  }

  for (int k = 0; k < segments.length; k++) {
    final seg = segments[k];
    final blockIdx = getSegmentBlock(k);

    if (k < lastModifiedIdx) {
      addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
    } else if (k == lastModifiedIdx) {
      if (isCompleted) {
        addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
      } else {
        for (final token in seg.base) {
          if (token == '(' || token == '[' || token == '{' || token.startsWith('sqrt(') || token.startsWith('root') || token.endsWith('(')) {
            output.add(token);
          } else {
            break;
          }
        }
        break;
      }
    } else {
      addSegmentTokens(seg.current, seg.baseIndices, blockIdx);
    }
  }

  while (output.isNotEmpty && output.last == '^') {
    output.removeLast();
  }

  return output.join(' ');
}


