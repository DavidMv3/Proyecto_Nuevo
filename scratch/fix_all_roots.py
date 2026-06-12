import json

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

for ex in exercises:
    ex_id = ex["exercise_id"]
    for step in ex["workflow_steps"]:
        def clean_roots(text):
            if not isinstance(text, str):
                return text
            
            # Replace various plain root formats with beautiful LaTeX equivalents
            text = text.replace("La suma √ $9 + 20$", "La suma $\\sqrt{9} + 20$")
            text = text.replace("La raíz cuadrada √ 9", "La raíz cuadrada $\\sqrt{9}$")
            text = text.replace("El resultado de la raíz cuadrada √ 9 es:", "El resultado de la raíz cuadrada $\\sqrt{9}$ es:")
            text = text.replace("El resultado de la raíz cuadrada √ 9 es $3$", "El resultado de la raíz cuadrada $\\sqrt{9}$ es $3$")
            text = text.replace("La suma 4√ $81 + 16$", "La suma $\\sqrt[4]{81} + 16$")
            text = text.replace("El resultado de la raíz cuadrada √ 36 es:", "El resultado de la raíz cuadrada $\\sqrt{36}$ es:")
            text = text.replace("El resultado de la raíz cuadrada √ 36 es $6$", "El resultado de la raíz cuadrada $\\sqrt{36}$ es $6$")
            text = text.replace("Al aplicar la propiedad√an = a n 2, el exponente queda÷", "Al aplicar la propiedad $\\sqrt{a^n} = a^{\\frac{n}{2}}$, el exponente queda:")
            text = text.replace("El resultado de la raíz cuadrada √ 49 es $7$", "El resultado de la raíz cuadrada $\\sqrt{49}$ es $7$")
            text = text.replace("El resultado de $3$√ 8 es:", "El resultado de $\\sqrt[3]{8}$ es:")
            text = text.replace("3√ 8 = 2", "$\\sqrt[3]{8} = 2$")
            text = text.replace("El resultado de la raíz cuadrada √ 25 es:", "El resultado de la raíz cuadrada $\\sqrt{25}$ es:")
            text = text.replace("El resultado de la raíz cuadrada √ 25 es $5$", "El resultado de la raíz cuadrada $\\sqrt{25}$ es $5$")
            
            return text

        if "instruction" in step:
            step["instruction"] = clean_roots(step["instruction"])
        if "question" in step:
            step["question"] = clean_roots(step["question"])
        if "correct_answer" in step:
            step["correct_answer"] = clean_roots(step["correct_answer"])
        if "feedback_failure" in step:
            step["feedback_failure"] = clean_roots(step["feedback_failure"])

        if "options" in step and step["options"] is not None:
            for opt in step["options"]:
                if opt and "text" in opt:
                    opt["text"] = clean_roots(opt["text"])

with open("assets/exercises.json", "w", encoding="utf-8") as f:
    json.dump(exercises, f, ensure_ascii=False, indent=2)

print("Roots replacement completed successfully!")
