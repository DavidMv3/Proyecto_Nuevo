import json
import re

with open("assets/exercises.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

for ex in exercises:
    if ex["exercise_id"] == "medium_4":
        print("medium_4 steps in JSON:")
        for step in ex["workflow_steps"]:
            print(f"Step {step['step_index']}: {step.get('display_append', 'NONE')}")

with open("lib/data/repositories/exercise_repository.dart", "r", encoding="utf-8") as f:
    dart_content = f.read()

# Let's find "id: 'medium_4'" and read until the end of the steps list
start_idx = dart_content.find("id: 'medium_4'")
if start_idx != -1:
    print("\nmedium_4 steps in Dart Repository:")
    # Find the matching closing bracket or list end
    sub = dart_content[start_idx:start_idx+10000]
    steps_block = re.findall(r"StepEntity\(.*?\),?", sub, re.DOTALL)
    for i, step in enumerate(steps_block, 1):
        override = re.search(r"expressionOverride:\s*'(.*?)'", step)
        override_val = override.group(1) if override else "NONE"
        inst = re.search(r"instruction:\s*'(.*?)'", step)
        inst_val = inst.group(1) if inst else "NONE"
        print(f"Step {i}: override='{override_val}' | instruction='{inst_val[:40]}'")
else:
    print("\nCould not find medium_4 in Dart")
