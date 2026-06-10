import 'package:flutter/material.dart';
import 'package:mateandina/presentation/screens/practice_screen.dart';
import 'package:mateandina/data/repositories/exercise_repository.dart';
import 'package:mateandina/domain/entities/exercise_entity.dart';

void main() {
  final repo = ExerciseRepository();
  final easy7 = repo.easyExercises.firstWhere((e) => e.id == 'easy_7');

  print("Exercise: ${easy7.baseExpression}");

  String getExpressionAfterStep(ExerciseEntity exercise, int stepIndex) {
    for (int i = stepIndex; i >= 0; i--) {
      final override = exercise.steps[i].expressionOverride;
      if (override != null) return override;
    }
    return exercise.baseExpression;
  }

  // Simulate stepIndex = 4 (Step 5, 'Se pueden resolver...')
  final currentStepIndex = 4;
  final stepCompleted = false;

  final List<dynamic> candidateExprs = [];
  for (int i = 0; i <= currentStepIndex; i++) {
    final step = easy7.steps[i];
    final isCurrent = (i == currentStepIndex);
    if (isCurrent && !stepCompleted) {
      continue;
    }

    final override = step.expressionOverride;
    final isConserve = '${step.instruction} ${step.correctAnswer ?? ''}'.toLowerCase().contains('conser');

    if (override != null || isConserve) {
      final expr = getExpressionAfterStep(easy7, i);
      candidateExprs.add({'expr': expr, 'stepIndex': i});
    }
  }

  for (int i = 0; i < candidateExprs.length; i++) {
    final candidate = candidateExprs[i];
    final prevExpr = (i == 0) ? easy7.baseExpression : candidateExprs[i - 1]['expr'] as String;
    
    final prog = getProgressiveExpression(
      prevExpr, 
      candidate['expr'] as String, 
      isCompleted: true,
      stepIndex: candidate['stepIndex'] as int,
      exercise: easy7,
      activeStepIndex: currentStepIndex,
      activeStepCompleted: stepCompleted,
    );
    print("  Candidate $i: prevExpr='$prevExpr', candidateExpr='${candidate['expr']}', stepIndex=${candidate['stepIndex']} -> progressive='$prog'");
  }
}
