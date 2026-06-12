import re
import json

def run():
    repo_path = r"lib/data/repositories/exercise_repository.dart"
    audit_report_path = r"scratch/audit_report.txt"

    with open(repo_path, "r", encoding="utf-8") as f:
        repo_content = f.read()

    # Step 1: Parse audit_report.txt for step IDs that have | in their PDF equations
    new_line_steps = set()
    with open(audit_report_path, "r", encoding="utf-8") as f:
        for line in f:
            if "equations:" in line:
                # Example:   hard_3_s11: Dart Override='8 + 3 * 3 / 1' vs PDF Step 11 equations: '= 2 3 + 3 × 3 ÷ 1 | = 8+'
                match = re.search(r'^\s*([a-zA-Z0-9_]+):.*equations:\s*\'(.*)\'', line)
                if match:
                    step_id = match.group(1)
                    eqs = match.group(2)
                    if '|' in eqs:
                        new_line_steps.add(step_id)

    print(f"Parsed {len(new_line_steps)} step IDs starting new lines from audit report:")
    print(sorted(list(new_line_steps)))

    # Step 2: Shift the overrides of hard_3 back by 1 step
    # We want:
    # hard_3_s3 gets hard_3_s4's current override (2 ^ 3 +)
    # hard_3_s4 gets hard_3_s5's current override (2 ^ 3 + 3 * ()
    # hard_3_s5 gets hard_3_s6's current override (2 ^ 3 + 3 * ()
    # hard_3_s6 gets hard_3_s7's current override (2 ^ 3 + 3 * 3 / ()
    # hard_3_s7 gets hard_3_s8's current override (2 ^ 3 + 3 * 3 / ()
    # hard_3_s8 gets hard_3_s9's current override (2 ^ 3 + 3 * 3 / 1)
    # hard_3_s9 gets hard_3_s10's current override (2 ^ 3 + 3 * 3 / 1)
    # hard_3_s10 gets hard_3_s11's current override (8 + 3 * 3 / 1)
    # hard_3_s11 gets hard_3_s12's current override (8 + 3 * 3 / 1)
    # hard_3_s12 gets hard_3_s13's current override (8 + 9 / 1)
    # hard_3_s13 gets hard_3_s14's current override (8 + 9 / 1)
    # hard_3_s14 gets hard_3_s15's current override (8 + 9)
    # hard_3_s15 gets hard_3_s16's current override (17)
    # hard_3_s16 gets '17' (same as step 15)

    hard_3_shifted = {
        'hard_3_s3': "expressionOverride: '2 ^ 3 +',",
        'hard_3_s4': "expressionOverride: '2 ^ 3 + 3 * (',",
        'hard_3_s5': "expressionOverride: '2 ^ 3 + 3 * (',",
        'hard_3_s6': "expressionOverride: '2 ^ 3 + 3 * 3 / (',",
        'hard_3_s7': "expressionOverride: '2 ^ 3 + 3 * 3 / (',",
        'hard_3_s8': "expressionOverride: '2 ^ 3 + 3 * 3 / 1',",
        'hard_3_s9': "expressionOverride: '2 ^ 3 + 3 * 3 / 1',",
        'hard_3_s10': "expressionOverride: '8 + 3 * 3 / 1',",
        'hard_3_s11': "expressionOverride: '8 + 3 * 3 / 1',",
        'hard_3_s12': "expressionOverride: '8 + 9 / 1',",
        'hard_3_s13': "expressionOverride: '8 + 9 / 1',",
        'hard_3_s14': "expressionOverride: '8 + 9',",
        'hard_3_s15': "expressionOverride: '17',",
        'hard_3_s16': "expressionOverride: '17',",
    }

    # Also, hard_3_s4 and hard_3_s11 should start a new line!
    # (Since we shifted, hard_3_s4 starts on the new line = 2^3 + 3 * (,
    # and hard_3_s11 starts on the new line = 8 + 3 * 3 / 1)
    # Wait, does hard_3_s4 start a new line?
    # Yes, hard_3_s4 shows `= 2^3 + 3 * (` which is on Line 2!
    # Wait! In Step 4 (hard_3_s4), we show `= 2^3 + 3 * (`.
    # But wait, Step 3 (hard_3_s3) shows `= 2^3 +` which was already on Line 2!
    # So does Step 4 start a new line? No! It stays on Line 2!
    # The step that actually started Line 2 was Step 3 (which now has override `2 ^ 3 +`).
    # Wait! If Step 3 has override `2 ^ 3 +`, then when the user is at Step 4, workingLine is `2 ^ 3 +`.
    # So Step 4 is the first step where we show the second line `= 2^3 +`.
    # So Step 4 is indeed the step where we transition to a new line!
    # So `hard_3_s4` has `startsNewLine = true`.
    # And Step 11 (`hard_3_s11`) shows `= 8 + 3 * 3 / 1` (Line 3).
    # Since Step 10 has override `8 + 3 * 3 / 1`, when they transition to Step 11, we push Step 10's working line to history, and show `= 8 + 3 * 3 / 1`.
    # So `hard_3_s11` has `startsNewLine = true`.
    # This is exactly correct!
    new_line_steps.add('hard_3_s4')
    new_line_steps.add('hard_3_s11')

    # Step 3: Parse and modify step entities in exercise_repository.dart
    # Let's find each StepEntity block.
    # We can split the repository by 'StepEntity(' and reconstruct it.
    parts = repo_content.split('StepEntity(')
    new_parts = [parts[0]]

    for part in parts[1:]:
        # Find step ID
        match = re.search(r"id:\s*'([a-zA-Z0-9_]+)'", part)
        if match:
            step_id = match.group(1)
            
            # Check if this step needs startsNewLine: true
            starts_new_line = step_id in new_line_steps
            
            # Check if this step is hard_3 and needs shifted expressionOverride
            has_hard3_override = step_id in hard_3_shifted
            
            # Let's perform replacements
            modified_part = part
            
            if starts_new_line:
                # Add startsNewLine: true, inside the StepEntity constructor
                modified_part = modified_part.replace(
                    f"id: '{step_id}',",
                    f"id: '{step_id}',\n          startsNewLine: true,"
                )
                
            if has_hard3_override:
                # Replace or add expressionOverride
                new_override_line = f"\n          {hard_3_shifted[step_id]}"
                if "expressionOverride:" in modified_part:
                    # Replace existing expressionOverride
                    modified_part = re.sub(
                        r"expressionOverride:\s*'[^']*',",
                        hard_3_shifted[step_id],
                        modified_part
                    )
                else:
                    # Insert expressionOverride after id
                    modified_part = modified_part.replace(
                        f"id: '{step_id}',",
                        f"id: '{step_id}',{new_override_line}"
                    )
                    
            new_parts.append(modified_part)
        else:
            new_parts.append(part)

    new_content = 'StepEntity('.join(new_parts)

    with open(repo_path, "w", encoding="utf-8") as f:
        f.write(new_content)

    print("Successfully updated exercise_repository.dart with shifted overrides and startsNewLine properties!")

if __name__ == "__main__":
    run()
