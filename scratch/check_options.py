import json

with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    exercises = json.load(f)

mismatches = []
total_steps = 0
for ex in exercises:
    for step in ex['steps']:
        total_steps += 1
        if step['options']:
            # Strip spaces and dollar signs to compare
            clean_correct = step['correctAnswer'].replace('$', '').strip()
            clean_options = [opt.replace('$', '').strip() for opt in step['options']]
            
            # Also check exact match
            if step['correctAnswer'] not in step['options']:
                # Maybe clean match works?
                if clean_correct in clean_options:
                    # It matches after stripping $ or spaces, but might need correction in code
                    mismatches.append({
                        'ex_id': ex['id'],
                        'step_id': step['id'],
                        'issue': 'Format mismatch (dollar signs or spaces)',
                        'correctAnswer': step['correctAnswer'],
                        'options': step['options']
                    })
                else:
                    mismatches.append({
                        'ex_id': ex['id'],
                        'step_id': step['id'],
                        'issue': 'Correct answer NOT in options',
                        'correctAnswer': step['correctAnswer'],
                        'options': step['options']
                    })

print(f"Total steps checked: {total_steps}")
print(f"Found {len(mismatches)} mismatches:")
for m in mismatches:
    print(json.dumps(m, indent=2, ensure_ascii=False))
