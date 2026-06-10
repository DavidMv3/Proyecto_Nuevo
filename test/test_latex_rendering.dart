import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mateandina/data/repositories/exercise_repository.dart';
import 'package:mateandina/presentation/widgets/latex_rich_text.dart';

void main() {
  testWidgets('Verify that all LaTeX strings in all exercises render without errors', (WidgetTester tester) async {
    final repo = ExerciseRepository();
    final exercises = repo.getAll();

    print('Starting LaTeX rendering audit for ${exercises.length} exercises...');

    int totalStringsTested = 0;
    int errorsFound = 0;

    Future<void> testString(String text, String contextInfo) async {
      if (text.isEmpty) return;
      totalStringsTested++;

      // Check unbalanced dollar signs
      final dollarCount = RegExp(r'\$').allMatches(text).length;
      if (dollarCount % 2 != 0) {
        print('ERROR: Unbalanced dollar signs in $contextInfo: "$text" (found $dollarCount dollars)');
        errorsFound++;
      }

      // Check double or triple dollar signs
      if (text.contains('\$\$')) {
        print('ERROR: Contains double/triple dollar signs in $contextInfo: "$text"');
        errorsFound++;
      }

      // Check for raw math errors like "es÷" or "8$1" or "potencias/raíces"
      if (text.contains('8\$1') || text.contains('8\\\$1')) {
        print('ERROR: Typos "8\$1" in $contextInfo: "$text"');
        errorsFound++;
      }
      if (text.contains('es÷') || text.contains('es/')) {
        if (text.contains('es/ ') || text.contains('es / ') || text.contains('es÷')) {
          print('ERROR: Trailing operator typo "es/" or "es÷" in $contextInfo: "$text"');
          errorsFound++;
        }
      }

      // Try rendering the LatexRichText widget to ensure no LaTeX syntax errors occur
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LatexRichText(
                text: text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        );

        if (tester.takeException() != null) {
          final err = tester.takeException();
          print('ERROR: LaTeX parsing exception in $contextInfo: "$text". Exception: $err');
          errorsFound++;
        }
      } catch (e) {
        print('ERROR: Exception caught while testing $contextInfo: "$text". Exception: $e');
        errorsFound++;
      }
    }

    for (final exercise in exercises) {
      await testString(exercise.title, '${exercise.id} (title)');

      for (final step in exercise.steps) {
        final stepCtx = '${exercise.id} -> ${step.id}';
        
        await testString(step.instruction, '$stepCtx (instruction)');
        
        if (step.options != null) {
          for (int i = 0; i < step.options!.length; i++) {
            await testString(step.options![i], '$stepCtx (options[$i])');
          }
        }
        
        if (step.correctAnswer != null) {
          await testString(step.correctAnswer!, '$stepCtx (correctAnswer)');
        }
        
        await testString(step.algorithmHint, '$stepCtx (algorithmHint)');
        await testString(step.feedbackError, '$stepCtx (feedbackError)');
        
        if (step.specificErrorMessages != null) {
          // We can't await inside forEach easily, so use map loop or for-in
          for (final entry in step.specificErrorMessages!.entries) {
            await testString(entry.key, '$stepCtx (specificErrorMessages key: "${entry.key}")');
            await testString(entry.value, '$stepCtx (specificErrorMessages value: "${entry.value}")');
          }
        }
      }
    }

    print('Completed LaTeX rendering audit. Tested $totalStringsTested strings. Errors found: $errorsFound');
    expect(errorsFound, 0, reason: 'All LaTeX strings must render successfully without formatting or syntax errors.');
  });
}
