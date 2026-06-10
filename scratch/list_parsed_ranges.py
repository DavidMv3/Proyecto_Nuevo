import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/parsed_ranges.json", "r", encoding="utf-8") as f:
    d = json.load(f)

print(f"Total exercises in parsed_ranges.json: {len(d)}")
for idx, x in enumerate(d, 1):
    print(f"{idx}. Complexity: {x.get('complexity')} | Roman: {x.get('roman')} | Base Expression: {x.get('base_expression')}")
