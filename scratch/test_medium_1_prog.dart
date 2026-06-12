import 'dart:io';
import '../lib/data/repositories/exercise_repository.dart';
import '../lib/domain/entities/exercise_entity.dart';
import '../lib/domain/entities/step_entity.dart';

bool _isPrefix(String a, String b) {
  final cleanA = a.replaceAll(' ', '').replaceAll('____', '').replaceAll('?', '');
  final cleanB = b.replaceAll(' ', '').replaceAll('____', '').replaceAll('?', '');
  if (cleanA.isEmpty) return false;
  return cleanB.startsWith(cleanA);
}

String getExpressionForStep(ExerciseEntity exercise, int stepIndex) {
  for (int i = stepIndex - 1; i >= 0; i--) {
    final override = exercise.steps[i].expressionOverride;
    if (override != null) return override;
  }
  return exercise.baseExpression;
}

void main() {
  final repo = ExerciseRepository();
  final exercise = repo.getAll().firstWhere((e) => e.id == 'medium_1');

  print('Simulating medium_1 progression:');
  
  List<String> equationHistory = [];
  
  for (int stepIdx = 0; stepIdx < exercise.steps.length; stepIdx++) {
    final step = exercise.steps[stepIdx];
    final stepNum = stepIdx + 1;
    print('\n=======================================');
    print('STEP $stepNum: ${step.instruction}');
    
    // Simulate before solving
    _printState(exercise, stepIdx, step, false, equationHistory);
    
    // Simulate after solving
    _printState(exercise, stepIdx, step, true, equationHistory);
    
    // Update history for the next step as done in _goToNextStep
    final workingLine = getExpressionForStep(exercise, stepIdx);
    final isSameAsLast = equationHistory.isNotEmpty && 
        equationHistory.last.replaceAll(' ', '') == workingLine.replaceAll(' ', '');
    if (!isSameAsLast) {
      equationHistory.add(workingLine);
    }
  }
}

void _printState(ExerciseEntity exercise, int stepIdx, StepEntity step, bool stepCompleted, List<String> history) {
  final isInteractive = !step.isMultipleChoice;
  final workingLine = getExpressionForStep(exercise, stepIdx);
  
  final List<String> rawExpressions = [];
  for (final h in history) {
    if (h.trim().isNotEmpty) {
      rawExpressions.add(h);
    }
  }

  final currentOverride = step.expressionOverride;
  String? activeLine;
  if (workingLine.trim().isNotEmpty) {
    activeLine = workingLine;
  } else if (currentOverride != null && stepCompleted && currentOverride.trim().isNotEmpty) {
    activeLine = currentOverride;
  }

  if (activeLine != null) {
    final cleanActive = activeLine.replaceAll(' ', '').replaceAll('____', '').replaceAll('\$', '');
    final lastClean = rawExpressions.isEmpty ? '' : rawExpressions.last.replaceAll(' ', '').replaceAll('\$', '');
    if (rawExpressions.isEmpty || lastClean != cleanActive) {
      rawExpressions.add(activeLine);
    }
  }

  // Filter out prefixes
  final List<String> filteredExpressions = [];
  if (rawExpressions.isNotEmpty) {
    final firstExpr = rawExpressions.first;
    // For simplicity of simulation we assume currentTokensStr corresponds to the current workingLine / override
    final filteredFirst = firstExpr; 
    filteredExpressions.add(filteredFirst);

    for (int i = 1; i < rawExpressions.length; i++) {
      final current = rawExpressions[i];
      bool isPrefixOfLater = false;
      for (int j = i + 1; j < rawExpressions.length; j++) {
        if (_isPrefix(current, rawExpressions[j])) {
          isPrefixOfLater = true;
          break;
        }
      }
      if (!isPrefixOfLater) {
        filteredExpressions.add(current);
      }
    }
  }

  final stateName = stepCompleted ? 'AFTER SOLVING (Completed)' : 'BEFORE SOLVING (Active)';
  print('  --- $stateName ---');
  for (int i = 0; i < filteredExpressions.length; i++) {
    final eq = filteredExpressions[i];
    final isBase = eq.replaceAll(' ', '') == exercise.baseExpression.replaceAll(' ', '');
    final prefix = isBase ? '' : '= ';
    final suffix = isBase ? ' =' : '';
    print('    $prefix$eq$suffix');
  }
}
