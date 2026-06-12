import json
import re

def main():
    # Load assets/exercises.json
    with open("assets/exercises.json", "r", encoding="utf-8") as f:
        exercises = json.load(f)

    # 1. We hardcode the Tutorial exercise since it's difficulty 0 and isn't in exercises.json
    tutorial_code = """    ExerciseEntity(
      id: 'tutorial_1',
      title: 'Tutorial de MateAndina',
      baseExpression: '2 + 3 x 4',
      rewardCoins: 5,
      difficulty: 0,
      steps: [
        StepEntity(
          id: 'tut1_s1',
          instruction: '¡Bienvenido a MateAndina! Vamos a aprender a jugar.\\nPrimero, selecciona todos los signos separadores (+) o (-).',
          correctIds: ['t1'], // El '+' en '2 + 3 x 4'
          algorithmHint: 'Fíjate en los signos + y - que están sueltos; ellos dividen el ejercicio.',
          feedbackError: '¡Casi! Los signos separadores de bloques son el "+" y el "-". Inténtalo de nuevo.',
        ),
        StepEntity(
          id: 'tut1_s2',
          instruction: '¡Excelente! Ahora veamos la jerarquía.\\nEntre sumar o multiplicar (3 x 4), ¿cuál tiene prioridad (se resuelve primero)?',
          correctIds: ['t2', 't3', 't4'], // '3 x 4'
          algorithmHint: 'Asegúrate de resolver primero las multiplicaciones antes de sumar o restar.',
          feedbackError: 'Recuerda que las multiplicaciones y divisiones tienen más fuerza que sumas y restas.',
        ),
        StepEntity(
          id: 'tut1_s3',
          instruction: '¡Muy bien! Ahora toca la respuesta correcta.\\n¿Cuál es el resultado de 3 x 4?',
          options: ['7', '12', '14'],
          correctAnswer: '12',
          algorithmHint: 'Asegúrate de resolver primero las multiplicaciones antes de sumar o restar.',
          feedbackError: 'Al multiplicar 3 veces 4 obtenemos 12.',
          correctIds: [],
          expressionOverride: '2 + 12',
        ),
        StepEntity(
          id: 'tut1_s4',
          expressionOverride: '2 + 12',
          instruction: '¡Último paso! Ahora nuestra ecuación es 2 + 12.\\n¿Cuál es el resultado final?',
          options: ['10', '24', '14'],
          correctAnswer: '14',
          algorithmHint: 'Suma o resta directamente los elementos que te quedan.',
          feedbackError: 'Si sumas 2 + 12 el resultado es 14.',
          correctIds: [],
        ),
      ],
    ),"""

    def clean_text(text):
        if not text:
            return ""
        # Escape single quotes for Dart string literals
        t = text.replace("'", "\\'")
        # Ensure we don't have double/triple dollar signs that make KaTeX fail
        t = t.replace("$$", "$")
        # Ensure backslashes are escaped in Dart string literals first
        t = t.replace("\\", "\\\\")
        # Escape dollar signs for Dart string literals (avoiding interpolation) after
        t = t.replace("$", "\\$")
        return t

    def get_hints(lvl, step_num, inst, correct_answer):
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

    easy_entities = []
    medium_entities = []
    hard_entities = []

    for ex in exercises:
        ex_id = ex["exercise_id"]
        complexity = ex["complexity"]
        base_expression = ex["initial_expression"]
        
        # Determine parameters based on complexity
        if complexity == "baja":
            diff_val = 1
            reward = 10
            title_lvl = "Fácil"
            dest_list = easy_entities
        elif complexity == "media":
            diff_val = 2
            reward = 20
            title_lvl = "Medio"
            dest_list = medium_entities
        else: # alta
            diff_val = 3
            reward = 35
            title_lvl = "Difícil"
            dest_list = hard_entities
            
        ex_num = ex_id.split("_")[-1]
        title = f"Nivel {title_lvl} {ex_num}"
        
        step_codes = []
        for step in ex["workflow_steps"]:
            s_num = step["step_index"]
            s_type = step["type"]
            
            # Instruction mapping
            if s_type == "operator_selection":
                inst = step["instruction"]
            else:
                inst = step["question"]
                
            # Correct answer mapping
            correct_ans = ""
            if "correct_answer" in step:
                correct_ans = step["correct_answer"]
            elif "correct_option" in step:
                correct_opt_id = step["correct_option"]
                # Find option text
                for opt in step["options"]:
                    if opt["id"] == correct_opt_id:
                        correct_ans = opt["text"]
                        break
            
            # Options formatting
            opts_formatted = []
            if "options" in step and step["options"]:
                for opt in step["options"]:
                    opts_formatted.append(f"'{clean_text(opt['text'])}'")
            
            # expressionOverride mapping
            override = None
            if "display_append" in step and step["display_append"]:
                override = step["display_append"]
                
            # correctIds mapping (only operator selection)
            correct_ids = []
            if s_type == "operator_selection" and "correct_targets" in step:
                correct_ids = step["correct_targets"]
            
            # Clean up fields
            inst_clean = clean_text(inst)
            correct_ans_clean = clean_text(correct_ans)
            
            # Retrieve default/fallback hints & feedback failure
            hint_fallback, feed_fallback = get_hints(complexity, s_num, inst, correct_ans)
            
            # Feedback mapping
            feedback_clean = ""
            if "feedback_failure" in step and step["feedback_failure"]:
                feedback_clean = clean_text(step["feedback_failure"])
            else:
                feedback_clean = clean_text(feed_fallback)
                
            hint_clean = clean_text(hint_fallback)
            
            # Generate step entity string
            step_str = []
            step_str.append("        StepEntity(")
            step_str.append(f"          id: '{ex_id}_s{s_num}',")
            step_str.append(f"          instruction: '{inst_clean}',")
            if override is not None:
                step_str.append(f"          expressionOverride: '{clean_text(override)}',")
            if opts_formatted:
                step_str.append(f"          options: [{', '.join(opts_formatted)}],")
            if correct_ans_clean and s_num > 1:
                step_str.append(f"          correctAnswer: '{correct_ans_clean}',")
            
            c_ids_formatted = ", ".join([f"'{cid}'" for cid in correct_ids])
            step_str.append(f"          correctIds: [{c_ids_formatted}],")
            step_str.append(f"          algorithmHint: '{hint_clean}',")
            step_str.append(f"          feedbackError: '{feedback_clean}',")
            step_str.append("        )")
            
            step_codes.append("\n".join(step_str))
            
        ex_str = []
        ex_str.append("    ExerciseEntity(")
        ex_str.append(f"      id: '{ex_id}',")
        ex_str.append(f"      title: '{title}',")
        ex_str.append(f"      baseExpression: '{clean_text(base_expression)}',")
        ex_str.append(f"      rewardCoins: {reward},")
        ex_str.append(f"      difficulty: {diff_val},")
        ex_str.append("      steps: [")
        ex_str.append(",\n".join(step_codes))
        ex_str.append("      ],")
        ex_str.append("    )")
        
        dest_list.append("\n".join(ex_str))

    easy_data_str = ",\n\n".join(easy_entities)
    medium_data_str = ",\n\n".join(medium_entities)
    hard_data_str = ",\n\n".join(hard_entities)

    repository_content = f"""import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/step_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseRepository {{
  // ==========================================
  // TUTORIAL (Dificultad 0) - No afecta el ciclo de niveles
  // ==========================================
  static final List<ExerciseEntity> _tutorialData = [
{tutorial_code}
  ];

  // ==========================================
  // NIVEL FÁCIL
  // ==========================================
  static final List<ExerciseEntity> _easyData = [
{easy_data_str}
  ];

  // ==========================================
  // NIVEL MEDIO
  // ==========================================
  static final List<ExerciseEntity> _mediumData = [
{medium_data_str}
  ];

  // ==========================================
  // NIVEL DIFÍCIL
  // ==========================================
  static final List<ExerciseEntity> _hardData = [
{hard_data_str}
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
"""

    with open("lib/data/repositories/exercise_repository.dart", "w", encoding="utf-8") as f_out:
        f_out.write(repository_content)

    print("Successfully generated repository code from assets/exercises.json!")

if __name__ == "__main__":
    main()
