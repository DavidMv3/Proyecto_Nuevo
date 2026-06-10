import json
with open('scratch/parsed_ranges.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
for ex in data:
    print(f"{ex['complexity']} {ex['roman']}: {ex['base_expression']}")
