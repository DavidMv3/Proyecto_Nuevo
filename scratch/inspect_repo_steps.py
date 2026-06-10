import re

def main():
    path = r"lib/data/repositories/exercise_repository.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    print(f"Total exercises found: {len(exercises) - 1}")
    for ex_idx, ex_text in enumerate(exercises[1:], 1):
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
        ex_title_match = re.search(r'title:\s*\'([^\']+)\'', ex_text)
        ex_id = ex_id_match.group(1) if ex_id_match else f"unknown_{ex_idx}"
        ex_title = ex_title_match.group(1) if ex_title_match else "Unknown"
        
        steps = re.split(r'StepEntity\(', ex_text)
        step_count = len(steps) - 1
        print(f"- {ex_id} ({ex_title}): {step_count} steps")

if __name__ == "__main__":
    main()
