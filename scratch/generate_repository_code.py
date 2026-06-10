import json
import re

# Load parsed ranges
with open("scratch/parsed_ranges.json", "r", encoding="utf-8") as f:
    exercises = json.load(f)

# Hardcode the correct overrides we traced
overrides_map = {
    # medium II
    ("medium", "II", 1): None,
    ("medium", "II", 2): None,
    ("medium", "II", 3): None,
    ("medium", "II", 4): "[ 2 ^ 5 - 20 ] + [ 6 + 3 ^ 2 ]",
    ("medium", "II", 5): None,
    ("medium", "II", 6): "[ 2 ^ 5 - 20 ] + [ 6 + 9 ]",
    ("medium", "II", 7): None,
    ("medium", "II", 8): "[ 32 - 20 ] + [ 6 + 9 ]",
    ("medium", "II", 9): "[ 32 - 20 ] + 15",
    ("medium", "II", 10): "12 + 15",
    ("medium", "II", 11): "27",

    # medium III
    ("medium", "III", 1): None,
    ("medium", "III", 2): None,
    ("medium", "III", 3): None,
    ("medium", "III", 4): "[ 3 ^ 2 + 7 ] - [ 7 + 2 ^ 3 ]",
    ("medium", "III", 5): None,
    ("medium", "III", 6): "[ 3 ^ 2 + 7 ] - [ 7 + 8 ]",
    ("medium", "III", 7): None,
    ("medium", "III", 8): "[ 9 + 7 ] - [ 7 + 8 ]",
    ("medium", "III", 9): "[ 9 + 7 ] - 15",
    ("medium", "III", 10): "16 - 15",
    ("medium", "III", 11): "1",

    # medium IV
    ("medium", "IV", 1): None,
    ("medium", "IV", 2): None,
    ("medium", "IV", 3): None,
    ("medium", "IV", 4): "[ 6 ^ 2 - 30 ] + [ 18 / 3 + 10 ]",
    ("medium", "IV", 5): None,
    ("medium", "IV", 6): "[ 6 ^ 2 - 30 ] + [ 6 + 10 ]",
    ("medium", "IV", 7): None,
    ("medium", "IV", 8): "[ 36 - 30 ] + [ 6 + 10 ]",
    ("medium", "IV", 9): "[ 36 - 30 ] + 16",
    ("medium", "IV", 10): "6 + 16",
    ("medium", "IV", 11): "22",

    # medium V
    ("medium", "V", 1): None,
    ("medium", "V", 2): None,
    ("medium", "V", 3): None,
    ("medium", "V", 4): "[ ( 4 ) ^ 2 - 12 ] + [ 5 ^ 2 - 4 ]",
    ("medium", "V", 5): None,
    ("medium", "V", 6): "[ ( 4 ) ^ 2 - 12 ] + [ 25 - 4 ]",
    ("medium", "V", 7): None,
    ("medium", "V", 8): "[ 16 - 12 ] + [ 25 - 4 ]",
    ("medium", "V", 9): "[ 16 - 12 ] + 21",
    ("medium", "V", 10): "4 + 21",
    ("medium", "V", 11): "25",

    # medium VI
    ("medium", "VI", 1): None,
    ("medium", "VI", 2): None,
    ("medium", "VI", 3): None,
    ("medium", "VI", 4): "[ 2 ^ 6 - 50 / 5 ] + [ 9 * 2 - 15 ]",
    ("medium", "VI", 5): "[ 2 ^ 6 - 10 ] + [ 9 * 2 - 15 ]",
    ("medium", "VI", 6): None,
    ("medium", "VI", 7): "[ 2 ^ 6 - 10 ] + [ 18 - 15 ]",
    ("medium", "VI", 8): None,
    ("medium", "VI", 9): "[ 64 - 10 ] + [ 18 - 15 ]",
    ("medium", "VI", 10): "[ 64 - 10 ] + 3",
    ("medium", "VI", 11): "54 + 3",
    ("medium", "VI", 12): "57",

    # medium VII
    ("medium", "VII", 1): None,
    ("medium", "VII", 2): None,
    ("medium", "VII", 3): None,
    ("medium", "VII", 4): "[ 15 - 3 ^ 2 ] + [ 3 * 5 + 20 ]",
    ("medium", "VII", 5): None,
    ("medium", "VII", 6): "[ 15 - 3 ^ 2 ] + [ 15 + 20 ]",
    ("medium", "VII", 7): None,
    ("medium", "VII", 8): "[ 15 - 9 ] + [ 15 + 20 ]",
    ("medium", "VII", 9): "[ 15 - 9 ] + 35",
    ("medium", "VII", 10): "6 + 35",
    ("medium", "VII", 11): "41",

    # medium VIII
    ("medium", "VIII", 1): None,
    ("medium", "VIII", 2): None,
    ("medium", "VIII", 3): None,
    ("medium", "VIII", 4): "[ sqrt( 144 / 16 ) + 20 ] - [ 5 ^ 2 - 10 ]",
    ("medium", "VIII", 5): None,
    ("medium", "VIII", 6): "[ sqrt( 144 / 16 ) + 20 ] - [ 25 - 10 ]",
    ("medium", "VIII", 7): None,
    ("medium", "VIII", 8): "[ sqrt( 9 ) + 20 ] - [ 25 - 10 ]",
    ("medium", "VIII", 9): "[ sqrt( 9 ) + 20 ] - 15",
    ("medium", "VIII", 10): None,
    ("medium", "VIII", 11): "[ 3 + 20 ] - 15",
    ("medium", "VIII", 12): "23 - 15",
    ("medium", "VIII", 13): "8",

    # medium IX
    ("medium", "IX", 1): None,
    ("medium", "IX", 2): None,
    ("medium", "IX", 3): None,
    ("medium", "IX", 4): "[ root4( 81 ) + 4 ^ 2 ] - [ 30 / 5 - 3 ]",
    ("medium", "IX", 5): None,
    ("medium", "IX", 6): "[ root4( 81 ) + 16 ] - [ 30 / 5 - 3 ]",
    ("medium", "IX", 7): None,
    ("medium", "IX", 8): "[ root4( 81 ) + 16 ] - [ 6 - 3 ]",
    ("medium", "IX", 9): None,
    ("medium", "IX", 10): "[ 3 + 16 ] - [ 6 - 3 ]",
    ("medium", "IX", 11): "[ 3 + 16 ] - 3",
    ("medium", "IX", 12): "19 - 3",
    ("medium", "IX", 13): "16",

    # medium X
    ("medium", "X", 1): None,
    ("medium", "X", 2): None,
    ("medium", "X", 3): None,
    ("medium", "X", 4): "[ 6 ^ 2 + 2 ^ 4 ] - [ sqrt( 16 + 20 ) - 3 ]",
    ("medium", "X", 5): None,
    ("medium", "X", 6): "[ 6 ^ 2 + 16 ] - [ sqrt( 16 + 20 ) - 3 ]",
    ("medium", "X", 7): None,
    ("medium", "X", 8): "[ 6 ^ 2 + 16 ] - [ sqrt( 36 ) - 3 ]",
    ("medium", "X", 9): None,
    ("medium", "X", 10): "[ 36 + 16 ] - [ sqrt( 36 ) - 3 ]",
    ("medium", "X", 11): None,
    ("medium", "X", 12): "[ 36 + 16 ] - [ 6 - 3 ]",
    ("medium", "X", 13): "52 - [ 6 - 3 ]",
    ("medium", "X", 14): "52 - 3",
    ("medium", "X", 15): "49",

    # hard I
    ("hard", "I", 1): None,
    ("hard", "I", 2): None,
    ("hard", "I", 3): None,
    ("hard", "I", 4): "30 + sqrt( 4 + 5 ) - ( 2 * 3 - 1 )",
    ("hard", "I", 5): None,
    ("hard", "I", 6): "30 + sqrt( 4 + 5 ) - ( 6 - 1 )",
    ("hard", "I", 7): None,
    ("hard", "I", 8): "30 + sqrt( 9 ) - ( 6 - 1 )",
    ("hard", "I", 9): None,
    ("hard", "I", 10): "30 + 3 - ( 6 - 1 )",
    ("hard", "I", 11): "30 + 3 - 5",
    ("hard", "I", 12): None,
    ("hard", "I", 13): "28",

    # hard II
    ("hard", "II", 1): None,
    ("hard", "II", 2): None,
    ("hard", "II", 3): None,
    ("hard", "II", 4): "30 - 7 + 8 / 2 * 4",
    ("hard", "II", 5): None,
    ("hard", "II", 6): "30 - 7 + 4 * 4",
    ("hard", "II", 7): "30 - 7 + 16",
    ("hard", "II", 8): "39",

    # hard III
    ("hard", "III", 1): None,
    ("hard", "III", 2): None,
    ("hard", "III", 3): None,
    ("hard", "III", 4): "2 ^ 3 + 3 * ( 5 - 2 ) / ( 3 - 2 )",
    ("hard", "III", 5): None,
    ("hard", "III", 6): None,
    ("hard", "III", 7): "2 ^ 3 + 3 * 3 / ( 3 - 2 )",
    ("hard", "III", 8): None,
    ("hard", "III", 9): "2 ^ 3 + 3 * 3 / 1",
    ("hard", "III", 10): None,
    ("hard", "III", 11): "8 + 3 * 3 / 1",
    ("hard", "III", 12): None,
    ("hard", "III", 13): "8 + 9 / 1",
    ("hard", "III", 14): None,
    ("hard", "III", 15): "8 + 9",
    ("hard", "III", 16): "17",

    # hard IV
    ("hard", "IV", 1): None,
    ("hard", "IV", 2): None,
    ("hard", "IV", 3): None,
    ("hard", "IV", 4): "55 - 6 + 3 * root3( 5 ^ 6 )",
    ("hard", "IV", 5): None,
    ("hard", "IV", 6): "55 - 6 + 3 * 5 ^ 2",
    ("hard", "IV", 7): None,
    ("hard", "IV", 8): "55 - 6 + 3 * 25",
    ("hard", "IV", 9): None,
    ("hard", "IV", 10): "55 - 6 + 75",
    ("hard", "IV", 11): "124",

    # hard V
    ("hard", "V", 1): None,
    ("hard", "V", 2): None,
    ("hard", "V", 3): None,
    ("hard", "V", 4): "3 * [ 27 - 16 / ( 5 + 3 ) ]",
    ("hard", "V", 5): None,
    ("hard", "V", 6): "3 * [ 27 - 16 / 8 ]",
    ("hard", "V", 7): None,
    ("hard", "V", 8): "3 * [ 27 - 2 ]",
    ("hard", "V", 9): "3 * 25",
    ("hard", "V", 10): "75",

    # hard VI
    ("hard", "VI", 1): None,
    ("hard", "VI", 2): None,
    ("hard", "VI", 3): None,
    ("hard", "VI", 4): "20 + 2 - sqrt( root3( 3 ^ 12 ) ) + 1",
    ("hard", "VI", 5): None,
    ("hard", "VI", 6): "20 + 2 - sqrt( 3 ^ 4 ) + 1",
    ("hard", "VI", 7): None,
    ("hard", "VI", 8): None,
    ("hard", "VI", 9): "20 + 2 - 3 ^ 2 + 1",
    ("hard", "VI", 10): None,
    ("hard", "VI", 11): "20 + 2 - 9 + 1",
    ("hard", "VI", 12): "14",

    # hard VII
    ("hard", "VII", 1): None,
    ("hard", "VII", 2): None,
    ("hard", "VII", 3): None,
    ("hard", "VII", 4): "( 4 + 1 ) ^ 3 + [ 10 - ( 9 / 3 + 1 ) ] - sqrt( 9 + 40 )",
    ("hard", "VII", 5): None,
    ("hard", "VII", 6): None,
    ("hard", "VII", 7): "( 4 + 1 ) ^ 3 + [ 10 - ( 3 + 1 ) ] - sqrt( 9 + 40 )",
    ("hard", "VII", 8): None,
    ("hard", "VII", 9): "( 4 + 1 ) ^ 3 + [ 10 - ( 3 + 1 ) ] - sqrt( 49 )",
    ("hard", "VII", 10): None,
    ("hard", "VII", 11): "5 ^ 3 + [ 10 - ( 3 + 1 ) ] - sqrt( 49 )",
    ("hard", "VII", 12): None,
    ("hard", "VII", 13): "5 ^ 3 + [ 10 - 4 ] - sqrt( 49 )",
    ("hard", "VII", 14): None,
    ("hard", "VII", 15): "5 ^ 3 + [ 10 - 4 ] - 7",
    ("hard", "VII", 16): None,
    ("hard", "VII", 17): "125 + [ 10 - 4 ] - 7",
    ("hard", "VII", 18): None,
    ("hard", "VII", 19): "125 + 6 - 7",
    ("hard", "VII", 20): "124",

    # hard VIII
    ("hard", "VIII", 1): None,
    ("hard", "VIII", 2): None,
    ("hard", "VIII", 3): None,
    ("hard", "VIII", 4): None,
    ("hard", "VIII", 5): "5 + [ 15 - 2 ^ 2 + 2 ^ 3 ] + root3( 7 + 1 )",
    ("hard", "VIII", 6): None,
    ("hard", "VIII", 7): "5 + [ 15 - 2 ^ 2 + 8 ] + root3( 7 + 1 )",
    ("hard", "VIII", 8): None,
    ("hard", "VIII", 9): "5 + [ 15 - 2 ^ 2 + 8 ] + root3( 8 )",
    ("hard", "VIII", 10): None,
    ("hard", "VIII", 11): "5 + [ 15 - 4 + 8 ] + root3( 8 )",
    ("hard", "VIII", 12): None,
    ("hard", "VIII", 13): "5 + [ 15 - 4 + 8 ] + 2",
    ("hard", "VIII", 14): "5 + 19 + 2",
    ("hard", "VIII", 15): "26",

    # hard IX
    ("hard", "IX", 1): None,
    ("hard", "IX", 2): None,
    ("hard", "IX", 3): None,
    ("hard", "IX", 4): "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 2 ^ 2 + 1 ) ) - ( 6 + 2 ) ^ 2",
    ("hard", "IX", 5): None,
    ("hard", "IX", 6): None,
    ("hard", "IX", 7): "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) - ( 6 + 2 ) ^ 2",
    ("hard", "IX", 8): None,
    ("hard", "IX", 9): "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) - 8 ^ 2",
    ("hard", "IX", 10): None,
    ("hard", "IX", 11): "83 * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) - 8 ^ 2",
    ("hard", "IX", 12): None,
    ("hard", "IX", 13): "83 * 3 - sqrt( 23 + 10 / 5 ) - 8 ^ 2",
    ("hard", "IX", 14): None,
    ("hard", "IX", 15): "83 * 3 - sqrt( 23 + 10 / 5 ) - 64",
    ("hard", "IX", 16): None,
    ("hard", "IX", 17): "249 - sqrt( 23 + 10 / 5 ) - 64",
    ("hard", "IX", 18): None,
    ("hard", "IX", 19): "249 - sqrt( 23 + 2 ) - 64",
    ("hard", "IX", 20): "249 - sqrt( 25 ) - 64",
    ("hard", "IX", 21): "249 - 5 - 64",
    ("hard", "IX", 22): "180"
}

# Resolve correct sign operator token IDs dynamically
def get_correct_operator_ids(base_expr):
    tokens = base_expr.split()
    depths = []
    current_depth = 0
    for token in tokens:
        if token == '(' or token == '[' or '(' in token or '[' in token:
            current_depth += 1
        depths.append(current_depth)
        if token == ')' or token == ']' or ')' in token or ']' in token:
            current_depth -= 1
            
    correct_ids = []
    for idx, token in enumerate(tokens):
        if (token == '+' or token == '-') and depths[idx] == 0:
            correct_ids.append(f"t{idx}")
    return correct_ids

# Map index ranges of steps to clean up overlaps
# Clean steps:
# For Medium II to X: steps list matches exactly.
# For Hard I: steps match.
# For Hard II: we need to find that misplaced Step 8 under Hard III and move it here.
# For Hard III: we discard the misplaced Step 8 from Hard II.
# For Hard VI: we move the misplaced Step 12 from Hard VII here as Step 12.
# For Hard VII: we discard the misplaced Step 12.

cleaned_exercises = []

# First, extract steps for each exercise cleanly
exercise_by_id = {}
for ex in exercises:
    lvl = ex["complexity"]
    rom = ex["roman"]
    key = (lvl, rom)
    exercise_by_id[key] = ex

# Perform cleanup
# 1. Hard II and Hard III
hard_ii = exercise_by_id[("hard", "II")]
hard_iii = exercise_by_id[("hard", "III")]
# Find the misplaced step: It's in hard_iii and has text like "resultado de las últimas operaciones" or "30 - 7 + 16"
misplaced_hard_ii_step = None
for step in hard_iii["steps"]:
    if "últimas" in step["instruction"] and step["num"] == 8:
        misplaced_hard_ii_step = step
        break

if misplaced_hard_ii_step:
    # Rename step number to 8 for Hard II
    misplaced_hard_ii_step["num"] = 8
    hard_ii["steps"].append(misplaced_hard_ii_step)
    # Remove from Hard III
    hard_iii["steps"] = [s for s in hard_iii["steps"] if s != misplaced_hard_ii_step]

# Resort steps and re-number sequential IDs
# Hard III steps have two step 8s now or need renumbering
# Let's renumber steps for Hard III sequentially from 1 to 16
for idx, s in enumerate(hard_iii["steps"]):
    s["num"] = idx + 1

# 2. Hard VI and Hard VII
hard_vi = exercise_by_id[("hard", "VI")]
hard_vii = exercise_by_id[("hard", "VII")]
# Find misplaced step 12 in Hard VII:
misplaced_hard_vi_step = None
for s in hard_vii["steps"]:
    if "últimas" in s["instruction"] and s["num"] == 12:
        misplaced_hard_vi_step = s
        break

if misplaced_hard_vi_step:
    misplaced_hard_vi_step["num"] = 12
    hard_vi["steps"].append(misplaced_hard_vi_step)
    hard_vii["steps"] = [s for s in hard_vii["steps"] if s != misplaced_hard_vi_step]

# Renumber Hard VII steps sequentially
for idx, s in enumerate(hard_vii["steps"]):
    s["num"] = idx + 1

# Hardcode hints to make them premium and helpful
def get_hints(lvl, rom, step_num, inst, correct_answer):
    if step_num == 1:
        return ("Fíjate en los signos + y - que están sueltos; ellos dividen el ejercicio.", 
                "Los signos separadores son únicamente los signos + y -, ya que estos permiten dividir a la expresión aritmética en bloques.")
    elif step_num == 2:
        return ("Cuenta cuántos bloques quedan separados por los signos principales.",
                "Recuerda que los bloques se identifican a partir de los signos separadores (+ y -).")
    
    # Generic mathematical hints
    if "conservar" in inst.lower() or "conserve" in inst.lower():
        return ("Si un bloque ya solo tiene un número, lo conservas tal como está.",
                "Recuerda que los bloques que están compuestos por un solo número se conservan.")
    if "propiedad" in inst.lower():
        return ("Aplica la propiedad correspondiente de la potenciación o radicación.",
                "Recuerda aplicar las propiedades de potenciación/radicación antes de resolver.")
    if "primero" in inst.lower():
        return ("Sigue el orden de operaciones: potencias/raíces, luego mult/div, al final sumas/restas.",
                "Respeta la jerarquía de operaciones: primero potencias/raíces, luego multiplicaciones/divisiones.")
    
    return ("Resuelve la operación indicada con cuidado.", f"El resultado correcto de esta operación es {correct_answer}.")

# Generate Dart code
dart_output = []

def generate_exercise_dart(ex, ex_idx):
    lvl = ex["complexity"]
    rom = ex["roman"]
    base_expr = ex["base_expression"]
    diff_val = 2 if lvl == "medium" else 3
    title_lvl = "Medio" if lvl == "medium" else "Difícil"
    
    correct_ids_s1 = get_correct_operator_ids(base_expr)
    
    steps_code = []
    for step in ex["steps"]:
        s_num = step["num"]
        inst = step["instruction"].replace("'", "\\'")
        feedback = step["feedback"].replace("'", "\\'") if step["feedback"] else ""
        override = overrides_map.get((lvl, rom, s_num))
        
        # Determine correct ids
        c_ids = []
        if s_num == 1:
            c_ids = correct_ids_s1
        
        # Options list formatting
        opts = []
        for o in step["options"]:
            # Clean options
            o_clean = o.replace("'", "\\'").strip()
            if o_clean:
                opts.append(f"'{o_clean}'")
                
        correct_ans = step["correct_answer"].replace("'", "\\'").strip()
        
        hint, err_feed = get_hints(lvl, rom, s_num, inst, correct_ans)
        if not feedback:
            feedback = err_feed
        feedback = feedback.replace("'", "\\'")
        
        hint_escaped = hint.replace("'", "\\'")
        feedback_escaped = feedback.replace("'", "\\'")
        step_lines = [
            f"        StepEntity(",
            f"          id: '{lvl}_{ex_idx}_s{s_num}',",
            f"          instruction: '{inst}',",
        ]
        if override:
            step_lines.append(f"          expressionOverride: '{override}',")
        if opts:
            step_lines.append(f"          options: [{', '.join(opts)}],")
        if correct_ans and s_num > 1:
            step_lines.append(f"          correctAnswer: '{correct_ans}',")
            
        step_lines.append(f"          correctIds: {c_ids},")
        step_lines.append(f"          algorithmHint: '{hint_escaped}',")
        step_lines.append(f"          feedbackError: '{feedback_escaped}',")
        step_lines.append(f"        )")
        
        steps_code.append("\n".join(step_lines))
        
    ex_code = [
        f"    ExerciseEntity(",
        f"      id: '{lvl}_{ex_idx}',",
        f"      title: 'Nivel {title_lvl} {ex_idx}',",
        f"      baseExpression: '{base_expr}',",
        f"      rewardCoins: {15 if lvl == 'medium' else 20},",
        f"      difficulty: {diff_val},",
        f"      steps: [",
        ",\n".join(steps_code),
        f"      ],",
        f"    )"
    ]
    return "\n".join(ex_code)

medium_exs_code = []
for idx in range(2, 11):
    roman_map = {2: "II", 3: "III", 4: "IV", 5: "V", 6: "VI", 7: "VII", 8: "VIII", 9: "IX", 10: "X"}
    rom = roman_map[idx]
    ex = exercise_by_id[("medium", rom)]
    medium_exs_code.append(generate_exercise_dart(ex, idx))

hard_exs_code = []
for idx in range(1, 10):
    roman_map = {1: "I", 2: "II", 3: "III", 4: "IV", 5: "V", 6: "VI", 7: "VII", 8: "VIII", 9: "IX"}
    rom = roman_map[idx]
    ex = exercise_by_id[("hard", rom)]
    hard_exs_code.append(generate_exercise_dart(ex, idx))

with open("scratch/dart_repository_code.txt", "w", encoding="utf-8") as f_out:
    f_out.write("=== MEDIUM EXERCISES ===\n\n")
    f_out.write(",\n\n".join(medium_exs_code))
    f_out.write("\n\n=== HARD EXERCISES ===\n\n")
    f_out.write(",\n\n".join(hard_exs_code))

print("Successfully generated Dart exercises repository code in scratch/dart_repository_code.txt")
