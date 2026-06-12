import re

def count_steps_in_file(repo_path):
    with open(repo_path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    results = {}
    for ex_idx, ex_text in enumerate(exercises[1:], 1):
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
        ex_id = ex_id_match.group(1) if ex_id_match else f"unknown_{ex_idx}"
        
        steps = re.split(r'StepEntity\(', ex_text)
        results[ex_id] = len(steps) - 1
    return results

def main():
    backup_steps = count_steps_in_file("scratch/exercise_repository_backup.dart")
    current_steps = count_steps_in_file("lib/data/repositories/exercise_repository.dart")
    
    print("Exercise | Backup Steps | Current Steps")
    print("-" * 45)
    all_keys = sorted(list(set(backup_steps.keys()) | set(current_steps.keys())))
    for key in all_keys:
        b_val = backup_steps.get(key, 0)
        c_val = current_steps.get(key, 0)
        if b_val != c_val:
            print(f"{key:10} | {b_val:12} | {c_val:13} <--- DIFFERENCE!")
        else:
            print(f"{key:10} | {b_val:12} | {c_val:13}")

if __name__ == "__main__":
    main()
