import re
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    pdf_text = f.read()

# remove "--- PAGE 18 ---" page markers to make it continuous
pdf_text = re.sub(r'\n*--- PAGE \d+ ---\n*', '\n', pdf_text)

# We have 3 sections: Baja, Media, Alta
sections = re.split(r'Complejidad (?:Media|Alta)', pdf_text)
baja_text = sections[0]
media_text = sections[1]
alta_text = sections[2]

def split_exercises(text, lvl):
    pattern = r'(?:\n|^)(I{1,3}|IV|V|VI{1,3}|IX|X)\)\s+([^=]+=.*?(?:\n|$))'
    matches = list(re.finditer(pattern, text))
    
    exercises = []
    for i, m in enumerate(matches):
        rom = m.group(1)
        base_expr = m.group(2).replace('(Colocar esta expresión aritmética en un solo color)', '').strip()
        start_idx = m.end()
        end_idx = matches[i+1].start() if i + 1 < len(matches) else len(text)
        ex_content = text[start_idx:end_idx]
        exercises.append((rom, base_expr, ex_content))
    return exercises

easy_exs = split_exercises(baja_text, "easy")
med_exs = split_exercises(media_text, "medium")
hard_exs = split_exercises(alta_text, "hard")

def clean_text(t):
    t = t.replace("−", "-").replace("×", "*").replace("÷", "/").replace(":", "/").replace("·", "*")
    t = re.sub(r'\s+', ' ', t)
    t = t.strip()
    return t

def pad_math_expr(t):
    t = clean_text(t)
    # Pad operators with spaces so the flutter UI can tokenize them
    t = re.sub(r'([+\-*/=()\[\]{}])', r' \1 ', t)
    # Remove multiple spaces
    t = re.sub(r'\s+', ' ', t)
    t = t.replace("s q r t", "sqrt") # Fix if sqrt gets split
    return t.strip()

parsed_exercises = []

for lvl, exs in [("easy", easy_exs), ("medium", med_exs), ("hard", hard_exs)]:
    for rom, base_expr, ex_text in exs:
        step_indices = []
        for match in re.finditer(r'(?:^|\n)(\d+)\)\s*(.*?)(?=\n\d+\)|$)', ex_text, re.DOTALL):
            step_num = int(match.group(1))
            step_content = match.group(2)
            step_indices.append((step_num, step_content))
            
        step_indices.sort(key=lambda x: x[0])
        parsed_steps = []
        
        for step_num, step_content in step_indices:
            opt_pattern = re.compile(r'(?:^|\n)([a-d1-4])\)\s*(.*?)(?=\n[a-d1-4]\)|$|\nSolución)', re.DOTALL)
            options = []
            for opt_match in opt_pattern.finditer(step_content):
                options.append(clean_text(opt_match.group(2)))
            
            sol_match = re.search(r'Solución\.\s*(.*?)(?=\nDebe aparecer|\nEn caso de|$)', step_content, re.DOTALL)
            correct_answer = ""
            if sol_match:
                sol_text = clean_text(sol_match.group(1))
                ans_match = re.search(r'(?:correcta es|correcta es:)\s*([a-d1-4])\)\s*(.*?)(?:\.|$)', sol_text)
                if ans_match:
                    desc = ans_match.group(2).strip()
                    matched_option = None
                    for opt in options:
                        if opt.startswith(desc) or desc.startswith(opt) or (len(opt) > 2 and opt[2:].strip() == desc):
                            matched_option = opt
                            break
                    correct_answer = matched_option if matched_option else desc
                elif "color azul" in sol_text:
                    correct_answer = "Seleccionar signos"
            
            feedback = ""
            feed_match = re.search(r'retroalimentación:\s*(.*?)(?:\.|$|\nDebe aparecer|\nUna vez que|$)', step_content, re.DOTALL)
            if feed_match:
                feedback = clean_text(feed_match.group(1))
                
            override = None
            over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)(?=\n\d+\)|$)', step_content, re.DOTALL)
            if over_match:
                over_lines = over_match.group(1).strip().split("\n")
                last_valid = None
                for ol in over_lines:
                    ol = ol.strip()
                    if not ol: continue
                    if re.match(r'^[a-d1-4]\)', ol): continue
                    if any(c in ol for c in ["+", "-", "*", "/", "sqrt", "root", "^", "[", "(", "{", "=", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]):
                        last_valid = ol
                if last_valid:
                    override = pad_math_expr(last_valid)
                    if override.startswith("="):
                        override = override[1:].strip()
            
            lines = step_content.split("\n")
            inst_lines = []
            for line in lines:
                line_str = line.strip()
                if line_str.startswith("Solución") or line_str.startswith("En caso de") or re.match(r'^[a-d1-4]\)', line_str) or line_str.startswith("Debe aparecer") or line_str.startswith("debe aparecer") or line_str.startswith("Una vez que"):
                    break
                inst_lines.append(line)
            instruction = clean_text(" ".join(inst_lines))
            
            parsed_steps.append({
                "num": step_num,
                "instruction": instruction,
                "options": options,
                "correct_answer": correct_answer,
                "feedback": feedback,
                "override": override
            })
            
        parsed_exercises.append({
            "complexity": lvl,
            "roman": rom,
            "base_expression": pad_math_expr(base_expr.replace("=", "")),
            "steps": parsed_steps
        })

with open("scratch/parsed_ranges.json", "w", encoding="utf-8") as f_out:
    json.dump(parsed_exercises, f_out, ensure_ascii=False, indent=2)

print(f"Successfully parsed {len(parsed_exercises)} exercises.")
