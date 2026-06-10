import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/parsed_ranges.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

print("Auditing parsed exercises from json...")
errors = 0
for ex in exercises:
    lvl = ex["complexity"]
    rom = ex["roman"]
    for step in ex["steps"]:
        s_num = step["num"]
        opt = step["options"]
        ans = step["correct_answer"]
        inst = step["instruction"]
        
        # Check if answer is empty for a multiple choice step
        if opt and not ans:
            print(f"ERROR: {lvl} {rom} Step {s_num} has options {opt} but empty correct_answer!")
            errors += 1
        # Check if answer is not in options (for multiple choice steps)
        if opt and ans and ans not in opt:
            # Check normalized
            norm_opt = [o.replace(" ", "").replace("×", "*").replace("÷", "/").replace(":", "/").replace("−", "-").lower() for o in opt]
            norm_ans = ans.replace(" ", "").replace("×", "*").replace("÷", "/").replace(":", "/").replace("−", "-").lower()
            if norm_ans not in norm_opt:
                print(f"WARNING: {lvl} {rom} Step {s_num} has ans '{ans}' not in options {opt}")
                errors += 1

print(f"Audit complete. Found {errors} errors/warnings.")
