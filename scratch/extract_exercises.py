import re
import sys

# Reconfigure stdout to support UTF-8 on Windows console
sys.stdout.reconfigure(encoding='utf-8')

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    text = f.read()

# Find all occurrences of Roman numeral exercises under each complexity section
sections = text.split("0.1 Complejidad Baja")
baja_section = sections[1].split("0.2 Complejidad Media")[0]
sections_media = sections[1].split("0.2 Complejidad Media")
media_section = sections_media[1].split("0.3 Complejidad Alta")[0]
alta_section = sections_media[1].split("0.3 Complejidad Alta")[1]

def find_exercises(sec_text):
    # Matches roman numerals followed by parenthesis at the start of a line
    # Wait, the PDF might have different spaces or symbols. Let's make it flexible.
    matches = re.finditer(r'^([IVX]+)\)\s*(.*?)\s*=\s*(?:\(Colocar|$)', sec_text, re.MULTILINE)
    results = []
    for m in matches:
        results.append((m.group(1), m.group(2).strip()))
    return results

print("=== BAJA ===")
for r, eq in find_exercises(baja_section):
    print(f"{r}: {eq}")

print("\n=== MEDIA ===")
for r, eq in find_exercises(media_section):
    print(f"{r}: {eq}")

print("\n=== ALTA ===")
for r, eq in find_exercises(alta_section):
    print(f"{r}: {eq}")
