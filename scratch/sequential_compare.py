import re
import json

# Load the extracted exercises from dart
with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    dart_exercises = json.load(f)

# Load the PDF text
with open('pdf_text.txt', 'r', encoding='utf-8') as f:
    pdf_text = f.read()

# Locate the three main complexity sections in the PDF
low_pos = pdf_text.find("0.1 Complejidad Baja")
med_pos = pdf_text.find("0.2 Complejidad Media")
high_pos = pdf_text.find("0.3 Complejidad Alta")

# Split the PDF into three main sections
low_text = pdf_text[low_pos:med_pos]
med_text = pdf_text[med_pos:high_pos]
high_text = pdf_text[high_pos:]

roman_numerals = ["I)", "II)", "III)", "IV)", "V)", "VI)", "VII)", "VIII)", "IX)", "X)"]

def split_into_exercises(section_text):
    exercises_blocks = {}
    positions = []
    
    for r in roman_numerals:
        pattern = r"(?:^|\n)\s*" + re.escape(r)
        match = re.search(pattern, section_text)
        if match:
            positions.append((r, match.start()))
            
    positions.sort(key=lambda x: x[1])
    
    for idx, (roman, pos) in enumerate(positions):
        next_pos = positions[idx+1][1] if idx + 1 < len(positions) else len(section_text)
        block_text = section_text[pos:next_pos]
        exercises_blocks[roman] = block_text
        
    return exercises_blocks

low_blocks = split_into_exercises(low_text)
med_blocks = split_into_exercises(med_text)
high_blocks = split_into_exercises(high_text)

mapping = {}
for i in range(1, 11):
    mapping[f"easy_{i}"] = low_blocks.get(roman_numerals[i-1], "")
    mapping[f"medium_{i}"] = med_blocks.get(roman_numerals[i-1], "")
    mapping[f"hard_{i}"] = high_blocks.get(roman_numerals[i-1], "")

def parse_questions_strictly(block_text):
    # Find questions sequentially: 1), 2), 3), 4), ...
    questions = {}
    current_num = 1
    
    # We will find the position of "1)" in the block text
    # then "2)", "3)", etc.
    last_pos = 0
    q_positions = []
    
    while True:
        # Search for current_num followed by ")"
        # It must be at the start of a line or after a newline/spaces
        pattern = r"(?:^|\n)\s*" + str(current_num) + r"\)"
        match = re.search(pattern, block_text[last_pos:])
        if match:
            pos = last_pos + match.start()
            q_positions.append((str(current_num), pos))
            last_pos = pos + len(str(current_num)) + 1
            current_num += 1
        else:
            break
            
    # Now extract the text for each question
    for idx, (q_num, pos) in enumerate(q_positions):
        next_pos = q_positions[idx+1][1] if idx + 1 < len(q_positions) else len(block_text)
        q_text = block_text[pos:next_pos]
        
        # Split into question, options, solution
        sol_pos = q_text.find("Solución.")
        if sol_pos == -1:
            q_body_and_opts = q_text
            sol_body = ""
        else:
            q_body_and_opts = q_text[:sol_pos]
            sol_body = q_text[sol_pos:]
            
        # Parse options: a), b), c), d) or 1), 2), 3), 4)
        opts = []
        opt_matches = re.findall(r"\b([a-d])\)\s*(.*?)(?=\b[a-d]\)|\n|$)", q_body_and_opts, re.DOTALL)
        if opt_matches:
            opts = [m[1].strip() for m in opt_matches]
        else:
            opt_matches = re.findall(r"\b([1-4])\)\s*(.*?)(?=\b[1-4]\)|\n|$)", q_body_and_opts, re.DOTALL)
            if opt_matches:
                opts = [m[1].strip() for m in opt_matches]
                
        # Parse correct answer text
        correct_text = ""
        correct_opt = ""
        correct_match = re.search(r"correcta\s+es\s+(?::\s*)?([a-d1-4])\)?\s*(.*)", sol_body, re.IGNORECASE)
        if correct_match:
            correct_opt = correct_match.group(1)
            correct_text = correct_match.group(2).split('\n')[0].strip()
            if correct_text.endswith('.'):
                correct_text = correct_text[:-1].strip()
                
        # Parse instruction
        first_opt_pos = re.search(r"\b(?:[a-d1-4])\)", q_body_and_opts)
        # Skip the very first "N)" which is the question number itself
        # The question text starts after "N) "
        q_start = q_body_and_opts.find(")") + 1
        q_body_only = q_body_and_opts[q_start:]
        
        first_opt_pos = re.search(r"\b(?:[a-d1-4])\)", q_body_only)
        if first_opt_pos:
            inst = q_body_only[:first_opt_pos.start()].strip()
        else:
            inst = q_body_only.strip()
            
        questions[q_num] = {
            'instruction': inst,
            'options': opts,
            'correct_opt': correct_opt,
            'correct_text': correct_text
        }
        
    return questions

mismatches = []

def normalize_val(s):
    if not s:
        return ""
    # strip LaTeX
    s = s.replace('\\$', '').replace('$', '').replace('{', '').replace('}', '')
    s = s.replace('\\times', '×').replace('\\div', '÷').replace(':', '÷').replace('\\sqrt', '√').replace('\\\\times', '×').replace('\\\\div', '÷')
    s = s.replace('[', '').replace(']', '')
    s = s.replace('^', '')
    s = "".join(s.split()).lower()
    return s

for ex in dart_exercises:
    ex_id = ex['id']
    pdf_block = mapping.get(ex_id, "")
    if not pdf_block:
        continue
        
    pdf_questions = parse_questions_strictly(pdf_block)
    
    for d_step in ex['steps']:
        step_num_match = re.search(r"_s(\d+)$", d_step['id'])
        if not step_num_match:
            continue
        step_num = step_num_match.group(1)
        
        if step_num not in pdf_questions:
            continue
            
        pdf_q = pdf_questions[step_num]
        
        # We only check multiple choice questions (i.e. those with options in Dart)
        if not d_step['options'] and not pdf_q['options']:
            continue
            
        # Verify options
        norm_d_opts = sorted([normalize_val(o) for o in d_step['options']])
        norm_p_opts = sorted([normalize_val(o) for o in pdf_q['options']])
        
        opts_differ = False
        if len(norm_d_opts) != len(norm_p_opts):
            opts_differ = True
        else:
            for d_opt in norm_d_opts:
                if not any(d_opt == p_opt or d_opt in p_opt or p_opt in d_opt for p_opt in norm_p_opts):
                    opts_differ = True
                    break
                    
        # Verify correct answer
        norm_d_correct = normalize_val(d_step['correctAnswer'])
        norm_p_correct = normalize_val(pdf_q['correct_text'])
        
        correct_differs = False
        if norm_d_correct != norm_p_correct:
            if norm_d_correct not in norm_p_correct and norm_p_correct not in norm_d_correct:
                correct_differs = True
                
        if opts_differ or correct_differs:
            mismatches.append({
                'ex_id': ex_id,
                'step_id': d_step['id'],
                'step_num': step_num,
                'dart_instruction': d_step['instruction'],
                'pdf_instruction': pdf_q['instruction'],
                'dart_options': d_step['options'],
                'pdf_options': pdf_q['options'],
                'dart_correct': d_step['correctAnswer'],
                'pdf_correct': pdf_q['correct_text'],
                'pdf_correct_opt': pdf_q['correct_opt']
            })

with open('scratch/sequential_mismatches.json', 'w', encoding='utf-8') as f:
    json.dump(mismatches, f, indent=2, ensure_ascii=False)

print(f"Found {len(mismatches)} strictly aligned mismatches. Saved to scratch/sequential_mismatches.json")
