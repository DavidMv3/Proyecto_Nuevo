import 'package:flutter_test/flutter_test.dart';
import 'package:mateandina/data/repositories/exercise_repository.dart';
import 'package:mateandina/domain/entities/exercise_entity.dart';
import 'package:mateandina/domain/entities/step_entity.dart';

// Helper to count blocks in a tokenized expression
int countBlocks(String expr) {
  final tokens = expr.trim().split(RegExp(r'\s+'));
  int depths = 0;
  int blockCount = 1;
  for (final token in tokens) {
    if (token == '(' || token == '[' || token == '{' || token.contains('(') || token.contains('[') || token.contains('{')) {
      depths++;
    }
    if (token == ')' || token == ']' || token == '}' || token.contains(')') || token.contains(']') || token.contains('}')) {
      depths--;
    }
    if (depths == 0 && (token == '+' || token == '-')) {
      blockCount++;
    }
  }
  return blockCount;
}

void main() {
  test('Analyze dropped blocks', () {
    final repo = ExerciseRepository();
    final exercises = repo.getAll();
    
    for (final ex in exercises) {
      int baseBlocks = countBlocks(ex.baseExpression);
      
      // Check each step override
      for (int i = 0; i < ex.steps.length; i++) {
        final step = ex.steps[i];
        final override = step.expressionOverride;
        if (override != null) {
          int overBlocks = countBlocks(override);
          
          // If it's not the last step, but it has fewer blocks than the base expression,
          // it might be dropping blocks.
          final isLastStep = (i == ex.steps.length - 1);
          if (!isLastStep && overBlocks < baseBlocks) {
            bool bringsItBack = false;
            for (int j = i + 1; j < ex.steps.length; j++) {
              final nextOver = ex.steps[j].expressionOverride;
              if (nextOver != null && countBlocks(nextOver) > overBlocks) {
                bringsItBack = true;
                break;
              }
            }
            
            if (bringsItBack) {
              print('Exercise: ${ex.id} (${ex.title})');
              print('  Step ${i + 1} (${step.id}) has override "$override" ($overBlocks blocks)');
              print('    Instruction: ${step.instruction}');
              print('    Base expression had $baseBlocks blocks: "${ex.baseExpression}"');
            }
          }
        }
      }
    }
  });
}
