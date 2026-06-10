import re

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Make replacements
replacements = {
    # 1. medium_2_s4
    "instruction: 'Al aplicar el producto de potencias de igual base en 2\\$3 \\times 2\\$2, el resultado queda÷',":
    "instruction: 'Al aplicar el producto de potencias de igual base en \\$2^3 \\times 2^2\\$, el resultado queda:',",
    "options: ['26', '25', '45', '21'],\n          correctAnswer: '25',":
    "options: ['\\$2^6\\$', '\\$2^5\\$', '\\$4^5\\$', '\\$2^1\\$'],\n          correctAnswer: '\\$2^5\\$',",
    "feedbackError: 'En el producto de potencias de igual base, se conserva la base y se suman los exponentes\\$/\\$3\\$+\\$2 = 5',":
    "feedbackError: 'En el producto de potencias de igual base, se conserva la base y se suman los exponentes: \\$2^{3+2} = 2^5\\$.',",

    # 2. medium_3_s4
    "instruction: 'Al aplicar la división de potencias de igual base en \\$3^4\\$ \\div \\$3^2\\$, el resultado queda÷',":
    "instruction: 'Al aplicar la división de potencias de igual base en \\$3^4\\$ \\div \\$3^2\\$, el resultado queda:',",
    "options: ['36', '32', '38', '34'],\n          correctAnswer: '32',":
    "options: ['\\$3^6\\$', '\\$3^2\\$', '\\$3^8\\$', '\\$3^4\\$'],\n          correctAnswer: '\\$3^2\\$',",
    "feedbackError: 'En la división de potencias de igual base, se conserva la base y se restan los exponentes: \\$4 - 2 = 2\\$.',":
    "feedbackError: 'En la división de potencias de igual base, se conserva la base y se restan los exponentes: \\$3^{4-2} = 3^2\\$.',",

    # 3. medium_4_s3
    "options: ['La resta (\\$2 \\times 3\\$)\\$2 - 30\\$', 'La potencia (\\$2 \\times 3\\$)2', 'La multiplicación \\$2 \\times 3\\$', 'La suma entre bloques'],":
    "options: ['La resta \\$(2 \\times 3)^2 - 30\\$', 'La potencia \\$(2 \\times 3)^2\\$', 'La multiplicación \\$2 \\times 3\\$', 'La suma entre bloques'],",

    # 4. medium_5_s3
    "options: ['La potencia (\\$8 \\div 2\\$) 2', 'La división \\$8 \\div 2\\$', 'La resta (\\$8 \\div 2\\$) \\$2 - 12\\$', 'La suma entre bloques'],":
    "options: ['La potencia \\$(8 \\div 2)^2\\$', 'La división \\$8 \\div 2\\$', 'La resta \\$(8 \\div 2)^2 - 12\\$', 'La suma entre bloques'],",

    # 5. medium_5_s5
    "options: ['La resta \\$52 - 4\\$', 'La potencia \\$5^2\\$', 'La suma entre bloques', 'La división'],":
    "options: ['La resta \\$5^2 - 4\\$', 'La potencia \\$5^2\\$', 'La suma entre bloques', 'La división'],",

    # 6. medium_5_s7
    "options: ['La resta (4)\\$2 - 12\\$', 'La potencia \\$4^2\\$', 'La resta \\$25 - 4\\$', 'La suma final'],":
    "options: ['La resta \\$4^2 - 12\\$', 'La potencia \\$4^2\\$', 'La resta \\$25 - 4\\$', 'La suma final'],",

    # 7. medium_6_s3
    "options: ['La potencia exterior(22)3', 'La propiedad de potencia de potencia', 'La división \\$50 \\div 5\\$', 'La resta'],":
    "options: ['La potencia exterior \\$(2^2)^3\\$', 'La propiedad de potencia de potencia', 'La división \\$50 \\div 5\\$', 'La resta'],",

    # 8. medium_6_s4
    "instruction: 'Al aplicar la propiedad de potencia de potencia en(22)3, el resultado queda÷',":
    "instruction: 'Al aplicar la propiedad de potencia de potencia en \\$(2^2)^3\\$, el resultado queda:',",
    "options: ['25', '26', '43', '29'],\n          correctAnswer: '26',":
    "options: ['\\$2^5\\$', '\\$2^6\\$', '\\$4^3\\$', '\\$2^9\\$'],\n          correctAnswer: '\\$2^6\\$',",

    # 9. medium_7_s3
    "options: ['La resta 15 - (\\$7 - 4\\$)', 'La operación interna \\$7 - 4\\$', 'La potencia (\\$7 - 4\\$)2', 'La suma entre bloques'],":
    "options: ['La resta \\$15 - (7 - 4)^2\\$', 'La operación interna \\$7 - 4\\$', 'La potencia \\$(7 - 4)^2\\$', 'La suma entre bloques'],"
}

# Auto replace any 'queda÷' with 'queda:'
content = content.replace("queda÷", "queda:")

count = 0
for k, v in replacements.items():
    # Normalize line endings/whitespaces slightly if needed
    k_norm = k.replace("\r\n", "\n")
    v_norm = v.replace("\r\n", "\n")
    if k_norm in content:
        content = content.replace(k_norm, v_norm)
        print(f"Replaced: {k_norm[:35]}... -> {v_norm[:35]}...")
        count += 1
    else:
        # Try raw replace without normalization
        if k in content:
            content = content.replace(k, v)
            print(f"Replaced raw: {k[:35]}... -> {v[:35]}...")
            count += 1
        else:
            print(f"NOT FOUND: {k[:35]}...")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Completed medium exercises corrections. Total replaced: {count}")
