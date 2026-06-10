import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Find all ExerciseEntity blocks
exercises = re.split(r'ExerciseEntity\(', content)

out = []

for ex_idx, ex_text in enumerate(exercises[1:], 1):
    ex_id_match = re.search(r'id:\s*\'([^\']+)\'', ex_text)
    if not ex_id_match:
        continue
    ex_id = ex_id_match.group(1)
    
    # Find all StepEntity blocks
    steps = re.split(r'StepEntity\(', ex_text)
    for step_idx, step_text in enumerate(steps[1:], 1):
        step_id_match = re.search(r'id:\s*\'([^\']+)\'', step_text)
        if not step_id_match:
            continue
        step_id = step_id_match.group(1)
        
        # Helper to extract string values for fields
        def get_field(field_name):
            # Matches field: 'value' or field: "value" or field: [values]
            m = re.search(r'' + field_name + r':\s*(?:\'([^\']*)\'|"([^"]*)"|\[(.*?)\])', step_text, re.DOTALL)
            if m:
                if m.group(1) is not None:
                    return m.group(1)
                elif m.group(2) is not None:
                    return m.group(2)
                elif m.group(3) is not None:
                    # Array of strings
                    opts_raw = m.group(3)
                    opts = re.findall(r'(?:\'([^\']*)\'|"([^"]*)")', opts_raw)
                    return [o[0] if o[0] else o[1] for o in opts]
            return None
        
        inst = get_field('instruction')
        opts = get_field('options')
        ans = get_field('correctAnswer')
        hint = get_field('algorithmHint')
        feed = get_field('feedbackError')
        
        out.append({
            "step_id": step_id,
            "instruction": inst,
            "options": opts,
            "correctAnswer": ans,
            "algorithmHint": hint,
            "feedbackError": feed
        })

with open("scratch/math_strings.txt", "w", encoding="utf-8") as f_out:
    for item in out:
        f_out.write(f"ID: {item['step_id']}\n")
        f_out.write(f"  Instruction: {item['instruction']}\n")
        if item['options']:
            f_out.write(f"  Options: {item['options']}\n")
        if item['correctAnswer']:
            f_out.write(f"  CorrectAnswer: {item['correctAnswer']}\n")
        if item['algorithmHint']:
            f_out.write(f"  Hint: {item['algorithmHint']}\n")
        if item['feedbackError']:
            f_out.write(f"  Feedback: {item['feedbackError']}\n")
        f_out.write("-" * 50 + "\n")

print(f"Successfully wrote {len(out)} steps' strings to scratch/math_strings.txt")
