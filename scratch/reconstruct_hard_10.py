import json

def get_hard_10_steps():
    return [
        {
            "step_index": 1,
            "type": "operator_selection",
            "instruction": "Selecciona los signos separadores que no constan en las operaciones internas.",
            "correct_targets": ["t3", "t9", "t17", "t27"],
            "feedback_failure": "Este es un signo separador de operaciones internas.",
            "visual_mutation": {
                "apply_color": {
                    "separators": "blue",
                    "internals": "red"
                }
            }
        },
        {
            "step_index": 2,
            "type": "block_count",
            "question": "¿En cuántos bloques queda dividida la expresión aritmética?",
            "options": [
                {"id": "a", "text": "3"},
                {"id": "b", "text": "4"},
                {"id": "c", "text": "5"},
                {"id": "d", "text": "2"}
            ],
            "correct_answer": "5",
            "feedback_failure": "Recuerda que los bloques se identifican a partir de los signos separadores que no están dentro de las operaciones internas."
        },
        {
            "step_index": 3,
            "type": "evaluation_step",
            "focus_block": 1,
            "question": "El resultado del primer bloque es:",
            "options": [
                {"id": "a", "text": "10"},
                {"id": "b", "text": "7"},
                {"id": "c", "text": "15"},
                {"id": "d", "text": "25"}
            ],
            "correct_answer": "25",
            "feedback_failure": "El resultado de la potencia $5^2$ es $25$.",
            "display_append": "25 + 8 * 2 ^ 2 - 7 ^ 8 / 7 ^ 6 + 2 * ( 5 + 4 / 2 ) - sqrt ( 15 + 1 )"
        },
        {
            "step_index": 4,
            "type": "evaluation_step",
            "focus_block": 2,
            "question": "En el segundo bloque, ¿qué operación se debe realizar primero?",
            "options": [
                {"id": "a", "text": "La multiplicación"},
                {"id": "b", "text": "La potenciación"}
            ],
            "correct_answer": "La potenciación",
            "feedback_failure": "Entre la multiplicación y la potenciación, primero se resuelve la potenciación."
        },
        {
            "step_index": 5,
            "type": "evaluation_step",
            "focus_block": 2,
            "question": "El resultado de la potencia $2^2$ es:",
            "options": [
                {"id": "a", "text": "2"},
                {"id": "b", "text": "4"},
                {"id": "c", "text": "8"},
                {"id": "d", "text": "1"}
            ],
            "correct_answer": "4",
            "feedback_failure": "El resultado de la potencia $2^2$ es $4$.",
            "display_append": "25 + 8 * 4 - 7 ^ 8 / 7 ^ 6 + 2 * ( 5 + 4 / 2 ) - sqrt ( 15 + 1 )"
        },
        {
            "step_index": 6,
            "type": "evaluation_step",
            "focus_block": 3,
            "question": "En el tercer bloque, ¿qué se debe realizar primero?",
            "options": [
                {"id": "a", "text": "Las potencias"},
                {"id": "b", "text": "La división"},
                {"id": "c", "text": "La propiedad de la división de potencias de igual base"}
            ],
            "correct_answer": "La propiedad de la división de potencias de igual base",
            "feedback_failure": "Cuando se presenta una división de potencias de igual base, primero se aplica la propiedad correspondiente: se conserva la base y se restan los exponentes."
        },
        {
            "step_index": 7,
            "type": "evaluation_step",
            "focus_block": 3,
            "question": "El resultado de la propiedad en $7^8 / 7^6$ es:",
            "options": [
                {"id": "a", "text": "$7^{14}$"},
                {"id": "b", "text": "$7^2$"},
                {"id": "c", "text": "7"},
                {"id": "d", "text": "2"}
            ],
            "correct_answer": "$7^2$",
            "feedback_failure": "En la división de potencias de igual base, se conserva la base y se restan los exponentes: $8 - 6 = 2$ (obteniendo $7^2$).",
            "display_append": "25 + 8 * 4 - 7 ^ 2 + 2 * ( 5 + 4 / 2 ) - sqrt ( 15 + 1 )"
        },
        {
            "step_index": 8,
            "type": "evaluation_step",
            "focus_block": 4,
            "question": "En el bloque cuatro, ¿qué operación se resuelve primero?",
            "options": [
                {"id": "a", "text": "La multiplicación"},
                {"id": "b", "text": "La suma"},
                {"id": "c", "text": "Las operaciones internas"}
            ],
            "correct_answer": "Las operaciones internas",
            "feedback_failure": "Entre las operaciones internas y otras operaciones, primero se resuelven las operaciones internas."
        },
        {
            "step_index": 9,
            "type": "evaluation_step",
            "focus_block": 4,
            "question": "En las operaciones internas del bloque cuatro, ¿qué operación se resuelve primero?",
            "options": [
                {"id": "a", "text": "La suma"},
                {"id": "b", "text": "La división"}
            ],
            "correct_answer": "La división",
            "feedback_failure": "Entre la suma y la división, se resuelve primero la división."
        },
        {
            "step_index": 10,
            "type": "evaluation_step",
            "focus_block": 4,
            "question": "El resultado de la división que consta en las operaciones internas del bloque cuatro es:",
            "options": [
                {"id": "a", "text": "9"},
                {"id": "b", "text": "2"},
                {"id": "c", "text": "7"},
                {"id": "d", "text": "1"}
            ],
            "correct_answer": "2",
            "feedback_failure": "El resultado de la división $4 \\div 2$ es $2$.",
            "display_append": "25 + 8 * 4 - 7 ^ 2 + 2 * ( 5 + 2 ) - sqrt ( 15 + 1 )"
        },
        {
            "step_index": 11,
            "type": "evaluation_step",
            "focus_block": 5,
            "question": "En el bloque cinco, ¿cuál es el resultado de la operación interna?",
            "options": [
                {"id": "a", "text": "4"},
                {"id": "b", "text": "16"},
                {"id": "c", "text": "15"},
                {"id": "d", "text": "14"}
            ],
            "correct_answer": "16",
            "feedback_failure": "La suma $15 + 1$ es $16$.",
            "display_append": "25 + 8 * 4 - 7 ^ 2 + 2 * ( 5 + 2 ) - sqrt ( 16 )"
        },
        {
            "step_index": 12,
            "type": "operator_selection",
            "instruction": "Selecciona los signos separadores que no constan en las operaciones internas.",
            "correct_targets": ["t1", "t5", "t9", "t17"],
            "feedback_failure": "Este es un signo separador de operaciones internas."
        },
        {
            "step_index": 13,
            "type": "block_count",
            "question": "¿En cuántos bloques queda dividida la expresión aritmética?",
            "options": [
                {"id": "a", "text": "3"},
                {"id": "b", "text": "4"},
                {"id": "c", "text": "5"},
                {"id": "d", "text": "2"}
            ],
            "correct_answer": "5",
            "feedback_failure": "Recuerda que los bloques se identifican a partir de los signos separadores que no están dentro de las operaciones internas."
        },
        {
            "step_index": 14,
            "type": "evaluation_step",
            "focus_block": 1,
            "question": "¿Qué se realiza en el primer bloque?",
            "options": [
                {"id": "a", "text": "Se conserva el número"},
                {"id": "b", "text": "Se elimina el número"}
            ],
            "correct_answer": "Se conserva el número",
            "feedback_failure": "En el primer bloque no hay operaciones, por lo que el número $25$ se conserva.",
            "display_append": "25 +"
        },
        {
            "step_index": 15,
            "type": "evaluation_step",
            "focus_block": 2,
            "question": "¿Cuál es el resultado del segundo bloque?",
            "options": [
                {"id": "a", "text": "32"},
                {"id": "b", "text": "12"}
            ],
            "correct_answer": "32",
            "feedback_failure": "El resultado de la multiplicación $8 \\times 4$ es $32$.",
            "display_append": "25 + 32 - 7 ^ 2 + 2 * ( 5 + 2 ) - sqrt ( 16 )"
        },
        {
            "step_index": 16,
            "type": "evaluation_step",
            "focus_block": 3,
            "question": "¿Cuál es el resultado del tercer bloque?",
            "options": [
                {"id": "a", "text": "49"},
                {"id": "b", "text": "14"}
            ],
            "correct_answer": "49",
            "feedback_failure": "El resultado de la potencia $7^2$ es $49$.",
            "display_append": "25 + 32 - 49 + 2 * ( 5 + 2 ) - sqrt ( 16 )"
        },
        {
            "step_index": 17,
            "type": "evaluation_step",
            "focus_block": 4,
            "question": "En el bloque cuatro, ¿qué se realiza primero?",
            "options": [
                {"id": "a", "text": "La operación interna"},
                {"id": "b", "text": "La multiplicación"}
            ],
            "correct_answer": "La operación interna",
            "feedback_failure": "Entre las operaciones internas y otras operaciones, primero se resuelven las operaciones internas."
        },
        {
            "step_index": 18,
            "type": "evaluation_step",
            "focus_block": 4,
            "question": "¿Cuál es el resultado de la operación interna del bloque cuatro?",
            "options": [
                {"id": "a", "text": "7"},
                {"id": "b", "text": "10"}
            ],
            "correct_answer": "7",
            "feedback_failure": "La suma $5 + 2 = 7$.",
            "display_append": "25 + 32 - 49 + 2 * ( 7 ) - sqrt ( 16 )"
        },
        {
            "step_index": 19,
            "type": "evaluation_step",
            "focus_block": 5,
            "question": "¿Cuál es el resultado de la operación interna del bloque cinco?",
            "options": [
                {"id": "a", "text": "8"},
                {"id": "b", "text": "4"}
            ],
            "correct_answer": "4",
            "feedback_failure": "El resultado de la raíz cuadrada $\\sqrt{16}$ es $4$.",
            "display_append": "25 + 32 - 49 + 2 * ( 7 ) - 4"
        },
        {
            "step_index": 20,
            "type": "evaluation_step",
            "focus_block": 1,
            "question": "¿Qué operación se realiza primero?",
            "options": [
                {"id": "a", "text": "La multiplicación"},
                {"id": "b", "text": "Las sumas"},
                {"id": "c", "text": "Las restas"}
            ],
            "correct_answer": "La multiplicación",
            "feedback_failure": "Entre sumas, restas y multiplicación, se resuelve primero la multiplicación; mientras tanto, los demás números se conservan."
        },
        {
            "step_index": 21,
            "type": "evaluation_step",
            "focus_block": 1,
            "question": "¿Cuál es el resultado de la multiplicación?",
            "options": [
                {"id": "a", "text": "9"},
                {"id": "b", "text": "14"}
            ],
            "correct_answer": "14",
            "feedback_failure": "El resultado de la multiplicación $2 \\times 7$ es $14$.",
            "display_append": "25 + 32 - 49 + 14 - 4"
        },
        {
            "step_index": 22,
            "type": "evaluation_step",
            "focus_block": 1,
            "question": "Al resolver ordenadamente las sumas y restas de la expresión aritmética, se obtiene el siguiente resultado:",
            "options": [
                {"id": "a", "text": "18"},
                {"id": "b", "text": "22"},
                {"id": "c", "text": "50"},
                {"id": "d", "text": "21"}
            ],
            "correct_answer": "18",
            "feedback_failure": "El resultado de la operación $25 + 32 - 49 + 14 - 4$ es $18$.",
            "display_append": "18"
        }
    ]

def main():
    with open("assets/exercises.json", "r", encoding="utf-8") as f:
        exercises = json.load(f)

    found = False
    for ex in exercises:
        if ex["exercise_id"] == "hard_10":
            ex["workflow_steps"] = get_hard_10_steps()
            found = True
            break
            
    if not found:
        print("Error: hard_10 not found in assets/exercises.json!")
        return

    with open("assets/exercises.json", "w", encoding="utf-8") as f:
        json.dump(exercises, f, indent=2, ensure_ascii=False)
    print("Successfully updated hard_10 in assets/exercises.json with 22 steps!")

if __name__ == "__main__":
    main()
