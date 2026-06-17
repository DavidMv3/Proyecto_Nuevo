import json
import re

with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    exercises = json.load(f)

flagged = []

for ex in exercises:
    steps = ex['steps']
    for idx in range(len(steps) - 1):
        step_curr = steps[idx]
        step_next = steps[idx + 1]
        
        curr_override = step_curr['expressionOverride']
        next_override = step_next['expressionOverride']
        
        if curr_override and next_override:
            # Clean spaces for comparison
            curr_clean = curr_override.replace(' ', '')
            next_clean = next_override.replace(' ', '')
            
            # Check if current is a prefix of next
            if next_clean.startswith(curr_clean) and next_clean != curr_clean:
                # The current override is a prefix of next override.
                # Let's check if the current override ends with an operator.
                last_char = curr_clean[-1]
                if last_char not in ['+', '-', '*', '/', '÷', '×', '(', '[', ':']:
                    flagged.append({
                        'ex_id': ex['id'],
                        'curr_id': step_curr['id'],
                        'next_id': step_next['id'],
                        'curr_override': curr_override,
                        'next_override': next_override,
                    })

print(f"Found {len(flagged)} potentially missing trailing operators:")
for f in flagged:
    print(json.dumps(f, indent=2))
