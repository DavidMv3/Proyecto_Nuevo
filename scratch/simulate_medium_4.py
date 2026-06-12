import json

# Load exercises.json
with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

exercise = next(ex for ex in exercises if ex["exercise_id"] == "medium_4")

def get_expression_for_step(step_index):
    # step_index is 0-indexed (0 to 10)
    for i in range(step_index - 1, -1, -1):
        override = exercise["workflow_steps"][i].get("display_append")
        if override:
            return override
    return exercise["initial_expression"]

print("SIMULATING medium_4 STEP PROGRESSION:")
print(f"Base expression: {exercise['initial_expression']}")

history = [exercise["initial_expression"]]
working_line = exercise["initial_expression"]

# Let's trace step by step
for step_idx in range(len(exercise["workflow_steps"])):
    step = exercise["workflow_steps"][step_idx]
    step_num = step_idx + 1
    
    # 1. Before solving:
    if step_idx > 0:
        working_line = get_expression_for_step(step_idx)
        
    # Check what gets rendered in UI (EquationHistory)
    raw_expressions = list(history)
    active_line = None
    if working_line and working_line.strip():
        active_line = working_line
    elif step.get("display_append") and False: # stepCompleted is false
        active_line = step.get("display_append")
        
    if active_line:
        clean_active = active_line.replace(" ", "").replace("____", "").replace("$", "")
        last_clean = raw_expressions[-1].replace(" ", "").replace("$", "") if raw_expressions else ""
        if not raw_expressions or last_clean != clean_active:
            raw_expressions.append(active_line)
            
    # Print what the user sees before answering
    step_desc = step.get('instruction', step.get('question', ''))
    print(f"\nStep {step_num} ({step_desc[:40]}): BEFORE ANSWERING")
    print("  Equations:")
    for eq in raw_expressions:
        is_base = eq.replace(" ", "") == exercise["initial_expression"].replace(" ", "")
        prefix = "" if is_base else "= "
        suffix = " =" if is_base else ""
        print(f"    {prefix}{eq}{suffix}")
        
    # 2. After solving (the user clicks correct option):
    # working_line updates to step's display_append (if any)
    override = step.get("display_append")
    if override:
        working_line = override
        
    # 3. Advance to next step (this adds previous working_line to history)
    if working_line:
        clean_working = working_line.replace(" ", "").replace("$", "")
        is_same_as_last = history and history[-1].replace(" ", "").replace("$", "") == clean_working
        if not is_same_as_last:
            history.append(working_line)
