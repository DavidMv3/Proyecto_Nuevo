import re

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

exercises = re.split(r'ExerciseEntity\(', content)

for ex_idx, ex_text in enumerate(exercises[1:], 1):
    ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
    if not ex_id_match:
        continue
    ex_id = ex_id_match.group(1)
    
    steps = re.split(r'StepEntity\(', ex_text)
    for step_idx, step_text in enumerate(steps[1:], 1):
        step_id_match = re.search(r'id:\s*\'([^\']+)\'', step_text)
        if not step_id_match:
            continue
        step_id = step_id_match.group(1)
        
        # Get options
        m = re.search(r'options:\s*\[(.*?)\]', step_text)
        if m:
            opts_raw = m.group(1)
            opts = [o.strip().strip("'").strip('"') for o in opts_raw.split(',') if o.strip()]
            
            # Check if all options are 2-digit numbers
            all_two_digits = len(opts) > 0 and all(re.match(r'^\d{2}$', o) for o in opts)
            if all_two_digits:
                # check if they share the first digit (common base)
                first_digits = {o[0] for o in opts}
                if len(first_digits) == 1:
                    base = list(first_digits)[0]
                    exps = [o[1] for o in opts]
                    print(f"FOUND FLAT POWERS: {ex_id} -> {step_id}: options={opts}, base={base}, exponents={exps}")
