import 'package:equatable/equatable.dart';
import 'step_entity.dart';

/// Representa un ejercicio completo en la aplicación RoboMate.
class ExerciseEntity extends Equatable {
  /// Identificador único del ejercicio
  final String id;
  
  /// Título o temática del ejercicio
  final String title;
  
  /// La expresión matemática inicial (antes 'initialExpression').
  final String baseExpression;
  
  /// Lista ordenada de los pasos interactivos.
  final List<StepEntity> steps;
  
  /// Recompensa (monedas) obtenida.
  final int rewardCoins;

  /// Nivel de dificultad (antes 'difficultyLevel').
  final int difficulty;

  const ExerciseEntity({
    required this.id,
    required this.title,
    required this.baseExpression,
    required this.steps,
    required this.rewardCoins,
    required this.difficulty,
  });

  @override
  List<Object?> get props => [id, title, baseExpression, steps, rewardCoins, difficulty];
}
