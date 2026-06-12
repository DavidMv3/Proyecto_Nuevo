import json

def get_expression_for_step(steps, base_expression, step_index):
    for i in range(step_index - 1, -1, -1):
        override = steps[i].get("display_append")
        if override:
            return override
    return base_expression

def simulate():
    with open("assets/exercises.json", "r", encoding="utf-8") as f:
        exercises = json.load(f)
    
    ex = next(item for item in exercises if item["exercise_id"] == "hard_3")
    base_expr = ex["initial_expression"]
    steps = ex["workflow_steps"]
    
    print(f"Base Expression: {base_expr}\n")
    
    # Initial state
    current_step_index = 0
    step = steps[current_step_index]
    initial_expr = get_expression_for_step(steps, base_expr, current_step_index)
    working_line = initial_expr
    equation_history = [base_expr]
    step_completed = False
    
    def print_state(label):
        print(f"--- {label} (Step {current_step_index + 1}: {steps[current_step_index].get('instruction') or steps[current_step_index].get('question')}) ---")
        print(f"  workingLine: '{working_line}'")
        print(f"  equationHistory: {equation_history}")
        
        # Simulate _EquationHistory filteredExpressions
        raw_expressions = []
        for h in equation_history:
            if h.strip():
                raw_expressions.add(h) if hasattr(raw_expressions, 'add') else raw_expressions.append(h)
        
        active_line = None
        if working_line and working_line.strip():
            active_line = working_line
        
        if active_line:
            clean_active = active_line.replace(' ', '').replace('____', '').replace('$', '')
            last_clean = raw_expressions[-1].replace(' ', '').replace('$', '') if raw_expressions else ''
            if not raw_expressions or last_clean != clean_active:
                raw_expressions.append(active_line)
                
        # Filter prefixes
        def is_prefix(a, b):
            cleanA = a.replace(' ', '').replace('____', '').replace('?', '')
            cleanB = b.replace(' ', '').replace('____', '').replace('?', '')
            if not cleanA:
                return False
            return cleanB.startswith(cleanA)
            
        filtered = []
        if raw_expressions:
            filtered.append(raw_expressions[0])
            for i in range(1, len(raw_expressions)):
                current = raw_expressions[i]
                is_prefix_of_later = False
                for j in range(i + 1, len(raw_expressions)):
                    if is_prefix(current, raw_expressions[j]):
                        is_prefix_of_later = True
                        break
                if not is_prefix_of_later:
                    filtered.append(current)
                    
        print("  Notebook Lines displayed in UI:")
        for line in filtered:
            is_base = line.replace(' ', '') == base_expr.replace(' ', '')
            prefix = "" if is_base else "= "
            suffix = " =" if is_base else ""
            print(f"    {prefix}{line}{suffix}")
        print()

    # Step 1 (operator_selection)
    print_state("BEFORE ANSWERING STEP 1")
    # Answer correct
    current_working = working_line
    new_working = steps[current_step_index].get("display_append") or current_working
    if new_working != current_working:
        lineToPush = current_working or base_expr
        is_same = equation_history and equation_history[-1].replace(' ', '') == lineToPush.replace(' ', '')
        if not is_same and '____' not in lineToPush:
            equation_history.append(lineToPush)
    working_line = new_working
    step_completed = True
    print_state("AFTER ANSWERING STEP 1")
    
    # Go to step 2
    current_step_index += 1
    next_expr = get_expression_for_step(steps, base_expr, current_step_index)
    current_working_line = working_line
    if current_working_line:
        clean_working = current_working_line.replace(' ', '').replace('$', '')
        is_same = equation_history and equation_history[-1].replace(' ', '').replace('$', '') == clean_working
        if not is_same:
            equation_history.append(current_working_line)
    working_line = next_expr
    step_completed = False
    
    # Step 2 (multiple_choice)
    print_state("BEFORE ANSWERING STEP 2")
    # Answer correct
    current_working = working_line
    new_working = steps[current_step_index].get("display_append") or current_working
    if new_working != current_working:
        lineToPush = current_working or base_expr
        is_same = equation_history and equation_history[-1].replace(' ', '') == lineToPush.replace(' ', '')
        if not is_same and '____' not in lineToPush:
            equation_history.append(lineToPush)
    working_line = new_working
    step_completed = True
    print_state("AFTER ANSWERING STEP 2")
    
    # Go to step 3
    current_step_index += 1
    next_expr = get_expression_for_step(steps, base_expr, current_step_index)
    current_working_line = working_line
    if current_working_line:
        clean_working = current_working_line.replace(' ', '').replace('$', '')
        is_same = equation_history and equation_history[-1].replace(' ', '').replace('$', '') == clean_working
        if not is_same:
            equation_history.append(current_working_line)
    working_line = next_expr
    step_completed = False
    
    # Step 3 (evaluation_step - "En el primer bloque...")
    print_state("BEFORE ANSWERING STEP 3")
    # Answer correct
    current_working = working_line
    new_working = steps[current_step_index].get("display_append") or current_working
    if new_working != current_working:
        lineToPush = current_working or base_expr
        is_same = equation_history and equation_history[-1].replace(' ', '') == lineToPush.replace(' ', '')
        if not is_same and '____' not in lineToPush:
            equation_history.append(lineToPush)
    working_line = new_working
    step_completed = True
    print_state("AFTER ANSWERING STEP 3")
    
    # Go to step 4
    current_step_index += 1
    next_expr = get_expression_for_step(steps, base_expr, current_step_index)
    current_working_line = working_line
    if current_working_line:
        clean_working = current_working_line.replace(' ', '').replace('$', '')
        is_same = equation_history and equation_history[-1].replace(' ', '').replace('$', '') == clean_working
        if not is_same:
            equation_history.append(current_working_line)
    working_line = next_expr
    step_completed = False
    
    # Step 4 (evaluation_step - "Al aplicar la propiedad...")
    print_state("BEFORE ANSWERING STEP 4")
    # Answer correct
    current_working = working_line
    new_working = steps[current_step_index].get("display_append") or current_working
    if new_working != current_working:
        lineToPush = current_working or base_expr
        is_same = equation_history and equation_history[-1].replace(' ', '') == lineToPush.replace(' ', '')
        if not is_same and '____' not in lineToPush:
            equation_history.append(lineToPush)
    working_line = new_working
    step_completed = True
    print_state("AFTER ANSWERING STEP 4")
    
    # Go to step 5
    current_step_index += 1
    next_expr = get_expression_for_step(steps, base_expr, current_step_index)
    current_working_line = working_line
    if current_working_line:
        clean_working = current_working_line.replace(' ', '').replace('$', '')
        is_same = equation_history and equation_history[-1].replace(' ', '').replace('$', '') == clean_working
        if not is_same:
            equation_history.append(current_working_line)
    working_line = next_expr
    step_completed = False
    
    # Step 5 (evaluation_step - "En el segundo bloque...")
    print_state("BEFORE ANSWERING STEP 5")

if __name__ == "__main__":
    simulate()
