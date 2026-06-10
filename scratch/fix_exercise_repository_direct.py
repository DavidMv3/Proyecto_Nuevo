import os

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Make replacements
replacements = {
    # 1. medium_3
    "feedbackError: 'En la división de potencias de igual base, se conserva la base y se restan los exponentes\\$/\\$\\$4 - 2\\$ = 2',": 
    "feedbackError: 'En la división de potencias de igual base, se conserva la base y se restan los exponentes: \\$4 - 2 = 2\\$.',",

    # 2. hard_2
    "instruction: 'El resultado de \\$76 \\div 75\\$ es:',":
    "instruction: 'El resultado de \\$7^6 \\div 7^5\\$ es:',",
    "feedbackError: 'Al dividir potencias de igual base se restan los exponentes\\$/\\$\\$76-5\\$ = 7',":
    "feedbackError: 'Al dividir potencias de igual base se restan los exponentes: \\$6 - 5 = 1\\$ (obteniendo \\$7^1 = 7\\$).',",

    # 3. hard_9
    "options: ['La suma 8\\$1 + 2\\$\\$\\$', 'La multiplicación', 'La resta', 'La raíz cuadrada'],":
    "options: ['La suma \\$81 + 2\\$', 'La multiplicación', 'La resta', 'La raíz cuadrada'],",
    "correctAnswer: 'La suma 8\\$1 + 2\\$\\$\\$',":
    "correctAnswer: 'La suma \\$81 + 2\\$',",
    "feedbackError: 'Al volver a observar de izquierda a derecha, en el primer bloque queda pendiente la suma interna 8\\$1 + 2\\$\\$\\$',":
    "feedbackError: 'Al volver a observar de izquierda a derecha, en el primer bloque queda pendiente la suma interna \\$81 + 2\\$.',",
    "instruction: 'El resultado de la suma 8\\$1 + 2\\$\\$\\$ es:',":
    "instruction: 'El resultado de la suma \\$81 + 2\\$ es:',",
    "feedbackError: 'El resultado de la suma 8\\$1 + 2\\$\\$\\$ es \\$83\\$',":
    "feedbackError: 'El resultado de la suma \\$81 + 2\\$ es \\$83\\$.',"
}

count = 0
for k, v in replacements.items():
    if k in content:
        content = content.replace(k, v)
        print(f"Replaced: {k[:40]}... -> {v[:40]}...")
        count += 1
    else:
        print(f"NOT FOUND: {k[:40]}...")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Completed replacements. Replaced {count} strings.")
