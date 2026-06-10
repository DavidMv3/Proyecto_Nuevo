import 'package:flutter_test/flutter_test.dart';
import 'package:mateandina/data/repositories/exercise_repository.dart';
import 'package:mateandina/domain/entities/exercise_entity.dart';

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
  test('Find dropped blocks in all exercises', () {
    final repo = ExerciseRepository();
    final allEx = repo.getAll();
    
    print('Total exercises: ${allEx.length}');
    
    for (final ex in allEx) {
      int baseBlocks = countBlocks(ex.baseExpression);
      
      for (int i = 0; i < ex.steps.length; i++) {
        final step = ex.steps[i];
        final override = step.expressionOverride;
        if (override != null) {
          int overBlocks = countBlocks(override);
          
          final isLastStep = (i == ex.steps.length - 1);
          if (!isLastStep && overBlocks < baseBlocks) {
            // Let's see if a future step override has MORE blocks.
            // If it does, that means this step dropped it, and a future step brings it back.
            bool bringsItBack = false;
            String? nextOverride;
            for (int j = i + 1; j < ex.steps.length; j++) {
              final nextOver = ex.steps[j].expressionOverride;
              if (nextOver != null) {
                if (countBlocks(nextOver) > overBlocks) {
                  bringsItBack = true;
                  nextOverride = nextOver;
                  break;
                }
              }
            }
            
            if (bringsItBack) {
              print('Exercise: ${ex.id} (${ex.title})');
              print('  Step ${i + 1} (${step.id}) has override "$override" ($overBlocks blocks)');
              print('    Next override brings it back: "$nextOverride"');
              print('    Base expression had $baseBlocks blocks: "${ex.baseExpression}"');
            }
          }
        }
      }
    }
  });
}
