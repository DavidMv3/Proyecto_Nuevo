import 'dart:io';
import 'dart:convert';

void main() {
  final file = File(r'C:\Users\jaime\.gemini\antigravity\brain\d562c66c-5257-492c-9d86-cdcd00ee1f69\.system_generated\logs\transcript.jsonl');
  if (!file.existsSync()) {
    print('File does not exist');
    return;
  }
  
  final lines = file.readAsLinesSync();
  print('Total lines in transcript: ${lines.length}');
  
  // Find the last few tools calls or USER_INPUT
  int count = 0;
  for (int i = lines.length - 1; i >= 0; i--) {
    final line = lines[i];
    try {
      final json = jsonDecode(line);
      if (json['type'] == 'USER_INPUT') {
        print('\n--- USER INPUT (Step ${json['step_index']}) ---');
        print(json['content']);
        count++;
      } else if (json['type'] == 'PLANNER_RESPONSE' || json['tool_calls'] != null) {
        final toolCalls = json['tool_calls'];
        if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
          print('  Step ${json['step_index']}: Tool calls: ${toolCalls.map((t) => t['name'])}');
        }
      }
      if (count >= 5) break;
    } catch (e) {
      // Ignore
    }
  }
}
