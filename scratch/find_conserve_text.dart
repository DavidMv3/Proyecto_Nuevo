import 'dart:io';

void main() {
  final file = File('lib/data/repositories/exercise_repository.dart');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  
  final content = file.readAsStringSync();
  
  // Find all StepEntity instances
  final stepRegex = RegExp(
    r'StepEntity\(([\s\S]*?)\)',
    multiLine: true,
  );
  
  final matches = stepRegex.allMatches(content);
  print('Found ${matches.length} StepEntity matches.');
  
  // Let's find matches that contain 'conser' (case-insensitive) in instruction or correctAnswer
  for (final m in matches) {
    final stepCode = m.group(0)!;
    if (stepCode.toLowerCase().contains('conser')) {
      final idMatch = RegExp(r"id:\s*'([^']*)'").firstMatch(stepCode);
      final id = idMatch?.group(1) ?? 'unknown';
      final instMatch = RegExp(r"instruction:\s*'([^']*)'").firstMatch(stepCode);
      final inst = instMatch?.group(1) ?? '';
      final overrideMatch = RegExp(r"expressionOverride:\s*'([^']*)'").firstMatch(stepCode);
      final override = overrideMatch?.group(1);
      
      print('Step ID: $id');
      print('  Instruction: "$inst"');
      print('  Override: $override');
      print('-----------------------------');
    }
  }
}
