import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/feedback_service.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/entities/equation_token.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/robot_accessory_entity.dart';
import '../../domain/entities/step_entity.dart';
import 'player_profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO VISUAL DEL ROBOT GUARDIÁN
// ─────────────────────────────────────────────────────────────────────────────

enum LlamaMood { idle, happy, error, thinking, victory }

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DEL JUEGO
// ─────────────────────────────────────────────────────────────────────────────

class PracticeState {
  final ExerciseEntity exercise;
  final List<EquationToken> tokens;
  final int currentStepIndex;
  final Set<String> selectedTokenIds;
  final bool stepCompleted;
  final bool exerciseFinished;
  final LlamaMood llamaMood;
  final RobotAccessoryEntity? newlyUnlockedAccessory;

  // ── Combos ────────────────────────────────────────────────────────────────
  final int comboCount;
  final bool comboActive;

  // ── RF04 / RF06: Sistema de Vidas ─────────────────────────────────────────
  /// Vidas restantes para el paso actual (3 → 2 → 1 → 0).
  final int lives;

  /// true cuando lives == 0 → la UI debe mostrar el BottomSheet de solución.
  final bool showSolutionDialog;

  // ── Feedback de error silencioso (flash en token) ─────────────────────────
  /// ID del último token incorrecto. Pasa a InteractiveEquation para el flash.
  final String? lastErrorTokenId;

  // ── SnackBar genérico (TAREA 1) ──────────────────────────────────────────
  /// Mensaje corto GENÉRICO para mostrar en un SnackBar cuando lives > 0.
  /// Es un counter que se incrementa en cada error para que el listener
  /// de la UI lo distinga aunque el texto sea el mismo.
  final int errorSnackVersion;
  final String errorSnackMessage;
  
  // ── SISTEMA DE PISTAS (TAREA 4) ──────────────────────────────────────────
  final Set<String> hintTokenIds;
  final bool hintActive;
  final bool isProcessing;

  // ── Historial Cuaderno ───────────────────────────────────────────────────
  final List<String> equationHistory;

  const PracticeState({
    required this.exercise,
    required this.tokens,
    required this.currentStepIndex,
    required this.selectedTokenIds,
    required this.stepCompleted,
    required this.exerciseFinished,
    required this.llamaMood,
    required this.hintTokenIds,
    required this.hintActive,
    required this.equationHistory,
    this.newlyUnlockedAccessory,
    this.comboCount = 0,
    this.comboActive = false,
    this.lives = 3,
    this.showSolutionDialog = false,
    this.lastErrorTokenId,
    this.errorSnackVersion = 0,
    this.errorSnackMessage = '',
    this.isProcessing = false,
  });

  // Getters de conveniencia
  StepEntity get currentStep => exercise.steps[currentStepIndex];
  Set<String> get correctIds => currentStep.correctIds.toSet();
  int get totalSteps => exercise.steps.length;
  int get displayStep => currentStepIndex + 1;

  /// Valores reales de los tokens correctos para el diálogo de solución.
  /// Usa la lista ordenada de correctIds (NO el Set) para preservar el orden.
  List<String> get correctTokenValues {
    if (currentStep.isMultipleChoice && currentStep.correctAnswer != null) {
      return [currentStep.correctAnswer!];
    }
    // Iteramos sobre la lista original (ordenada) del step, no sobre el Set
    return currentStep.correctIds.map((id) {
      try {
        return tokens.firstWhere((t) => t.id == id).value;
      } catch (_) {
        return id;
      }
    }).toList();
  }

  bool get isLastStep => currentStepIndex >= exercise.steps.length - 1;

  factory PracticeState.fromExercise(ExerciseEntity exercise, {int initialStepIndex = 0}) {
    final safeIndex = (initialStepIndex >= exercise.steps.length) ? 0 : initialStepIndex;
    final step = exercise.steps[safeIndex];
    final initialExpr = step.expressionOverride ?? exercise.baseExpression;
    return PracticeState(
      exercise: exercise,
      tokens: EquationToken.fromExpression(initialExpr),
      currentStepIndex: safeIndex,
      selectedTokenIds: const {},
      stepCompleted: false,
      exerciseFinished: false,
      llamaMood: LlamaMood.idle,
      hintTokenIds: const {},
      hintActive: false,
      lives: 3,
      showSolutionDialog: false,
      equationHistory: [initialExpr],
    );
  }

  PracticeState copyWith({
    List<EquationToken>? tokens,
    int? currentStepIndex,
    Set<String>? selectedTokenIds,
    bool? stepCompleted,
    bool? exerciseFinished,
    LlamaMood? llamaMood,
    RobotAccessoryEntity? newlyUnlockedAccessory,
    bool clearAccessory = false,
    int? comboCount,
    bool? comboActive,
    int? lives,
    bool? showSolutionDialog,
    String? lastErrorTokenId,
    bool clearErrorToken = false,
    int? errorSnackVersion,
    String? errorSnackMessage,
    Set<String>? hintTokenIds,
    bool? hintActive,
    bool? isProcessing,
    List<String>? equationHistory,
  }) {
    return PracticeState(
      exercise: exercise,
      tokens: tokens ?? this.tokens,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      selectedTokenIds: selectedTokenIds ?? this.selectedTokenIds,
      stepCompleted: stepCompleted ?? this.stepCompleted,
      exerciseFinished: exerciseFinished ?? this.exerciseFinished,
      llamaMood: llamaMood ?? this.llamaMood,
      hintTokenIds: hintTokenIds ?? this.hintTokenIds,
      hintActive: hintActive ?? this.hintActive,
      newlyUnlockedAccessory: clearAccessory
          ? null
          : (newlyUnlockedAccessory ?? this.newlyUnlockedAccessory),
      comboCount: comboCount ?? this.comboCount,
      comboActive: comboActive ?? this.comboActive,
      lives: lives ?? this.lives,
      showSolutionDialog: showSolutionDialog ?? this.showSolutionDialog,
      lastErrorTokenId:
          clearErrorToken ? null : (lastErrorTokenId ?? this.lastErrorTokenId),
      errorSnackVersion: errorSnackVersion ?? this.errorSnackVersion,
      errorSnackMessage: errorSnackMessage ?? this.errorSnackMessage,
      isProcessing: isProcessing ?? this.isProcessing,
      equationHistory: equationHistory ?? this.equationHistory,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class PracticeNotifier extends StateNotifier<PracticeState> {
  final Ref _ref;
  bool _isProcessing = false;

  PracticeNotifier(this._ref, ExerciseEntity exercise, {int initialStepIndex = 0})
      : super(PracticeState.fromExercise(exercise, initialStepIndex: initialStepIndex));

  // ── 1. El niño toca un token ──────────────────────────────────────────────

  Future<void> onTokenTapped(String tokenId) async {
    if (_isProcessing) return;
    if (state.stepCompleted || state.exerciseFinished) return;
    if (state.showSolutionDialog) return;
    // Si el paso es de opción múltiple, ignoramos toques en la ecuación
    if (state.currentStep.isMultipleChoice) return;

    _isProcessing = true;
    try {
      // Limpia flash de error anterior
      state = state.copyWith(
        llamaMood: LlamaMood.idle,
        clearErrorToken: true,
      );

      final correctIds = state.correctIds;

      // Deselección
      if (state.selectedTokenIds.contains(tokenId)) {
        final updated = Set<String>.from(state.selectedTokenIds)
          ..remove(tokenId);
        state = state.copyWith(selectedTokenIds: updated);
        return;
      }

      // ── TOQUE INCORRECTO ─────────────────────────────────────────────────
      if (!correctIds.contains(tokenId)) {
        final newLives = state.lives - 1;
        FeedbackService.instance.playError();

        if (newLives <= 0) {
          // ── Vida 0 → mostrar diálogo de solución (sin SnackBar) ──────────
          state = state.copyWith(
            llamaMood: LlamaMood.error,
            comboCount: 0,
            comboActive: false,
            lives: 0,
            showSolutionDialog: true,
            lastErrorTokenId: tokenId,
          );
        } else {
          // ── Vidas > 0 → SnackBar GENÉRICO + flash en token (TAREA 1) ─────
          // Mensaje genérico, sin pistas específicas sobre la respuesta.
          state = state.copyWith(
            llamaMood: LlamaMood.error,
            comboCount: 0,
            comboActive: false,
            lives: newLives,
            lastErrorTokenId: tokenId,
            errorSnackVersion: state.errorSnackVersion + 1,
            errorSnackMessage: '¡Ups! Revisa la jerarquía de operaciones. '
                'Te quedan $newLives corazón(es). ❤️',
          );
          // Cooldown reducido: solo el tiempo del flash del token (180ms)
          await Future.delayed(const Duration(milliseconds: 180));
          state = state.copyWith(
              clearErrorToken: true, llamaMood: LlamaMood.idle);
        }
        return;
      }

      // ── TOQUE CORRECTO ────────────────────────────────────────────────────
      final newCombo = state.comboCount + 1;
      final isCombo = newCombo >= 3;
      final updated = Set<String>.from(state.selectedTokenIds)..add(tokenId);

      if (updated.containsAll(correctIds)) {
        // Paso completado
        state = state.copyWith(
          selectedTokenIds: updated,
          stepCompleted: true,
          llamaMood: LlamaMood.happy,
          comboCount: newCombo,
          comboActive: isCombo,
          clearErrorToken: true,
        );
        FeedbackService.instance.playCorrect();
      } else {
        FeedbackService.instance.playSelection();
        state = state.copyWith(
          selectedTokenIds: updated,
          llamaMood: LlamaMood.thinking,
          comboCount: newCombo,
          comboActive: isCombo,
          clearErrorToken: true,
        );
      }
    } finally {
      // Cooldown mínimo anti doble-tap (100ms)
      await Future.delayed(const Duration(milliseconds: 100));
      _isProcessing = false;
    }
  }

  // ── 1.2 Validación de Opción Múltiple ────────────────────────────────────

  Future<void> checkMultipleChoiceAnswer(String answer) async {
    if (_isProcessing || state.stepCompleted || state.exerciseFinished) return;

    _isProcessing = true;
    try {
      final isCorrect = state.currentStep.correctAnswer == answer;

      if (isCorrect) {
        final newCombo = state.comboCount + 1;
        state = state.copyWith(
          stepCompleted: true,
          llamaMood: LlamaMood.happy,
          comboCount: newCombo,
          comboActive: newCombo >= 3,
        );
        FeedbackService.instance.playCorrect();
      } else {
        final newLives = state.lives - 1;
        FeedbackService.instance.playError();

        if (newLives <= 0) {
          state = state.copyWith(
            llamaMood: LlamaMood.error,
            comboCount: 0,
            comboActive: false,
            lives: 0,
            showSolutionDialog: true,
          );
        } else {
          state = state.copyWith(
            llamaMood: LlamaMood.error,
            comboCount: 0,
            comboActive: false,
            lives: newLives,
            errorSnackVersion: state.errorSnackVersion + 1,
            errorSnackMessage: state.currentStep.feedbackError,
          );
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  // ── 1.5 SISTEMA DE PISTAS (TAREA 1) ──────────────────────────────────────
  
  Future<void> buyHint() async {
    if (_isProcessing || state.stepCompleted || state.exerciseFinished || state.hintActive) return;
    
    _isProcessing = true;
    state = state.copyWith(isProcessing: true);
    
    try {
      final profileNotifier = _ref.read(playerProfileProvider.notifier);
    
      // Intentar descontar 20 monedas
      final success = await profileNotifier.spendCoins(20);
      
      if (!success) {
        state = state.copyWith(
          errorSnackVersion: state.errorSnackVersion + 1,
          errorSnackMessage: '¡Necesitas 20 monedas para una pista! Sigue intentando.',
        );
        return;
      }

      // Activar la pista dependiendo del tipo de paso
      if (state.currentStep.isMultipleChoice) {
        state = state.copyWith(
          errorSnackVersion: state.errorSnackVersion + 1,
          errorSnackMessage: '💡 PISTA: ${state.currentStep.algorithmHint}',
          hintActive: true,
          llamaMood: LlamaMood.thinking,
        );
      } else {
        // Activar brillo en los correctos para pasos interactivos
        state = state.copyWith(
          hintTokenIds: state.correctIds,
          hintActive: true,
          llamaMood: LlamaMood.thinking,
        );
      }

      // Desactivar después de 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        state = state.copyWith(
          hintActive: false,
          hintTokenIds: const {},
          llamaMood: LlamaMood.idle,
        );
      }
    } finally {
      if (mounted) {
        _isProcessing = false;
        state = state.copyWith(isProcessing: false);
      }
    }
  }

  // ── 2. Avanzar al siguiente paso (con recompensa) ─────────────────────────

  Future<void> advanceStep() async {
    // CONDICIÓN DE SEGURIDAD CRÍTICA (TAREA 2)
    if (state.isLastStep) {
      await _finishExercise();
    } else {
      _goToNextStep();
    }
  }

  // ── 3. Autocomplete (vida 0): cerrar diálogo + avanzar sin puntos ─────────
  //
  // TAREA 2: el Navigator.pop() lo hace la UI antes de llamar este método.
  // Aquí solo avanzamos o terminamos con la validación de seguridad.

  /// TAREA 1: Avance forzado (blindado) tras perder las vidas.
  Future<void> forceNextStep() async {
    final isLastStep = state.currentStepIndex >= state.exercise.steps.length - 1;

    if (isLastStep) {
      // Si es el último, finalizamos el ejercicio (lanza el diálogo de victoria)
      await _finishExercise(withComboBonus: false);
    } else {
      // Si hay más, avanzamos al siguiente snapshot
      state = state.copyWith(
        showSolutionDialog: false,
        clearErrorToken: true,
      );
      _goToNextStep();
    }
  }

  // ── 4. Terminar ejercicio ─────────────────────────────────────────────────

  Future<void> _finishExercise({bool withComboBonus = true}) async {
    final profileNotifier = _ref.read(playerProfileProvider.notifier);
    final repo = _ref.read(exerciseRepositoryProvider);

    final base = state.exercise.rewardCoins;
    final earned = (withComboBonus && state.comboActive) ? base * 2 : base;

    await profileNotifier.addCoins(earned);
    
    // Obtener todos los IDs del nivel actual para la progresión estricta
    final currentDifficulty = state.exercise.difficulty;
    final allInLevel = currentDifficulty == 1 
        ? repo.easyExercises 
        : (currentDifficulty == 2 ? repo.mediumExercises : repo.hardExercises);
    final allIdsInLevel = allInLevel.map((e) => e.id).toList();

    final accessory = await profileNotifier.completeExercise(
      exerciseId: state.exercise.id,
      levelOfExercise: currentDifficulty,
      allExerciseIdsInThisLevel: allIdsInLevel,
    );

    state = state.copyWith(
      exerciseFinished: true,
      llamaMood: LlamaMood.victory,
      newlyUnlockedAccessory: accessory,
      comboActive: false,
      showSolutionDialog: false,
    );
    FeedbackService.instance.playVictory();
  }

  // ── Helper: ir al siguiente paso ─────────────────────────────────────────

  void _goToNextStep() {
    final nextIndex = state.currentStepIndex + 1;
    // Doble seguridad
    if (nextIndex >= state.exercise.steps.length) {
      _finishExercise(withComboBonus: false);
      return;
    }
    final nextStep = state.exercise.steps[nextIndex];
    final nextTokens = nextStep.expressionOverride != null
        ? EquationToken.fromExpression(nextStep.expressionOverride!)
        : state.tokens;

    final newExpression = nextStep.expressionOverride ?? nextTokens.map((t) => t.value).join(' ');

    state = state.copyWith(
      currentStepIndex: nextIndex,
      tokens: nextTokens,
      selectedTokenIds: {},
      stepCompleted: false,
      llamaMood: LlamaMood.idle,
      clearAccessory: true,
      lives: 3,
      showSolutionDialog: false,
      clearErrorToken: true,
      comboActive: false,
      equationHistory: List.from(state.equationHistory)..add(newExpression),
    );

    // Guardar progreso en el perfil (Tarea 2)
    _saveProgress();
  }

  /// Guarda el progreso actual en Hive.
  void _saveProgress() {
    _ref.read(playerProfileProvider.notifier).updateLastPlayedProgress(
      level: state.exercise.difficulty,
      exerciseId: state.exercise.id,
      stepIndex: state.currentStepIndex,
    );
  }

  // ── 5. Reiniciar ejercicio ────────────────────────────────────────────────

  void restart() {
    _isProcessing = false;
    state = PracticeState.fromExercise(state.exercise);
  }

  /// Carga un nuevo ejercicio aleatorio del pool de dificultad (PULIDO FINAL).
  Future<void> loadLevel(int difficulty) async {
    if (_isProcessing) return;
    _isProcessing = true;
    state = state.copyWith(isProcessing: true);

    try {
      final repo = _ref.read(exerciseRepositoryProvider);
      
      // Obtener pool
      List<ExerciseEntity> pool = difficulty == 1 
          ? repo.easyExercises 
          : (difficulty == 2 ? repo.mediumExercises : repo.hardExercises);
      
      if (pool.isEmpty) return;

      // Nueva lógica: Elegir el siguiente ejercicio en orden secuencial
      final profile = _ref.read(playerProfileProvider);
      final uncompleted = pool.where((e) => !profile.completedExerciseIds.contains(e.id)).toList();
      
      ExerciseEntity newEx;
      if (uncompleted.isNotEmpty) {
        newEx = uncompleted.first; // Toma el primero disponible (en orden)
      } else {
        // Si ya completó todos, elige uno al azar para repasar (que no sea el mismo que acaba de hacer)
        var available = pool.where((e) => e.id != state.exercise.id).toList();
        if (available.isEmpty) available = pool;
        newEx = available[DateTime.now().millisecond % available.length];
      }

      // Reiniciar estado
      state = PracticeState.fromExercise(newEx);
      
      // Limpiar progreso de Hive para el nuevo ejercicio
      _saveProgress();
      
    } finally {
      _isProcessing = false;
      state = state.copyWith(isProcessing: false);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER family
// ─────────────────────────────────────────────────────────────────────────────

final practiceProvider = StateNotifierProvider.autoDispose
    .family<PracticeNotifier, PracticeState, int>((ref, exerciseIndex) {
  final repo = ref.read(exerciseRepositoryProvider);
  final profile = ref.read(playerProfileProvider);
  final allExercises = repo.getAll();
  
  // Si es -1, cargamos el tutorial
  if (exerciseIndex == -1) {
    return PracticeNotifier(ref, repo.tutorialExercise);
  }

  // Seguridad ante índice fuera de rango (causante del crash reportado)
  if (exerciseIndex < 0 || exerciseIndex >= allExercises.length) {
    return PracticeNotifier(ref, allExercises.first);
  }

  final exercise = allExercises[exerciseIndex];
  
  // Recuperar progreso si coincide el ejercicio practicado
  int initialStep = 0;
  if (profile.lastPlayedExerciseId == exercise.id) {
    initialStep = profile.lastPlayedStepIndex;
  }

  return PracticeNotifier(ref, exercise, initialStepIndex: initialStep);
});
