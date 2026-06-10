import json
with open('scratch/parsed_ranges.json', 'r', encoding='utf-8') as f:
    d = json.load(f)
for i, ex in enumerate(d[:12]):
    print(f"{i+1}. {ex['complexity']} {ex['roman']}: {ex['base_expression']}")
