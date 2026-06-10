import 'dart:io';
import 'package:mateandina/data/repositories/exercise_repository.dart';

void main() {
  final repo = ExerciseRepository();
  final exercises = repo.getAll();
  
  for (final ex in exercises) {
    for (int i = 0; i < ex.steps.length; i++) {
      final step = ex.steps[i];
      final text = '${step.instruction} ${step.correctAnswer ?? ''}'.toLowerCase();
      if (text.contains('conser')) {
        print('Exercise: ${ex.id} (${ex.baseExpression})');
        print('  Step ${i + 1} (${step.id}): "${step.instruction}"');
        print('    This step override: "${step.expressionOverride}"');
        
        // Print previous step and override
        if (i > 0) {
          final prevStep = ex.steps[i - 1];
          print('    Prev step (${prevStep.id}) override: "${prevStep.expressionOverride}"');
        }
        
        // Print next step and override
        if (i < ex.steps.length - 1) {
          final nextStep = ex.steps[i + 1];
          print('    Next step (${nextStep.id}) override: "${nextStep.expressionOverride}"');
        }
        print('');
      }
    }
  }
}
