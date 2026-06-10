import re

def main():
    path = r"lib/data/repositories/exercise_repository.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    exercises = re.split(r'ExerciseEntity\(', content)
    for ex_idx, ex_text in enumerate(exercises[1:], 1):
        ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
        ex_id = ex_id_match.group(1) if ex_id_match else f"unknown_{ex_idx}"
        base_match = re.search(r'baseExpression:\s*\'([^\']+)\'', ex_text)
        base_expr = base_match.group(1) if base_match else "unknown"
        
        print(f"\n=========================================\nEXERCISE: {ex_id} | Base: {base_expr}")
        
        steps = re.split(r'StepEntity\(', ex_text)
        for s_idx, s_text in enumerate(steps[1:], 1):
            s_id_match = re.search(r'id:\s*\'([^\']+)\'', s_text)
            s_id = s_id_match.group(1) if s_id_match else f"s{s_idx}"
            inst_match = re.search(r'instruction:\s*\'([^\']+)\'', s_text)
            inst = inst_match.group(1) if inst_match else "no instruction"
            inst_short = inst.replace('\n', ' ')[:60]
            
            override_match = re.search(r'expressionOverride:\s*\'([^\']+)\'', s_text)
            override = override_match.group(1) if override_match else None
            
            opt_match = re.search(r'options:\s*\[([^\]]*)\]', s_text)
            has_opts = "MC" if opt_match else "Interactive"
            
            print(f"  Step {s_idx} ({s_id}) [{has_opts}]: {inst_short} -> Override: {override}")

if __name__ == "__main__":
    main()
