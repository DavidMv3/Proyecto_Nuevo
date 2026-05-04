import 'package:equatable/equatable.dart';

/// Tipo de accesorio cosmético del robot.
enum AccessoryType { hat, glasses, cape, badge }

/// Accesorio visual desbloqueado automáticamente al completar ejercicios.
/// NO cuesta piezas — es una recompensa por mérito académico.
class RobotAccessoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final AccessoryType type;
  final String emoji;

  /// ID del ejercicio que desbloquea este accesorio (null = desbloqueado desde inicio).
  final String? unlockedByExerciseId;

  const RobotAccessoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.emoji,
    this.unlockedByExerciseId,
  });

  @override
  List<Object?> get props => [id];
}

/// Catálogo estático de accesorios cosméticos del robot.
class RobotAccessoryCatalog {
  static const List<RobotAccessoryEntity> all = [
    RobotAccessoryEntity(
      id: 'acc_cap_green',
      name: 'Gorra Exploradora',
      description: 'Para el aventurero de las matemáticas.',
      type: AccessoryType.hat,
      emoji: '🎩',
      unlockedByExerciseId: 'ex_001',
    ),
    RobotAccessoryEntity(
      id: 'acc_glasses_round',
      name: 'Gafas del Sabio',
      description: 'Ahora ves los números con más claridad.',
      type: AccessoryType.glasses,
      emoji: '🕶️',
      unlockedByExerciseId: 'ex_002',
    ),
    RobotAccessoryEntity(
      id: 'acc_cape_blue',
      name: 'Capa Matemática',
      description: 'El héroe de las operaciones combinadas.',
      type: AccessoryType.cape,
      emoji: '🦸',
      unlockedByExerciseId: 'ex_003',
    ),
    RobotAccessoryEntity(
      id: 'acc_badge_star',
      name: 'Insignia Estrella',
      description: 'Completaste la mitad del currículo.',
      type: AccessoryType.badge,
      emoji: '⭐',
      unlockedByExerciseId: 'ex_005',
    ),
    RobotAccessoryEntity(
      id: 'acc_crown_gold',
      name: 'Corona de Maestro',
      description: '¡Completaste todos los ejercicios!',
      type: AccessoryType.hat,
      emoji: '👑',
      unlockedByExerciseId: 'ex_010',
    ),
  ];

  static RobotAccessoryEntity? findByExerciseId(String exerciseId) {
    try {
      return all.firstWhere((a) => a.unlockedByExerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }
}
