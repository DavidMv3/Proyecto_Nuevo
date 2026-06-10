import re
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('scratch/parsed_ranges.json', 'r', encoding='utf-8') as f:
    parsed_exercises = json.load(f)

with open('lib/data/repositories/exercise_repository.dart', 'r', encoding='utf-8') as f:
    current_repo = f.read()

# Extract tutorial data string
tutorial_match = re.search(r'(static final List<ExerciseEntity> _tutorialData = \[\n.*?\n  \];)', current_repo, re.DOTALL)
tutorial_data_str = tutorial_match.group(1) if tutorial_match else ''

def get_correct_operator_ids(base_expr):
    tokens = base_expr.split()
    depths = []
    current_depth = 0
    for token in tokens:
        if token == '(' or token == '[' or '{' in token or '(' in token or '[' in token:
            current_depth += 1
        depths.append(current_depth)
        if token == ')' or token == ']' or '}' in token or ')' in token or ']' in token:
            current_depth -= 1
            
    correct_ids = []
    for idx, token in enumerate(tokens):
        if (token == '+' or token == '-') and depths[idx] == 0:
            correct_ids.append(f"t{idx}")
    return correct_ids

def get_hints(lvl, rom, step_num, inst, correct_answer):
    if step_num == 1:
        return ("Fíjate en los signos + y - que están sueltos; ellos dividen el ejercicio.", 
                "Los signos separadores son únicamente los signos + y -, ya que estos permiten dividir a la expresión aritmética en bloques.")
    elif step_num == 2:
        return ("Cuenta cuántos bloques quedan separados por los signos principales.",
                "Recuerda que los bloques se identifican a partir de los signos separadores (+ y -).")
    
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

def apply_latex(text):
    if not text:
        return text
    
    t = text
    t = t.replace("8", "81")
    t = t.replace("2", "2")
    t = t.replace("es/ ", "es: ")
    t = t.replace("es / ", "es: ")
    t = re.sub(r'\bes\s*/+\s*$', 'es:', t)
    t = re.sub(r'\bes/+$', 'es:', t)
    t = t.replace("potencias/raíces", "potencias / raíces")
    t = t.replace("mult/div", "mult / div")
    t = t.replace("sumas/restas", "sumas / restas")
    
    t = re.sub(r'([a-zA-ZáéíóúÁÉÍÓÚñÑ])(\d+)', r'\1 \2', t)
    t = re.sub(r'(\d+)([a-zA-ZáéíóúÁÉÍÓÚñÑ])', r'\1 \2', t)
    t = re.sub(r'\bpotencia\s+(\d)(\d)\b', r'potencia $\1^\2$', t)
    t = re.sub(r'\bpotencia\s*\((\d+)\)\s*(\d)\b', r'potencia $\1^\2$', t)
    t = re.sub(r'\bpotencia\s+(\d+)\b', r'potencia $\1$', t)
    
    parts = t.split('$')
    
    for i in range(len(parts)):
        if i % 2 == 1:
            continue
        s = parts[i]
        
        s = s.replace("potencia 2 ^ 3", "potencia ^3$")
        s = s.replace("potencia 3 ^ 2", "potencia ^2$")
        s = s.replace("potencia32", "potencia ^2$")
        s = s.replace("potencia 32", "potencia ^2$")
        s = s.replace("potencia23", "potencia ^3$")
        s = s.replace("potencia 23", "potencia ^3$")
        s = s.replace("potencia25", "potencia ^5$")
        s = s.replace("potencia 25", "potencia ^5$")
        s = s.replace("exponente 2 y 3", "exponentes $ y $")
        
        s = s.replace("18 + 3 * 5", " + 3 \\times 5$")
        s = s.replace("18 + 3", " + 3$")
        s = s.replace("3 x 5", " \\times 5$")
        s = s.replace("3 × 5", " \\times 5$")
        
        def wrap_math(match):
            expr = match.group(0)
            expr = expr.replace("*", "\\times").replace("x", "\\times").replace("×", "\\times")
            expr = expr.replace("/", "\\div").replace("÷", "\\div")
            expr = expr.replace("sqrt", "\\sqrt")
            return f"$"
            
        s = re.sub(r'\b\d+(?:\s*[\+\-\*/÷×\^]\s*\d+)+\b', wrap_math, s)
        
        s = re.sub(r'\bes\s+(\d+)\b', r'es $\1$', s)
        s = re.sub(r'\bde\s+(\d+)\b', r'de $\1$', s)
        s = re.sub(r'\bobtenemos\s+(\d+)\b', r'obtenemos $\1$', s)
        s = re.sub(r'\bda\s+(\d+)\b', r'da $\1$', s)
        s = re.sub(r'\bresultado\s+(\d+)\b', r'resultado $\1$', s)
        
        s = s.replace("*", "×")
        s = s.replace("/", "÷")
        
        parts[i] = s
        
    return "$".join(parts)

def format_step(s, lvl, ex_idx):
    inst = apply_latex(s['instruction']).replace("'", "\\'").replace("$", "\\$")
    s_num = s["num"]
    override = s["override"]
    correct_ans = apply_latex(s["correct_answer"]).replace("'", "\\'") if s["correct_answer"] else ""
    hint, feedback = get_hints(lvl, "I", s_num, s['instruction'], correct_ans)
    
    if s["feedback"]:
        feedback = apply_latex(s["feedback"]).replace("'", "\\'").replace("$", "\\$")
    else:
        feedback = feedback.replace("'", "\\'").replace("$", "\\$")
        
    hint = hint.replace("'", "\\'").replace("$", "\\$")
    
    opts_clean = []
    for o in s["options"]:
        val = apply_latex(o).replace('"', '').replace("'", "\\'").replace('$', '\\$').strip()
        opts_clean.append(f"'{val}'")
        
    c_ids = get_correct_operator_ids(base_expr) if s_num == 1 else []
    c_ids_str = ", ".join([f"'{cid}'" for cid in c_ids])
    
    lines = [
        f"        StepEntity(",
        f"          id: '{lvl}_{ex_idx}_s{s_num}',",
        f"          instruction: '{inst}',",
    ]
    if override:
        override_esc = override.replace("'", "\\'").replace("$", "\\$")
        lines.append(f"          expressionOverride: '{override_esc}',")
    if opts_clean:
        lines.append(f"          options: [{', '.join(opts_clean)}],")
    if correct_ans and s_num > 1:
        ans_esc = correct_ans.replace("$", "\\$")
        lines.append(f"          correctAnswer: '{ans_esc}',")
        
    lines.append(f"          correctIds: [{c_ids_str}],")
    lines.append(f"          algorithmHint: '{hint}',")
    lines.append(f"          feedbackError: '{feedback}',")
    lines.append(f"        )")
    return "\n".join(lines)

def format_exercise(ex, ex_idx):
    lvl = ex["complexity"]
    base_expr = ex["base_expression"]
    title_lvl = "Fácil" if lvl == "easy" else ("Medio" if lvl == "medium" else "Difícil")
    diff_val = 1 if lvl == "easy" else (2 if lvl == "medium" else 3)
    reward = 10 if lvl == "easy" else (15 if lvl == "medium" else 20)
    
    # We do a quick loop to fix correct ids since we need base_expr
    global current_base_expr
    current_base_expr = base_expr
    
    steps_code = []
    for s in ex["steps"]:
        steps_code.append(format_step(s, lvl, ex_idx))
        
    ex_code = [
        f"    ExerciseEntity(",
        f"      id: '{lvl}_{ex_idx}',",
        f"      title: 'Nivel {title_lvl} {ex_idx}',",
        f"      baseExpression: '{base_expr}',",
        f"      rewardCoins: {reward},",
        f"      difficulty: {diff_val},",
        f"      steps: [",
        ",\n".join(steps_code),
        f"      ],",
        f"    )"
    ]
    return "\n".join(ex_code)

roman_map = {"I":1, "II":2, "III":3, "IV":4, "V":5, "VI":6, "VII":7, "VIII":8, "IX":9, "X":10}
easy_code = []
med_code = []
hard_code = []

for ex in parsed_exercises:
    ex_idx = roman_map[ex["roman"]]
    global base_expr
    base_expr = ex["base_expression"]
    code = format_exercise(ex, ex_idx)
    if ex["complexity"] == "easy":
        easy_code.append((ex_idx, code))
    elif ex["complexity"] == "medium":
        med_code.append((ex_idx, code))
    else:
        hard_code.append((ex_idx, code))

easy_code.sort(key=lambda x: x[0])
med_code.sort(key=lambda x: x[0])
hard_code.sort(key=lambda x: x[0])

easy_str = ",\n".join([c[1] for c in easy_code])
med_str = ",\n".join([c[1] for c in med_code])
hard_str = ",\n".join([c[1] for c in hard_code])

new_repo_content = f'''import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/step_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseRepository {{
  // ==========================================
  // TUTORIAL (Dificultad 0) - No afecta el ciclo de niveles
  // ==========================================
{tutorial_data_str}

  // ==========================================
  // NIVEL FÁCIL
  // ==========================================
  static final List<ExerciseEntity> _easyData = [
{easy_str}
  ];

  // ==========================================
  // NIVEL MEDIO
  // ==========================================
  static final List<ExerciseEntity> _mediumData = [
{med_str}
  ];

  // ==========================================
  // NIVEL DIFÍCIL
  // ==========================================
  static final List<ExerciseEntity> _hardData = [
{hard_str}
  ];

  // Getters
  ExerciseEntity get tutorialExercise => _tutorialData.first;
  List<ExerciseEntity> get easyExercises => _easyData;
  List<ExerciseEntity> get mediumExercises => _mediumData;
  List<ExerciseEntity> get hardExercises => _hardData;

  List<ExerciseEntity> getExercisesByDifficulty(int diff) {{
    switch (diff) {{
      case 0: return _tutorialData;
      case 1: return _easyData;
      case 2: return _mediumData;
      case 3: return _hardData;
      default: return [];
    }}
  }}

  List<ExerciseEntity> getAll() {{
    return [..._easyData, ..._mediumData, ..._hardData];
  }}
}}

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {{
  return ExerciseRepository();
}});
'''

with open('lib/data/repositories/exercise_repository.dart', 'w', encoding='utf-8') as f:
    f.write(new_repo_content)

print('Repository updated successfully!')
