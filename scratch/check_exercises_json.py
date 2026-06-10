import json

with open("scratch/exercises.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for idx, ex in enumerate(data):
    ex_id = ex.get("exercise_id", f"idx_{idx}")
    complexity = ex.get("complexity", "")
    expr = ex.get("initial_expression", "")
    ns = len(ex.get("workflow_steps", []))
    print(f"{ex_id} ({complexity}): expression='{expr}', steps={ns}")
