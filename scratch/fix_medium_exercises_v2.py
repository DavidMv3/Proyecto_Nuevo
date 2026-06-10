import re

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Make replacements (with double backslashes for times, div, sqrt)
replacements = {
    # 1. medium_2_s4 instruction
    "instruction: 'Al aplicar el producto de potencias de igual base en 2\\$3 \\\\times 2\\$2, el resultado queda:',":
    "instruction: 'Al aplicar el producto de potencias de igual base en \\$2^3 \\\\times 2^2\\$, el resultado queda:',",

    # 2. medium_3_s4 instruction
    "instruction: 'Al aplicar la división de potencias de igual base en \\$3^4\\$ \\\\div \\$3^2\\$, el resultado queda:',":
    "instruction: 'Al aplicar la división de potencias de igual base en \\$3^4\\$ \\\\div \\$3^2\\$, el resultado queda:',",

    # 3. medium_4_s3 options
    "options: ['La resta (\\$2 \\\\times 3\\$)\\$2 - 30\\$', 'La potencia (\\$2 \\\\times 3\\$)2', 'La multiplicación \\$2 \\\\times 3\\$', 'La suma entre bloques'],":
    "options: ['La resta \\$(2 \\\\times 3)^2 - 30\\$', 'La potencia \\$(2 \\\\times 3)^2\\$', 'La multiplicación \\$2 \\\\times 3\\$', 'La suma entre bloques'],",

    # 4. medium_5_s3 options
    "options: ['La potencia (\\$8 \\\\div 2\\$) 2', 'La división \\$8 \\\\div 2\\$', 'La resta (\\$8 \\\\div 2\\$) \\$2 - 12\\$', 'La suma entre bloques'],":
    "options: ['La potencia \\$(8 \\\\div 2)^2\\$', 'La división \\$8 \\\\div 2\\$', 'La resta \\$(8 \\\\div 2)^2 - 12\\$', 'La suma entre bloques'],",

    # 5. medium_6_s3 options
    "options: ['La potencia exterior(22)3', 'La propiedad de potencia de potencia', 'La división \\$50 \\\\div 5\\$', 'La resta'],":
    "options: ['La potencia exterior \\$(2^2)^3\\$', 'La propiedad de potencia de potencia', 'La división \\$50 \\\\div 5\\$', 'La resta'],",

    # 6. medium_6_s4 instruction
    "instruction: 'Al aplicar la propiedad de potencia de potencia en(22)3, el resultado queda:',":
    "instruction: 'Al aplicar la propiedad de potencia de potencia en \\$(2^2)^3\\$, el resultado queda:',",
}

count = 0
for k, v in replacements.items():
    k_norm = k.replace("\r\n", "\n")
    v_norm = v.replace("\r\n", "\n")
    if k_norm in content:
        content = content.replace(k_norm, v_norm)
        print(f"Replaced: {k_norm[:40]}... -> {v_norm[:40]}...")
        count += 1
    else:
        print(f"NOT FOUND: {k_norm[:40]}...")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Completed medium exercises corrections v2. Total replaced: {count}")
