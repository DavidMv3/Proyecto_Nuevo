import re

with open("lib/data/repositories/exercise_repository.dart", "r", encoding="utf-8") as f:
    content = f.read()

start = content.find("id: 'medium_4'")
end = content.find("id: 'medium_5'")
if start == -1 or end == -1:
    print("Could not find medium_4 or medium_5")
    exit(1)

block = content[start:end]

# Find each StepEntity block. Since step entities are nested, let's split by StepEntity(
steps = block.split("StepEntity(")
for idx, step in enumerate(steps[1:], 1):
    step_id_match = re.search(r"id:\s*'([^']+)'", step)
    override_match = re.search(r"expressionOverride:\s*'([^']+)'", step)
    
    step_id = step_id_match.group(1) if step_id_match else f"unknown_{idx}"
    override = override_match.group(1) if override_match else "NONE"
    
    print(f"Step {idx} ({step_id}): override='{override}'")
