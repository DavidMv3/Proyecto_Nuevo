import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/player_profile_local_datasource.dart';
import '../../domain/entities/player_profile_entity.dart';
import '../../domain/entities/robot_accessory_entity.dart';
import '../../domain/entities/robot_part_entity.dart';

// ---------------------------------------------------------------------------
// Datasource Provider
// ---------------------------------------------------------------------------

final playerProfileDatasourceProvider =
    Provider<PlayerProfileLocalDatasource>((ref) {
  return PlayerProfileLocalDatasource();
});

// ---------------------------------------------------------------------------
// StateNotifier
// ---------------------------------------------------------------------------

class PlayerProfileNotifier extends StateNotifier<PlayerProfileEntity> {
  final PlayerProfileLocalDatasource _datasource;

  PlayerProfileNotifier(this._datasource) : super(_datasource.load());

  /// Añade monedas de oro al perfil (al completar un ejercicio).
  Future<void> addCoins(int amount) async {
    state = state.copyWith(availableCoins: state.availableCoins + amount);
    await _datasource.save(state);
  }

  /// Descuenta monedas (para el sistema de pistas).
  Future<bool> spendCoins(int amount) async {
    if (state.availableCoins < amount) return false;
    state = state.copyWith(availableCoins: state.availableCoins - amount);
    await _datasource.save(state);
    return true;
  }

  /// Guarda el último nivel en el que estuvo el niño.
  Future<void> setLastPlayedLevel(int level) async {
    state = state.copyWith(lastPlayedLevel: level);
    await _datasource.save(state);
  }

  /// Guarda el progreso exacto de un ejercicio.
  Future<void> updateLastPlayedProgress({
    required int level,
    required String exerciseId,
    required int stepIndex,
  }) async {
    state = state.copyWith(
      lastPlayedLevel: level,
      lastPlayedExerciseId: exerciseId,
      lastPlayedStepIndex: stepIndex,
    );
    await _datasource.save(state);
  }

  /// Intenta comprar una pieza estructural con piezas. Retorna [true] si tuvo éxito.
  Future<bool> buyPart(LlamaObjectEntity part) async {
    if (state.ownsPart(part.id) || !state.canAfford(part.coinCost)) {
      return false;
    }
    final updatedParts = List<String>.from(state.ownedPartIds)..add(part.id);
    state = state.copyWith(
      availableCoins: state.availableCoins - part.coinCost,
      ownedPartIds: updatedParts,
    );
    await _datasource.save(state);
    return true;
  }

  /// Registra un ejercicio como completado y verifica si se desbloquea el siguiente nivel.
  /// Retorna el [RobotAccessoryEntity] desbloqueado, o null si no hay ninguno.
  Future<RobotAccessoryEntity?> completeExercise({
    required String exerciseId,
    required int levelOfExercise,
    required List<String> allExerciseIdsInThisLevel,
  }) async {
    // 1. Marcar ejercicio como completado (si no estaba ya)
    if (!state.hasCompletedExercise(exerciseId)) {
      final updatedEx = List<String>.from(state.completedExerciseIds)
        ..add(exerciseId);
      state = state.copyWith(completedExerciseIds: updatedEx);
    }
    
    // Si es el tutorial (Nivel 0), solo guardamos que se completó (para el registro) y terminamos
    if (levelOfExercise == 0) {
      await _datasource.save(state);
      return null;
    }

    // 2. Verificar si se desbloquea un accesorio nuevo (Gamificación)
    final accessory = RobotAccessoryCatalog.findByExerciseId(exerciseId);
    if (accessory != null && !state.hasAccessory(accessory.id)) {
      final updatedAcc = List<String>.from(state.unlockedAccessoryIds)
        ..add(accessory.id);
      state = state.copyWith(unlockedAccessoryIds: updatedAcc);
    }

    // 3. Progresión de niveles estrictos (Tarea 2)
    // El nivel Medio (2) solo se desbloquea si TODOS los Fácil (1) están completados.
    // El nivel Difícil (3) solo se desbloquea si TODOS los Medio (2) están completados.
    
    int newHighestLevel = state.highestUnlockedLevel;
    
    // Si terminamos un ejercicio del nivel que estamos intentando superar
    if (levelOfExercise == state.highestUnlockedLevel && state.highestUnlockedLevel < 3) {
      final completedInThisLevel = allExerciseIdsInThisLevel.where((id) => 
        state.completedExerciseIds.contains(id)).length;
      
      // Si ya completamos TODOS los de este nivel, desbloqueamos el siguiente
      if (completedInThisLevel >= allExerciseIdsInThisLevel.length) {
        newHighestLevel = state.highestUnlockedLevel + 1;
      }
    }

    state = state.copyWith(highestUnlockedLevel: newHighestLevel);
    await _datasource.save(state);
    
    return accessory;
  }

  /// Equipa o desequipa una pieza de la llama.
  /// Solo funciona si el jugador posee la pieza ([ownedPartIds]).
  /// Garantiza que solo haya un ítem activo por [LlamaObjectType].
  Future<void> toggleEquip(String partId) async {
    if (!state.ownsPart(partId)) return;
    
    final partToEquip = LlamaObjectCatalog.all.firstWhere((p) => p.id == partId);
    final currently = List<String>.from(state.equippedPartIds);
    
    if (currently.contains(partId)) {
      // Si ya está equipada, la desequipamos
      currently.remove(partId);
    } else {
      // Si la vamos a equipar, primero removemos CUALQUIER otra pieza del mismo TIPO
      currently.removeWhere((id) {
        try {
          final existingPart = LlamaObjectCatalog.all.firstWhere((p) => p.id == id);
          return existingPart.partType == partToEquip.partType;
        } catch (_) {
          return false;
        }
      });
      // Luego añadimos la nueva
      currently.add(partId);
    }
    
    state = state.copyWith(equippedPartIds: currently);
    await _datasource.save(state);
  }

  /// Desbloquear accesorio manualmente (para pruebas o cheats de admin).
  Future<void> unlockAccessory(String accessoryId) async {
    if (state.hasAccessory(accessoryId)) return;
    final updated = List<String>.from(state.unlockedAccessoryIds)
      ..add(accessoryId);
    state = state.copyWith(unlockedAccessoryIds: updated);
    await _datasource.save(state);
  }
}

// ---------------------------------------------------------------------------
// Provider Global
// ---------------------------------------------------------------------------

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfileEntity>((ref) {
  final datasource = ref.watch(playerProfileDatasourceProvider);
  return PlayerProfileNotifier(datasource);
});
