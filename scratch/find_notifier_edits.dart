import 'dart:io';
import 'dart:convert';

void main() {
  final file = File(r'C:\Users\jaime\.gemini\antigravity\brain\d562c66c-5257-492c-9d86-cdcd00ee1f69\.system_generated\logs\transcript.jsonl');
  final lines = file.readAsLinesSync();
  
  for (final line in lines) {
    try {
      final json = jsonDecode(line);
      final stepIndex = json['step_index'];
      final toolCalls = json['tool_calls'];
      if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
        for (final tc in toolCalls) {
          final name = tc['name'];
          final args = tc['arguments'] ?? tc['args'] ?? {};
          final argStr = args.toString();
          if (argStr.contains('notifier') || argStr.contains('interactive') || argStr.contains('notebook') || argStr.contains('token')) {
            print('Step $stepIndex: $name');
            if (args['TargetFile'] != null) {
              print('  TargetFile: ${args['TargetFile']}');
            }
          }
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
