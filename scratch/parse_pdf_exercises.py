import re
import json

def clean_expr(expr):
    expr = expr.replace("×", "*").replace("÷", "/").replace("−", "-").replace(":", "/")
    expr = re.sub(r'\(Colocar.*?\)', '', expr)
    expr = expr.strip()
    return expr

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

# Dividir por páginas
pages = content.split("=== PAGE ")
parsed_exercises = []

# Expresiones regulares
expr_pattern = re.compile(r'^([IVX]+)\)\s*(.*?)\s*=\s*(?:\(Colocar|$)', re.MULTILINE)

current_exercise = None

for page_str in pages:
    if not page_str.strip():
        continue
    
    lines = page_str.split("\n")
    page_num = lines[0].split(" ===")[0].strip()
    page_text = "\n".join(lines[1:])
    
    # Buscar si inicia un ejercicio
    expr_match = expr_pattern.search(page_text)
    if expr_match:
        if current_exercise:
            parsed_exercises.append(current_exercise)
        roman = expr_match.group(1)
        raw_expr = expr_match.group(2)
        base_expr = clean_expr(raw_expr)
        
        # Determinar complejidad
        complexity = "Baja"
        if "Complejidad Media" in page_text:
            complexity = "Media"
        elif "Complejidad Alta" in page_text:
            complexity = "Alta"
        elif int(page_num) >= 94:
            complexity = "Alta"
        elif int(page_num) >= 39:
            complexity = "Media"
            
        current_exercise = {
            "roman": roman,
            "page": int(page_num),
            "base_expression": base_expr,
            "complexity": complexity,
            "steps": []
        }
    
    if current_exercise:
        # Buscar preguntas en esta página
        step_matches = re.finditer(r'^(\d+)\)\s*(.*?)$', page_text, re.MULTILINE)
        for sm in step_matches:
            step_num = int(sm.group(1))
            step_desc = sm.group(2).strip()
            
            # Evitar duplicar preguntas
            if any(s["num"] == step_num for s in current_exercise["steps"]):
                continue
                
            # Extraer opciones
            pos = page_text.find(sm.group(0))
            next_question_pos = page_text.find(f"{step_num + 1})", pos)
            solucion_pos = page_text.find("Solución.", pos)
            
            end_pos = min(x for x in [next_question_pos, solucion_pos] if x != -1) if (next_question_pos != -1 or solucion_pos != -1) else len(page_text)
            question_block = page_text[pos:end_pos]
            
            opt_matches = re.findall(r'^[a-d1-4]\)\s*(.*?)$', question_block, re.MULTILINE)
            options = [o.strip() for o in opt_matches]
            
            # Buscar solución
            sol_match = re.search(r'Solución\.\s*(.*?)$', page_text[pos:], re.MULTILINE)
            correct_answer = ""
            correct_ids = []
            if sol_match:
                sol_text = sol_match.group(1).strip()
                ans_match = re.search(r'es\s+([a-d1-4])\)\s*(.*?)(?:\.|$)', sol_text)
                if ans_match:
                    correct_answer = ans_match.group(2).strip()
                else:
                    ans_match_2 = re.search(r'es:\s+([a-d1-4])\)\s*(.*?)(?:\.|$)', sol_text)
                    if ans_match_2:
                        correct_answer = ans_match_2.group(2).strip()
                    elif "color azul" in sol_text:
                        correct_answer = "Seleccionar signos"
            
            # Buscar retroalimentación
            feedback = ""
            feed_match = re.search(r'retroalimentación:\s*(.*?)(?:\.|$|\nDebe aparecer)', page_text[pos:])
            if feed_match:
                feedback = feed_match.group(1).strip()
                
            # Buscar override (Debe aparecer: ...)
            override = None
            over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)$', page_text[pos:], re.DOTALL)
            if over_match:
                over_lines = over_match.group(1).strip().split("\n")
                for ol in over_lines:
                    ol = ol.strip()
                    if ol.startswith("="):
                        override = clean_expr(ol.replace("=", ""))
                        break
                    elif any(c in ol for c in ["+", "-", "*", "/", "sqrt", "root"]):
                        override = clean_expr(ol)
                        break

            current_exercise["steps"].append({
                "num": step_num,
                "instruction": step_desc,
                "options": options,
                "correct_answer": correct_answer,
                "correct_ids": correct_ids,
                "feedback": feedback,
                "override": override
            })

if current_exercise:
    parsed_exercises.append(current_exercise)

# Escribir a JSON
with open("scratch/parsed_exercises.json", "w", encoding="utf-8") as f:
    json.dump(parsed_exercises, f, ensure_ascii=False, indent=2)

print(f"Done! Parsed {len(parsed_exercises)} exercises and saved to scratch/parsed_exercises.json")
