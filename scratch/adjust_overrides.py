import re

def clean_override(val):
    if not val:
        return None
    val = val.strip().strip("'").strip('"')
    if val.startswith('='):
        val = val[1:].strip()
    return val

def main():
    repo_path = "lib/data/repositories/exercise_repository.dart"
    with open(repo_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Split content by ExerciseEntity( to parse each exercise separately
    exercises = re.split(r'(ExerciseEntity\()', content)
    
    # We will reconstruct the content
    new_content_parts = [exercises[0]]
    
    for i in range(1, len(exercises), 2):
        ex_header = exercises[i]
        ex_body = exercises[i+1]
        
        # Split ex_body by StepEntity(
        steps = re.split(r'(StepEntity\()', ex_body)
        
        # Let's parse each step
        step_list = []
        # steps[0] is the baseExpression and other fields of ExerciseEntity
        for j in range(1, len(steps), 2):
            step_header = steps[j]
            step_body = steps[j+1]
            
            # Extract step ID
            id_match = re.search(r'id:\s*\'([^\']+)\'', step_body)
            step_id = id_match.group(1) if id_match else f"unknown_s{j}"
            
            # Extract expressionOverride
            override_match = re.search(r'expressionOverride:\s*[\'"]([^\'"]*)[\'"],?(.*?)\n', step_body)
            original_override = override_match.group(1) if override_match else None
            comment = override_match.group(2).strip() if (override_match and '//' in override_match.group(2)) else None
            
            # Extract correctAnswer
            correct_ans_match = re.search(r'correctAnswer:\s*[\'"]([^\'"]*)[\'"]', step_body)
            correct_answer = correct_ans_match.group(1) if correct_ans_match else None
            
            step_list.append({
                'id': step_id,
                'header': step_header,
                'body': step_body,
                'original_override': original_override,
                'comment': comment,
                'correct_answer': correct_answer,
                'index_in_steps': j
            })
            
        # Compute new overrides
        N = len(step_list)
        for idx in range(N):
            step = step_list[idx]
            if idx == 0:
                # Step 1 (s1): no override
                step['new_override'] = None
                step['new_comment'] = None
            elif idx < N - 1:
                # Step 2 to N-1: gets override of step idx + 1
                next_step = step_list[idx + 1]
                step['new_override'] = clean_override(next_step['original_override'])
                # Use comment of next step if present
                step['new_comment'] = next_step['comment']
            else:
                # Step N (sN): gets correctAnswer of step N
                step['new_override'] = clean_override(step['correct_answer'])
                step['new_comment'] = "Resultado final"
                
        # Reconstruct the steps body
        new_ex_body_parts = [steps[0]]
        for j in range(len(step_list)):
            step = step_list[j]
            body = step['body']
            
            # Remove existing expressionOverride if any (make sure to match trailing comma and optional comments/spaces)
            body = re.sub(r'\s*expressionOverride:\s*[\'"][^\'"]*[\'"],?(.*?)\n', '\n', body)
            
            new_override_val = step['new_override']
            new_comment_val = step['new_comment']
            
            if new_override_val is not None:
                # Clean comment value: remove leading slashes and strip
                clean_comment = ""
                if new_comment_val:
                    c = new_comment_val.strip()
                    if c.startswith('//'):
                        c = c[2:].strip()
                    clean_comment = f" // {c}"
                
                # Format the override line
                override_line = f"\n          expressionOverride: '{new_override_val}',{clean_comment}\n"
                
                # Insert it right after the id line
                body = re.sub(r'(id:\s*\'[^\']+\',)', r'\1' + override_line, body)
                
            new_ex_body_parts.append(step['header'])
            new_ex_body_parts.append(body)
            
        new_content_parts.append(ex_header)
        new_content_parts.append("".join(new_ex_body_parts))
        
    final_content = "".join(new_content_parts)
    
    with open(repo_path, "w", encoding="utf-8") as f:
        f.write(final_content)
        
    print("Done adjusting overrides!")

if __name__ == '__main__':
    main()
