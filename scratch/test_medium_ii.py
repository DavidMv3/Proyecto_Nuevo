import json
import sys
sys.stdout.reconfigure(encoding='utf-8')
with open('scratch/parsed_ranges.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for ex in data:
    if ex['complexity'] == 'medium' and ex['roman'] == 'II':
        for step in ex['steps']:
            print(f"Step {step['num']}: Answer: '{step['correct_answer']}' options: {step['options']}")
