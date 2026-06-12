import json

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

for ex in exercises:
    ex_id = ex["exercise_id"]
    for step in ex["workflow_steps"]:
        s_num = step["step_index"]

        # Helper to clean general fields
        def clean_text(text):
            if not isinstance(text, str):
                return text
            
            # medium_2 Step 3 option:
            text = text.replace("La multiplicación $23 \\times 22$", "La multiplicación $2^3 \\times 2^2$")
            # medium_2 Step 4 question:
            text = text.replace("2$3 \\times 2$2", "$2^3 \\times 2^2$")
            
            # medium_6 Step 3 option:
            text = text.replace("La potencia exterior(22)3", "La potencia exterior $(2^2)^3$")
            # medium_6 Step 4 question:
            text = text.replace("en(22)3", "en $(2^2)^3$")
            
            # feedback failure raw powers
            text = text.replace("Recuerda que 32 = $3 \\times 3$ = 9", "Recuerda que $3^2$ = $3 \\times 3$ = 9")
            text = text.replace("Recuerda que 25 = $2 \\times 2 \\times 2 \\times 2 \\times 2$ = 32", "Recuerda que $2^5$ = $2 \\times 2 \\times 2 \\times 2 \\times 2$ = 32")
            text = text.replace("Recuerda que 23 = $2 \\times 2 \\times 2$ = 8", "Recuerda que $2^3$ = $2 \\times 2 \\times 2$ = 8")
            text = text.replace("Recuerda que 62 = $6 \\times 6$ = 36", "Recuerda que $6^2$ = $6 \\times 6$ = 36")
            text = text.replace("Recuerda que 52 = $5 \\times 5$ = 25", "Recuerda que $5^2$ = $5 \\times 5$ = 25")
            text = text.replace("Recuerda que 42 = $4 \\times 4$ = 16", "Recuerda que $4^2$ = $4 \\times 4$ = 16")
            text = text.replace("Recuerda que 26 = $2 \\times 2 \\times 2 \\times 2 \\times 2 \\times 2$ = 64", "Recuerda que $2^6$ = $2 \\times 2 \\times 2 \\times 2 \\times 2 \\times 2$ = 64")
            text = text.replace("Recuerda que 24 = $2 \\times 2 \\times 2 \\times 2$ = 16", "Recuerda que $2^4$ = $2 \\times 2 \\times 2 \\times 2$ = 16")
            
            # medium_8 Step 4
            text = text.replace("√ 144 ÷ √ 16", "$\\sqrt{144} \\div \\sqrt{16}$")
            text = text.replace("√$144 \\div 16$", "$\\sqrt{144 \\div 16}$")
            text = text.replace("√$144 + 16$", "$\\sqrt{144 + 16}$")
            text = text.replace("√$144 - 16$", "$\\sqrt{144 - 16}$")
            text = text.replace("√$144 \\times 16$", "$\\sqrt{144 \\times 16}$")
            text = text.replace("√ 144 ÷ √ 16 = √$144 \\div 16$", "$\\sqrt{144} \\div \\sqrt{16} = \\sqrt{144 \\div 16}$")
            text = text.replace("La división √ 144 ÷ √ 16", "La división $\\sqrt{144} \\div \\sqrt{16}$")
            
            # medium_9
            text = text.replace("p√ 81", "$\\sqrt{\\sqrt{81}}$")
            text = text.replace("4√ 81", "$\\sqrt[4]{81}$")
            text = text.replace("√ 81", "$\\sqrt{81}$")
            text = text.replace("3√ 81", "$\\sqrt[3]{81}$")
            text = text.replace("812", "$81^2$")
            text = text.replace("34 = 81", "$3^4 = 81$")
            text = text.replace("Como 34 = 81, entonces 4√ 81 = 3", "Como $3^4 = 81$, entonces $\\sqrt[4]{81} = 3$")
            text = text.replace("La raíz cuarta 4√ 81", "La raíz cuarta $\\sqrt[4]{81}$")
            
            # medium_10
            text = text.replace("10√ 620", "$\\sqrt[10]{6^{20}}$")
            text = text.replace("La raíz 10√ 620", "La raíz $\\sqrt[10]{6^{20}}$")
            text = text.replace("La raíz cuadrada √ 36", "La raíz cuadrada $\\sqrt{36}$")
            text = text.replace("La raíz cuadrada √ 36 es:", "La raíz cuadrada $\\sqrt{36}$ es:")
            text = text.replace("La suma $62 + 16$", "La suma $6^2 + 16$")
            
            # hard_4
            text = text.replace("3√an = a n 3", "$\\sqrt[3]{a^n} = a^{\\frac{n}{3}}$")
            text = text.replace("La multiplicación $3 \\times 3$√ 56", "La multiplicación $3 \\times \\sqrt[3]{5^6}$")
            text = text.replace("La potenciación 56", "La potenciación $5^6$")
            text = text.replace("3 \\times 2$5", "3 \\times 25$")
            
            # hard_5
            text = text.replace("potencia$33$", "potencia $3^3$")
            text = text.replace("potencia $33$", "potencia $3^3$")
            text = text.replace("$33$", "$3^3$")
            
            # hard_6
            text = text.replace("3√ 312 = 3 12 3", "$\\sqrt[3]{3^{12}} = 3^{\\frac{12}{3}}$")
            text = text.replace("2√ 34 = 3 4 2", "$\\sqrt{3^4} = 3^{\\frac{4}{2}}$")
            
            # hard_8
            if text == "23 = 8":
                text = "$2^3 = 8$"
            elif text == "22 = 4":
                text = "$2^2 = 4$"
                
            return text

        if "instruction" in step:
            step["instruction"] = clean_text(step["instruction"])
        if "question" in step:
            step["question"] = clean_text(step["question"])
        if "correct_answer" in step:
            step["correct_answer"] = clean_text(step["correct_answer"])
        if "feedback_failure" in step:
            step["feedback_failure"] = clean_text(step["feedback_failure"])

        if "options" in step and step["options"] is not None:
            for opt in step["options"]:
                if opt and "text" in opt:
                    opt["text"] = clean_text(opt["text"])

        # Precise option formatting overrides for medium_2 step 4
        if ex_id == "medium_2" and s_num == 4:
            if "options" in step:
                for opt in step["options"]:
                    if opt["text"] == "26": opt["text"] = "$2^6$"
                    elif opt["text"] == "25": opt["text"] = "$2^5$"
                    elif opt["text"] == "45": opt["text"] = "$4^5$"
                    elif opt["text"] == "21": opt["text"] = "$2^1$"
            if step.get("correct_answer") == "25":
                step["correct_answer"] = "$2^5$"

        # Precise option formatting overrides for medium_6 step 4
        if ex_id == "medium_6" and s_num == 4:
            if "options" in step:
                for opt in step["options"]:
                    if opt["text"] == "25": opt["text"] = "$2^5$"
                    elif opt["text"] == "26": opt["text"] = "$2^6$"
                    elif opt["text"] == "43": opt["text"] = "$4^3$"
                    elif opt["text"] == "29": opt["text"] = "$2^9$"
            if step.get("correct_answer") == "26":
                step["correct_answer"] = "$2^6$"

        # Precise option formatting overrides for medium_10 step 4
        if ex_id == "medium_10" and s_num == 4:
            if "options" in step:
                for opt in step["options"]:
                    if opt["text"] == "610": opt["text"] = "$6^{10}$"
                    elif opt["text"] == "62": opt["text"] = "$6^2$"
                    elif opt["text"] == "630": opt["text"] = "$6^{30}$"
                    elif opt["text"] == "620": opt["text"] = "$6^{20}$"
            if step.get("correct_answer") == "62":
                step["correct_answer"] = "$6^2$"

with open("assets/exercises.json", "w", encoding="utf-8") as f:
    json.dump(exercises, f, ensure_ascii=False, indent=2)

print("Replacement complete successfully!")
