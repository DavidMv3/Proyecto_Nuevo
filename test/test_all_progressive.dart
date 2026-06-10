import 'package:flutter_test/flutter_test.dart';
import 'package:mateandina/data/repositories/exercise_repository.dart';
import 'package:mateandina/domain/entities/exercise_entity.dart';
import 'package:mateandina/presentation/screens/practice_screen.dart';

class _CandidateExpression {
  final String expression;
  final bool isCompleted;
  final int? stepIndex;
  _CandidateExpression(this.expression, this.isCompleted, {this.stepIndex});
}

void main() {
  test('Verify progressive expressions for all exercises', () {
    final repo = ExerciseRepository();
    final exercises = repo.getAll();
    print('Found ${exercises.length} exercises to validate.');

    int totalViolations = 0;

    for (final exercise in exercises) {
      print('Validating ${exercise.id} (${exercise.title})...');

      // Simulate each step
      for (int stepIdx = 0; stepIdx < exercise.steps.length; stepIdx++) {
        for (final stepCompleted in [false, true]) {
          // Build candidate expressions for the current state
          final List<_CandidateExpression> candidateExprs = [];

          String getExpressionAfterStep(ExerciseEntity exercise, int stepIndex) {
            for (int i = stepIndex; i >= 0; i--) {
              final override = exercise.steps[i].expressionOverride;
              if (override != null) return override;
            }
            return exercise.baseExpression;
          }

          for (int i = 0; i <= stepIdx; i++) {
            final step = exercise.steps[i];
            final isCurrent = (i == stepIdx);
            if (isCurrent && !stepCompleted) {
              continue;
            }

            final override = step.expressionOverride;
            final isConserve = '${step.instruction} ${step.correctAnswer ?? ''}'.toLowerCase().contains('conser');

            if (override != null || isConserve) {
              final expr = getExpressionAfterStep(exercise, i);
              candidateExprs.add(_CandidateExpression(expr, true, stepIndex: i));
            }
          }

          final List<String> rawProgressiveLines = [];
          for (int i = 0; i < candidateExprs.length; i++) {
            final candidate = candidateExprs[i];
            final prevExpr = (i == 0) ? exercise.baseExpression : candidateExprs[i - 1].expression;
            
            final prog = getProgressiveExpression(
              prevExpr, 
              candidate.expression, 
              isCompleted: candidate.isCompleted,
              stepIndex: candidate.stepIndex,
              exercise: exercise,
              activeStepIndex: stepIdx,
              activeStepCompleted: stepCompleted,
            );
            rawProgressiveLines.add(prog);
          }

          List<String> getTopLevelOperators(String expr) {
            final tokens = expr.trim().split(RegExp(r'\s+'));
            final operators = <String>[];
            int depth = 0;
            for (final t in tokens) {
              if (t == '(' || t == '[' || t == '{' || t.contains('(') || t.contains('[') || t.contains('{')) {
                depth++;
              }
              if (depth == 0 && (t == '+' || t == '-')) {
                operators.add(t);
              }
              if (t == ')' || t == ']' || t == '}' || t.contains(')') || t.contains(']') || t.contains('}')) {
                depth--;
              }
            }
            return operators;
          }

          // Apply prefix filtering as done in practice_screen.dart
          final List<String> filteredLines = [];
          final cleanLines = rawProgressiveLines.map((s) => s.replaceAll(' ', '')).toList();

          for (int i = 0; i < rawProgressiveLines.length; i++) {
            final raw = rawProgressiveLines[i].trim();
            if (raw.isEmpty) continue;
            
            final clean = cleanLines[i];
            bool shouldFilter = false;
            final opsI = getTopLevelOperators(raw);

            for (int j = i + 1; j < rawProgressiveLines.length; j++) {
              final nextRaw = rawProgressiveLines[j].trim();
              final nextClean = cleanLines[j];
              
              // Rule 1: prefix matching
              if (nextClean.startsWith(clean)) {
                shouldFilter = true;
                break;
              }
              
              // Rule 2: same block structure (operators at depth 0)
              final opsJ = getTopLevelOperators(nextRaw);
              if (opsI.length == opsJ.length) {
                bool matches = true;
                for (int k = 0; k < opsI.length; k++) {
                  if (opsI[k] != opsJ[k]) {
                    matches = false;
                    break;
                  }
                }
                if (matches) {
                  shouldFilter = true;
                  break;
                }
              }
            }
            if (!shouldFilter) {
              filteredLines.add(raw);
            }
          }
        }
      }
    }
  });
}
