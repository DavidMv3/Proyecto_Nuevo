import 'package:equatable/equatable.dart';

/// Estado del perfil del jugador. Inmutable — los cambios producen nuevas instancias.
class PlayerProfileEntity extends Equatable {
  /// Monedas de oro disponibles para gastar en la granja.
  final int availableCoins;

  /// IDs de las partes estructurales del robot compradas con piezas.
  final List<String> ownedPartIds;

  /// IDs de los accesorios cosméticos desbloqueados por completar ejercicios.
  final List<String> unlockedAccessoryIds;

  /// IDs de los ejercicios que el jugador ha completado al menos una vez.
  final List<String> completedExerciseIds;

  /// IDs de las piezas que el jugador tiene EQUIPADAS en su robot.
  final List<String> equippedPartIds;

  /// Máximo nivel desbloqueado (1: Fácil, 2: Medio, 3: Difícil).
  final int highestUnlockedLevel;

  /// Último nivel (dificultad) que el niño estaba practicando.
  final int lastPlayedLevel;

  /// ID del último ejercicio específico practicado (para reanudar).
  final String? lastPlayedExerciseId;

  /// Índice del paso en el que se quedó.
  final int lastPlayedStepIndex;

  const PlayerProfileEntity({
    required this.availableCoins,
    required this.ownedPartIds,
    required this.unlockedAccessoryIds,
    required this.completedExerciseIds,
    this.equippedPartIds = const [],
    this.highestUnlockedLevel = 1,
    this.lastPlayedLevel = 1,
    this.lastPlayedExerciseId,
    this.lastPlayedStepIndex = 0,
  });

  const PlayerProfileEntity.initial()
      : availableCoins = 0,
        ownedPartIds = const [],
        unlockedAccessoryIds = const [],
        completedExerciseIds = const [],
        equippedPartIds = const [],
        highestUnlockedLevel = 1,
        lastPlayedLevel = 1,
        lastPlayedExerciseId = null,
        lastPlayedStepIndex = 0;

  PlayerProfileEntity copyWith({
    int? availableCoins,
    List<String>? ownedPartIds,
    List<String>? unlockedAccessoryIds,
    List<String>? completedExerciseIds,
    List<String>? equippedPartIds,
    int? highestUnlockedLevel,
    int? lastPlayedLevel,
    String? lastPlayedExerciseId,
    int? lastPlayedStepIndex,
  }) {
    return PlayerProfileEntity(
      availableCoins: availableCoins ?? this.availableCoins,
      ownedPartIds: ownedPartIds ?? this.ownedPartIds,
      unlockedAccessoryIds: unlockedAccessoryIds ?? this.unlockedAccessoryIds,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      equippedPartIds: equippedPartIds ?? this.equippedPartIds,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      lastPlayedLevel: lastPlayedLevel ?? this.lastPlayedLevel,
      lastPlayedExerciseId: lastPlayedExerciseId ?? this.lastPlayedExerciseId,
      lastPlayedStepIndex: lastPlayedStepIndex ?? this.lastPlayedStepIndex,
    );
  }

  bool ownsPart(String partId) => ownedPartIds.contains(partId);
  bool canAfford(int cost) => availableCoins >= cost;
  bool hasAccessory(String accessoryId) => unlockedAccessoryIds.contains(accessoryId);
  bool hasCompletedExercise(String exerciseId) => completedExerciseIds.contains(exerciseId);
  bool isEquipped(String partId) => equippedPartIds.contains(partId);

  @override
  List<Object?> get props => [
        availableCoins,
        ownedPartIds,
        unlockedAccessoryIds,
        completedExerciseIds,
        equippedPartIds,
        highestUnlockedLevel,
        lastPlayedLevel,
        lastPlayedExerciseId,
        lastPlayedStepIndex,
      ];
}
