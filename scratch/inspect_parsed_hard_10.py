import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/parsed_ranges.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

hard_10 = next(ex for ex in exercises if ex["complexity"] == "hard" and ex["roman"] == "X")

print(f"Hard X has {len(hard_10['steps'])} steps:")
for step in hard_10["steps"]:
    print(f"Step {step['num']}: {step['instruction']}")
    print(f"  Options: {step['options']}")
    print(f"  Correct Answer: {step['correct_answer']}")
    print(f"  Override: {step['override']}")
