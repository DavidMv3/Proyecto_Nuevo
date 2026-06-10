import re

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    text = f.read()

pages = text.split("=== PAGE ")

# Queremos imprimir de la página 44 a la 93 (que corresponden a Complejidad Media II a X)
with open("scratch/medium_steps.txt", "w", encoding="utf-8") as out:
    for i in range(44, 94):
        if i < len(pages):
            out.write(f"\n=== PAGE {i} ===\n")
            lines = pages[i].split("\n")
            for line in lines[1:]:
                line = line.strip()
                # Filtrar líneas vacías o de relleno
                if not line:
                    continue
                if any(phrase in line for phrase in ["En caso de que el estudiante", "desplegarse la palabra incorrecto", "retroalimentación:", "Una vez que el estudiante"]):
                    continue
                out.write(line + "\n")

print("Done! Medium steps written to scratch/medium_steps.txt")
