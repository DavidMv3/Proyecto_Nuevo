import 'dart:io';
import 'package:mateandina/data/repositories/exercise_repository.dart';

void main() {
  final repo = ExerciseRepository();
  final easy = repo.easyExercises;
  
  for (final ex in easy) {
    print('=== ${ex.id} (${ex.title}): "${ex.baseExpression}" ===');
    for (int i = 0; i < ex.steps.length; i++) {
      final step = ex.steps[i];
      print('  Step ${i + 1} (${step.id}): "${step.instruction}" -> Answer: "${step.correctAnswer}"');
      if (step.expressionOverride != null) {
        print('    Override: "${step.expressionOverride}"');
      }
    }
  }
}
