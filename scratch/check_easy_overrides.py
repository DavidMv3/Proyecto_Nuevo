import re

def main():
    path = "lib/data/repositories/exercise_repository.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    
    for ex in exercises[1:]:
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex)
        if not ex_id_match:
            continue
        ex_id = ex_id_match.group(1)
        
        # We only care about easy exercises
        if not ex_id.startswith("easy_"):
            continue
            
        base_expr_match = re.search(r'baseExpression:\s*\'([^\']+)\'', ex)
        base_expr = base_expr_match.group(1) if base_expr_match else ""
        
        steps = re.split(r'StepEntity\(', ex)
        for s_idx, step_text in enumerate(steps[1:], 1):
            override_match = re.search(r'expressionOverride:\s*\'([^\']+)\'', step_text)
            if override_match:
                override = override_match.group(1)
                # Find all numbers in override
                numbers = re.findall(r'\d+', override)
                base_numbers = re.findall(r'\d+', base_expr)
                for num in numbers:
                    # Allow numbers that are correct intermediate results
                    # (e.g. 20, 2, 18 in easy_1, 15, 33 in easy_2, etc.)
                    # But print them so we can manually review if they make sense
                    print(f"{ex_id}_s{s_idx} | Base: {base_expr} | Override: {override} | Num in override: {num}")

if __name__ == "__main__":
    main()
