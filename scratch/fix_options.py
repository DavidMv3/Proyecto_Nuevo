import json

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

for ex in exercises:
    ex_id = ex["exercise_id"]
    for step in ex["workflow_steps"]:
        s_num = step["step_index"]

        def clean_option(text):
            if not isinstance(text, str):
                return text
            
            # medium_4 Step 3
            text = text.replace("La resta ($2 \\times 3$)$2 - 30$", "La resta $(2 \\times 3)^2 - 30$")
            text = text.replace("La potencia ($2 \\times 3$)2", "La potencia $(2 \\times 3)^2$")
            
            # medium_5 Step 3
            text = text.replace("La potencia ($8 \\div 2$) 2", "La potencia $(8 \\div 2)^2$")
            text = text.replace("La resta ($8 \\div 2$) $2 - 12$", "La resta $(8 \\div 2)^2 - 12$")
            
            # medium_7 Step 3
            text = text.replace("La resta 15 - ($7 - 4$)", "La resta $15 - (7 - 4)^2$")
            text = text.replace("La potencia ($7 - 4$)2", "La potencia $(7 - 4)^2$")
            
            return text

        if "instruction" in step:
            step["instruction"] = clean_option(step["instruction"])
        if "question" in step:
            step["question"] = clean_option(step["question"])
        if "correct_answer" in step:
            step["correct_answer"] = clean_option(step["correct_answer"])
        if "feedback_failure" in step:
            step["feedback_failure"] = clean_option(step["feedback_failure"])

        if "options" in step and step["options"] is not None:
            for opt in step["options"]:
                if opt and "text" in opt:
                    opt["text"] = clean_option(opt["text"])

with open("assets/exercises.json", "w", encoding="utf-8") as f:
    json.dump(exercises, f, ensure_ascii=False, indent=2)

print("Options replacement completed successfully!")
