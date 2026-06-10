import re
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

base_expressions = {
    ("easy", "I"): "4 * 5 - 6 / 3",
    ("easy", "II"): "18 + 3 * 5",
    ("easy", "III"): "8 - 3 * 2 + 1",
    ("easy", "IV"): "10 - 3 * 2 + 2 ^ 3",
    ("easy", "V"): "1 + 12 / 4 - 1 + 2 ^ 3",
    ("easy", "VI"): "3 - 2 + ( 8 - 2 * 3 )",
    ("easy", "VII"): "sqrt( 4 + 12 ) - 15 / 5",
    ("easy", "VIII"): "3 ^ 2 + 5 * 2 - sqrt( 30 - 5 )",
    ("easy", "IX"): "4 * ( 20 / 4 + 1 ) + 4 * 2 ^ 3",
    ("easy", "X"): "( 2 + 10 / 5 ) * 2 ^ 2 - 3",

        ("medium", "I"): "3 ^ 6 / 3 ^ 4 - 2 * ( 5 - 2 )",
    ("medium", "II"): "[ 2 ^ 3 * 2 ^ 2 - 20 ] + [ 6 + 3 ^ 2 ]",
    ("medium", "III"): "[ 3 ^ 4 / 3 ^ 2 + 7 ] - [ 7 + 2 ^ 3 ]",
    ("medium", "IV"): "[ ( 2 * 3 ) ^ 2 - 30 ] + [ 18 / 3 + 10 ]",
    ("medium", "V"): "[ ( 8 / 2 ) ^ 2 - 12 ] + [ 5 ^ 2 - 4 ]",
    ("medium", "VI"): "[ ( 2 ^ 2 ) ^ 3 - 50 / 5 ] + [ 9 * 2 - 15 ]",
    ("medium", "VII"): "[ 15 - ( 7 - 4 ) ^ 2 ] + [ 3 * 5 + 20 ]",
    ("medium", "VIII"): "[ sqrt( 144 ) / sqrt( 16 ) + 20 ] - [ 5 ^ 2 - 10 ]",
    ("medium", "IX"): "[ sqrt( sqrt( 81 ) ) + 4 ^ 2 ] - [ 30 / 5 - 3 ]",
    ("medium", "X"): "[ root10( 6 ^ 20 ) + 2 ^ 4 ] - [ sqrt( 16 ) + 20 - 3 ]",
    
    ("hard", "I"): "15 * 2 + sqrt( 4 + 5 ) - ( 2 * 3 - 1 )",
    ("hard", "II"): "30 - 7 ^ 6 / 7 ^ 5 + 8 / 2 * 4",
    ("hard", "III"): "sqrt( 2 ^ 6 ) + 3 * ( 5 - 2 ) / ( 3 - 2 )",
    ("hard", "IV"): "55 - 3 * 2 + 3 * root3( 5 ^ 6 )",
    ("hard", "V"): "3 * [ 3 ^ 3 - 16 / ( 5 + 3 ) ]",
    ("hard", "VI"): "20 + 10 / 5 - sqrt( root3( 3 ^ 12 ) ) + 1",
    ("hard", "VII"): "( 2 ^ 2 + 1 ) ^ 3 + [ 10 - ( 9 / 3 + 1 ) ] - sqrt( 9 + 40 )",
    ("hard", "VIII"): "5 + [ 15 - ( 3 - 1 ) ^ 2 + 2 ^ 3 ] + root3( 7 + 1 )",
    ("hard", "IX"): "( 9 ^ 2 + 2 ) * 3 - sqrt( 23 + 10 / ( 2 ^ 2 + 1 ) ) - ( 6 + 2 ) ^ 2",
    ("hard", "X"): "5 ^ 2 + 8 * 2 ^ 2 - 7 ^ 8 / 7 ^ 6 + 2 * ( 5 + 4 / 2 ) - sqrt ( 15 + 1 )",
}

ranges = {
    ("easy", "I"): (1, 2),
    ("easy", "II"): (3, 5),
    ("easy", "III"): (6, 7),
    ("easy", "IV"): (8, 10),
    ("easy", "V"): (11, 14),
    ("easy", "VI"): (15, 17),
    ("easy", "VII"): (18, 22),
    ("easy", "VIII"): (23, 26),
    ("easy", "IX"): (27, 32),
    ("easy", "X"): (33, 38),

        ("medium", "I"): (39, 43),
    ("medium", "II"): (44, 48),
    ("medium", "III"): (49, 53),
    ("medium", "IV"): (54, 58),
    ("medium", "V"): (59, 63),
    ("medium", "VI"): (64, 69),
    ("medium", "VII"): (70, 74),
    ("medium", "VIII"): (75, 80),
    ("medium", "IX"): (81, 86),
    ("medium", "X"): (87, 93),
    
    ("hard", "I"): (94, 99),
    ("hard", "II"): (100, 102),
    ("hard", "III"): (103, 110),
    ("hard", "IV"): (111, 115),
    ("hard", "V"): (116, 120),
    ("hard", "VI"): (121, 125),
    ("hard", "VII"): (126, 135),
    ("hard", "VIII"): (136, 142),
    ("hard", "IX"): (143, 152),
    ("hard", "X"): (153, 163),
}

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    pdf_text = f.read()

pages = pdf_text.split("--- PAGE ")
page_dict = {}
for p in pages:
    if not p.strip():
        continue
    lines = p.split("\n")
    p_num = int(lines[0].split(" ---")[0].strip())
    p_text = "\n".join(lines[1:])
    page_dict[p_num] = p_text

def clean_text(t):
    # Normalize symbols for overrides
    t = t.replace("−", "-").replace("×", "*").replace("÷", "/").replace(":", "/").replace("·", "*")
    t = re.sub(r'\s+', ' ', t)
    t = t.strip()
    return t

parsed_exercises = []

for (lvl, rom), (start, end) in ranges.items():
    print(f"Parsing {lvl} {rom} (Pages {start}-{end})...")
    # Gather exercise text
    ex_text_parts = []
    for p in range(start, end + 1):
        if p in page_dict:
            ex_text_parts.append(page_dict[p])
    
    full_ex_text = "\n".join(ex_text_parts)
    
    # We find questions. A question starts with "1)", "2)", etc. at the start of a line
    # (or in a way that represents a new question)
    # Using regex to find steps
    steps = []
    # To split by steps, let's find indices of "\n1) ", "\n2) ", etc.
    # We will search using regex
    step_indices = []
    # Find all pattern like "\n\d+\)" or at the very start of the text
    for match in re.finditer(r'(?:^|\n)(\d+)\)\s*(.*?)(?=\n\d+\)|$)', full_ex_text, re.DOTALL):
        step_num = int(match.group(1))
        step_content = match.group(2)
        step_indices.append((step_num, step_content))
    
    # Sort steps by number
    step_indices.sort(key=lambda x: x[0])
    
    parsed_steps = []
    for step_num, step_content in step_indices:
        # Extract options
        # Options are like: a) ... b) ... c) ... d) ... or 1) ... 2) ... 3) ... 4) ...
        # Let's find them
        opt_pattern = re.compile(r'(?:^|\n)([a-d1-4])\)\s*(.*?)(?=\n[a-d1-4]\)|$|\nSolución)', re.DOTALL)
        options = []
        for opt_match in opt_pattern.finditer(step_content):
            options.append(clean_text(opt_match.group(2)))
        
        # Extract solution
        sol_match = re.search(r'Solución\.\s*(.*?)(?=\nDebe aparecer|\nEn caso de|$)', step_content, re.DOTALL)
        correct_answer = ""
        if sol_match:
            sol_text = clean_text(sol_match.group(1))
            # Find correct option letter/number
            ans_match = re.search(r'(?:correcta es|correcta es:)\s*([a-d1-4])\)\s*(.*?)(?:\.|$)', sol_text)
            if ans_match:
                letter = ans_match.group(1)
                desc = ans_match.group(2).strip()
                # Find matching option in our options list
                matched_option = None
                for opt in options:
                    if opt.startswith(desc) or desc.startswith(opt) or (len(opt) > 2 and opt[2:].strip() == desc):
                        matched_option = opt
                        break
                correct_answer = matched_option if matched_option else desc
            elif "color azul" in sol_text:
                correct_answer = "Seleccionar signos"
        
        # Extract feedback
        feedback = ""
        feed_match = re.search(r'retroalimentación:\s*(.*?)(?:\.|$|\nDebe aparecer|\nUna vez que|$)', step_content, re.DOTALL)
        if feed_match:
            feedback = clean_text(feed_match.group(1))
            
        # Extract override
        override = None
        # Look for "Debe aparecer:" or "debe aparecer:" followed by mathematical lines
        over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)(?=\n\d+\)|$)', step_content, re.DOTALL)
        if over_match:
            over_lines = over_match.group(1).strip().split("\n")
            last_valid = None
            for ol in over_lines:
                ol = ol.strip()
                if not ol: continue
                if "---" in ol: continue
                if re.match(r'^[a-d1-4]\)', ol): continue
                if any(c in ol for c in ["+", "-", "*", "/", "sqrt", "root", "^", "[", "(", "{", "=", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]):
                    last_valid = ol
            if last_valid:
                override = clean_text(last_valid)
                if override.startswith("="):
                    override = override[1:].strip()
                if rom == "VI" and step_num == 7:
                    print(f"DEBUG VI-7: last_valid={last_valid}, override={override}")

        # Remove options and solution stuff from the instruction to get clean text
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
        "base_expression": base_expressions[(lvl, rom)],
        "steps": parsed_steps
    })

with open("scratch/parsed_ranges.json", "w", encoding="utf-8") as f_out:
    json.dump(parsed_exercises, f_out, ensure_ascii=False, indent=2)

print(f"Successfully parsed {len(parsed_exercises)} exercises from ranges.")
