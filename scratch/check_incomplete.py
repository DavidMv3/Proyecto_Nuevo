import json

def is_prefix(a, b):
    clean_a = a.replace(' ', '').replace('____', '').replace('?', '')
    clean_b = b.replace(' ', '').replace('____', '').replace('?', '')
    if not clean_a:
        return False
    return clean_b.startswith(clean_a)

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

for ex in exercises:
    ex_id = ex["exercise_id"]
    steps = ex["workflow_steps"]
    
    # Collect all overrides
    overrides = []
    for step in steps:
        val = step.get("display_append")
        if val is not None and val != "":
            overrides.append((step["step_index"], val))
            
    # Simulate final state where all overrides are completed
    raw_expressions = [ex["initial_expression"]]
    for idx, val in overrides:
        raw_expressions.append(val)
        
    # Apply prefix filtering
    filtered = []
    for i in range(len(raw_expressions)):
        current = raw_expressions[i]
        is_prefix_of_later = False
        for j in range(i + 1, len(raw_expressions)):
            if is_prefix(current, raw_expressions[j]):
                is_prefix_of_later = True
                break
        if not is_prefix_of_later:
            filtered.append(current)
            
    # Check if any filtered expression is "incomplete" (ends with [, +, -, etc.)
    for f in filtered:
        clean_f = f.strip()
        if clean_f.endswith("[") or clean_f.endswith("+") or clean_f.endswith("-") or clean_f.endswith("/") or clean_f.endswith("*") or clean_f == "[":
            print(f"In exercise {ex_id}: incomplete line remained visible: '{clean_f}'")
