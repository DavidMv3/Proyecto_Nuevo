import re
import json

def extract_exercises(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    exercises_raw = content.split('ExerciseEntity(')[1:]
    
    exercises = []
    for raw in exercises_raw:
        # Extract ID
        id_match = re.search(r"id:\s*'([^']+)'", raw)
        if not id_match:
            continue
        ex_id = id_match.group(1)
        
        title_match = re.search(r"title:\s*'([^']+)'", raw)
        title = title_match.group(1) if title_match else ""
        
        expr_match = re.search(r"baseExpression:\s*'([^']+)'", raw)
        expr = expr_match.group(1) if expr_match else ""
        
        # Extract steps
        steps_start = raw.find('steps: [')
        if steps_start == -1:
            continue
        
        bracket_count = 1
        i = steps_start + len('steps: [')
        steps_content = ""
        while i < len(raw) and bracket_count > 0:
            if raw[i] == '[':
                bracket_count += 1
            elif raw[i] == ']':
                bracket_count -= 1
            if bracket_count > 0:
                steps_content += raw[i]
            i += 1
            
        step_blocks = steps_content.split('StepEntity(')[1:]
        steps = []
        for s_raw in step_blocks:
            s_id_match = re.search(r"id:\s*'([^']+)'", s_raw)
            if not s_id_match:
                continue
            s_id = s_id_match.group(1)
            
            s_inst_match = re.search(r"instruction:\s*'([^']+)'", s_raw)
            s_inst = s_inst_match.group(1) if s_inst_match else ""
            
            # Find options
            opts = []
            opts_start = s_raw.find('options: [')
            if opts_start != -1:
                b_count = 1
                j = opts_start + len('options: [')
                opts_content = ""
                while j < len(s_raw) and b_count > 0:
                    if s_raw[j] == '[':
                        b_count += 1
                    elif s_raw[j] == ']':
                        b_count -= 1
                    if b_count > 0:
                        opts_content += s_raw[j]
                    j += 1
                
                current_opt = ""
                in_single_quote = False
                in_double_quote = False
                nested_b = 0
                for char in opts_content:
                    if char == "'" and not in_double_quote:
                        in_single_quote = not in_single_quote
                        current_opt += char
                    elif char == '"' and not in_single_quote:
                        in_double_quote = not in_double_quote
                        current_opt += char
                    elif char == '[' and not in_single_quote and not in_double_quote:
                        nested_b += 1
                        current_opt += char
                    elif char == ']' and not in_single_quote and not in_double_quote:
                        nested_b -= 1
                        current_opt += char
                    elif char == ',' and not in_single_quote and not in_double_quote and nested_b == 0:
                        opts.append(current_opt.strip().strip("'").strip('"'))
                        current_opt = ""
                    else:
                        current_opt += char
                if current_opt:
                    opts.append(current_opt.strip().strip("'").strip('"'))
            
            opts = [o.strip("'").strip('"') for o in opts if o.strip()]
            
            correct_match = re.search(r"correctAnswer:\s*'([^']+)'", s_raw)
            correct = correct_match.group(1) if correct_match else ""
            
            feedback_match = re.search(r"feedbackError:\s*'([^']+)'", s_raw)
            feedback = feedback_match.group(1) if feedback_match else ""
            
            override_match = re.search(r"expressionOverride:\s*'([^']+)'", s_raw)
            override = override_match.group(1) if override_match else None
            
            starts_line_match = re.search(r"startsNewLine:\s*([a-zA-Z]+)", s_raw)
            starts_line = starts_line_match.group(1) == 'true' if starts_line_match else False
            
            steps.append({
                'id': s_id,
                'instruction': s_inst,
                'options': opts,
                'correctAnswer': correct,
                'feedbackError': feedback,
                'expressionOverride': override,
                'startsNewLine': starts_line
            })
            
        exercises.append({
            'id': ex_id,
            'title': title,
            'baseExpression': expr,
            'steps': steps
        })
        
    return exercises

exercises = extract_exercises('lib/data/repositories/exercise_repository.dart')
with open('extracted_exercises.json', 'w', encoding='utf-8') as f:
    json.dump(exercises, f, indent=2, ensure_ascii=False)

print(f"Extracted {len(exercises)} exercises.")
