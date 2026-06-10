import json

with open("scratch/parsed_exercises.json", "r", encoding="utf-8") as f:
    data = json.load(f)

for e in data:
    # Escribir solo ASCII o usar repr para evitar fallos de codificación en consola
    comp = e["complexity"]
    rom = e["roman"]
    pg = e["page"]
    ns = len(e["steps"])
    print(f"{comp} {rom} (Page {pg}) has {ns} steps")
