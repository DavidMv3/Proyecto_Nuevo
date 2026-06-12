import 'package:equatable/equatable.dart';

/// Representa un paso individual en el "Interrogatorio Pedagógico Interactivo".
class StepEntity extends Equatable {
  /// Identificador único del paso
  final String id;

  /// La instrucción pedagógica (antes 'question').
  final String instruction;

  /// Lista de IDs de los tokens correctos (antes 'correctElementIds').
  final List<String> correctIds;

  /// Mensaje de error pedagógico (antes 'generalErrorMessage').
  final String feedbackError;

  /// Pista basada en el algoritmo de 6 pasos.
  final String algorithmHint;

  /// Opciones para pasos de selección múltiple.
  final List<String>? options;

  /// Respuesta correcta para selección múltiple.
  final String? correctAnswer;

  /// Mensajes de error por token incorrecto (opcional).
  final Map<String, String> specificErrorMessages;

  /// Expresión opcional para pasos de sustitución.
  final String? expressionOverride;

  /// Expresión progresiva del cuaderno: cómo se ve la línea de trabajo
  /// DESPUÉS de que el usuario responde este paso. Usa '____' para blancos.
  final String? workingExpression;

  /// Indica si este paso inicia una nueva línea de evaluación en el cuaderno.
  final bool startsNewLine;

  const StepEntity({
    required this.id,
    required this.instruction,
    required this.correctIds,
    required this.feedbackError,
    required this.algorithmHint,
    this.options,
    this.correctAnswer,
    this.specificErrorMessages = const {},
    this.expressionOverride,
    this.workingExpression,
    this.startsNewLine = false,
  });

  /// Determina si este paso es de opción múltiple.
  bool get isMultipleChoice => options != null && options!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    instruction,
    correctIds,
    feedbackError,
    algorithmHint,
    options,
    correctAnswer,
    specificErrorMessages,
    expressionOverride,
    workingExpression,
    startsNewLine,
  ];
}
