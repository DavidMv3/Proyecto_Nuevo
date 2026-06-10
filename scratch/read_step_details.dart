import 'dart:io';
import 'dart:convert';

void main() {
  final file = File(r'C:\Users\jaime\.gemini\antigravity\brain\d562c66c-5257-492c-9d86-cdcd00ee1f69\.system_generated\logs\transcript.jsonl');
  final lines = file.readAsLinesSync();
  
  for (final line in lines) {
    try {
      final json = jsonDecode(line);
      final stepIndex = json['step_index'];
      if (stepIndex == 437 || stepIndex == 438 || stepIndex == 443 || stepIndex == 444) {
        print('\n=== STEP $stepIndex ===');
        print('Source: ${json['source']}, Type: ${json['type']}');
        final toolCalls = json['tool_calls'];
        if (toolCalls != null && toolCalls is List && toolCalls.isNotEmpty) {
          print(JsonEncoder.withIndent('  ').convert(toolCalls));
        }
      }
    } catch (e) {
      // Ignore
    }
  }
}
