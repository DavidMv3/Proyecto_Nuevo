import re

def main():
    repo_path = r"lib/data/repositories/exercise_repository.dart"
    import sys
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass
    with open(repo_path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    
    for ex_idx, ex_text in enumerate(exercises[1:], 1):
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
        ex_id = ex_id_match.group(1) if ex_id_match else f"unknown_{ex_idx}"
        
        steps = re.split(r'StepEntity\(', ex_text)
        
        overrides = []
        for step_idx, step_text in enumerate(steps[1:], 1):
            step_id_match = re.search(r'id:\s*\'([^\']+)\'', step_text)
            step_id = step_id_match.group(1) if step_id_match else f"{ex_id}_s{step_idx}"
            
            override_match = re.search(r'expressionOverride:\s*\'([^\']+)\'', step_text)
            override = override_match.group(1) if override_match else None
            if override:
                overrides.append((step_id, override))
                
        if overrides:
            print(f"\nExercise {ex_id}:")
            for step_id, o in overrides:
                print(f"  {step_id}: {o}")

if __name__ == "__main__":
    main()
