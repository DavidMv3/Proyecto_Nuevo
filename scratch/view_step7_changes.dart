import 'dart:io';
import 'dart:convert';

void main() {
  final file = File(r'C:\Users\jaime\.gemini\antigravity\brain\d562c66c-5257-492c-9d86-cdcd00ee1f69\.system_generated\logs\transcript.jsonl');
  final lines = file.readAsLinesSync();
  
  for (final line in lines) {
    try {
      final json = jsonDecode(line);
      final stepIndex = json['step_index'];
      if (stepIndex == null || stepIndex < 357 || stepIndex > 459) continue;
      
      final type = json['type'];
      final toolCalls = json['tool_calls'];
      if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
        for (final tc in toolCalls) {
          final name = tc['name'];
          if (name == 'replace_file_content' || name == 'multi_replace_file_content' || name == 'write_to_file') {
            final args = tc['arguments'] ?? tc['args'];
            print('Step $stepIndex: $name on file ${args['TargetFile'] ?? args['TargetFile']}');
          }
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
