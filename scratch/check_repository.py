import re
import sys

def main():
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass
    path = r"scratch/exercise_repository_backup.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    print(f"Total exercises in backup: {len(exercises) - 1}")
    for ex_idx, ex_text in enumerate(exercises[1:], 1):
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
        ex_id = ex_id_match.group(1) if ex_id_match else f"unknown_{ex_idx}"
        base_match = re.search(r'baseExpression:\s*\'([^\']+)\'', ex_text)
        base_expr = base_match.group(1) if base_match else "unknown"
        
        steps = re.split(r'StepEntity\(', ex_text)
        print(f"- {ex_id}: {len(steps)-1} steps | Base: {base_expr}")

if __name__ == "__main__":
    main()

