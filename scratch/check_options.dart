import 'package:mateandina/data/repositories/exercise_repository.dart';

void main() {
  final repo = ExerciseRepository();
  final exercises = repo.getAll();

  print("Checking options and correct answers for all exercises...");
  int totalMismatches = 0;

  for (final ex in exercises) {
    for (final step in ex.steps) {
      if (step.options != null && step.options!.isNotEmpty) {
        final hasAns = step.correctAnswer != null;
        if (!hasAns) {
          print("WARNING: Step ${ex.id} -> ${step.id} has options but no correctAnswer");
          continue;
        }

        final ans = step.correctAnswer!;
        final contains = step.options!.contains(ans);
        if (!contains) {
          print("ERROR: Step ${ex.id} -> ${step.id} has correctAnswer '$ans' which is NOT in options: ${step.options}");
          totalMismatches++;
        }
      }
    }
  }

  print("Audit completed. Total mismatches found: $totalMismatches");
}
