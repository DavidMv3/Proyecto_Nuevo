import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/player_profile_entity.dart';

const String _kProfileBox = 'player_profile';
const String _kPiecesKey = 'available_pieces';
const String _kOwnedPartsKey = 'owned_parts';
const String _kAccessoriesKey = 'unlocked_accessories';
const String _kCompletedExKey = 'completed_exercises';
const String _kHighestLevelKey = 'highest_unlocked_level';
const String _kLastPlayedKey = 'last_played_level';
const String _kLastExerciseKey = 'last_played_exercise_id';
const String _kLastStepKey = 'last_played_step_index';

/// Fuente de datos local usando Hive. Opera completamente OFFLINE.
class PlayerProfileLocalDatasource {
  late Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(_kProfileBox);
  }

  PlayerProfileEntity load() {
    final pieces = _box.get(_kPiecesKey, defaultValue: 0) as int;
    final ownedParts =
        List<String>.from(_box.get(_kOwnedPartsKey, defaultValue: <String>[]));
    final accessories =
        List<String>.from(_box.get(_kAccessoriesKey, defaultValue: <String>[]));
    final completedEx =
        List<String>.from(_box.get(_kCompletedExKey, defaultValue: <String>[]));

    final highestLevel = _box.get(_kHighestLevelKey, defaultValue: 1) as int;
    final lastPlayed = _box.get(_kLastPlayedKey, defaultValue: 1) as int;
    final lastEx = _box.get(_kLastExerciseKey) as String?;
    final lastStep = _box.get(_kLastStepKey, defaultValue: 0) as int;

    return PlayerProfileEntity(
      availableCoins: pieces,
      ownedPartIds: ownedParts,
      unlockedAccessoryIds: accessories,
      completedExerciseIds: completedEx,
      highestUnlockedLevel: highestLevel,
      lastPlayedLevel: lastPlayed,
      lastPlayedExerciseId: lastEx,
      lastPlayedStepIndex: lastStep,
    );
  }

  Future<void> save(PlayerProfileEntity profile) async {
    await _box.put(_kPiecesKey, profile.availableCoins);
    await _box.put(_kOwnedPartsKey, profile.ownedPartIds);
    await _box.put(_kAccessoriesKey, profile.unlockedAccessoryIds);
    await _box.put(_kCompletedExKey, profile.completedExerciseIds);
    await _box.put(_kHighestLevelKey, profile.highestUnlockedLevel);
    await _box.put(_kLastPlayedKey, profile.lastPlayedLevel);
    await _box.put(_kLastExerciseKey, profile.lastPlayedExerciseId);
    await _box.put(_kLastStepKey, profile.lastPlayedStepIndex);
  }
}
