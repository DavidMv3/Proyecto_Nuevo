import json
import re

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

print("SCANNING FOR PARENTHESIS EXPONENT ERRORS:")

for ex in exercises:
    ex_id = ex["exercise_id"]
    for step in ex["workflow_steps"]:
        step_index = step["step_index"]
        
        # Check all fields
        for field in ["instruction", "question", "correct_answer", "feedback_failure"]:
            val = step.get(field, "")
            if val and re.search(r"\)\s*\d+", val):
                print(f"[{ex_id}] Step {step_index} {field} has: '{val}'")
                
        # Check options
        for opt in step.get("options", []) or []:
            opt_text = opt.get("text", "")
            if opt_text and re.search(r"\)\s*\d+", opt_text):
                print(f"[{ex_id}] Step {step_index} option has: '{opt_text}'")
