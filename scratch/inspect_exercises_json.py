import json

with open("scratch/exercises.json", "r", encoding="utf-8") as f:
    data = json.load(f)

print("First item keys:", data[0].keys())
print("First item structure:", json.dumps(data[0], indent=2)[:500])
print("Total exercises in scratch/exercises.json:", len(data))
