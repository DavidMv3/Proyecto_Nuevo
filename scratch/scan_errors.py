import json
import re
import sys

# Reconfigure stdout to use UTF-8
sys.stdout.reconfigure(encoding="utf-8")

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

print("SCANNING FOR FORMATTING ERRORS IN EXERCISES.JSON:")

# Regex to find things like 62 = 6 x 6 or 62 = $6 \times 6$
pattern_feedback = re.compile(r"\b(\d)(\d)\s*=\s*\$?\s*\1\s*\\times\s*\1\s*\$?\s*=\s*\d+")
# Regex to find things like 62 = 36 or 62 = $36$
pattern_feedback_simple = re.compile(r"\b(\d)2\s*=\s*\$?\s*\1\s*\\times")

for ex_idx, ex in enumerate(exercises):
    ex_id = ex["exercise_id"]
    for s_idx, step in enumerate(ex["workflow_steps"]):
        step_index = step["step_index"]
        
        # 1. Check feedback_failure
        feedback = step.get("feedback_failure", "")
        if feedback:
            # Look for things like "62 =" or "52 =" (meaning 6^2 or 5^2)
            m = re.findall(r"\b\d{2}\s*=", feedback)
            if m:
                print(f"[{ex_id}] Step {step_index} feedback has potential raw power: '{feedback}'")
                
        # 2. Check question / instruction / question options
        question = step.get("question", "")
        instruction = step.get("instruction", "")
        for text in [question, instruction]:
            if text:
                # Look for things like (22)3 or similar
                if re.search(r"\(\d+\)\d+", text) or re.search(r"\b\d{2}\b", text) and any(word in text.lower() for word in ["potencia", "propiedad", "exponente"]):
                    print(f"[{ex_id}] Step {step_index} text has potential error: '{text}'")

        # 3. Check options
        options = step.get("options", [])
        if options:
            for opt in options:
                opt_text = opt.get("text", "")
                # If option is a number like 25, 26, 29 in a step about potencias
                if opt_text in ["25", "26", "29", "43"] and "potencia" in str(step.values()).lower():
                    print(f"[{ex_id}] Step {step_index} option is raw number: '{opt_text}'")
                # If option has (22)3
                if "(22)3" in opt_text:
                    print(f"[{ex_id}] Step {step_index} option has (22)3: '{opt_text}'")
