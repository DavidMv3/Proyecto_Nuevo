import re

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

pages = content.split("=== PAGE ")
output = []
for page in pages:
    if not page.strip():
        continue
    lines = page.split("\n")
    page_num = lines[0].split(" ===")[0].strip()
    page_text = "\n".join(lines[1:])
    
    # Check for complexity titles or Roman numerals
    for line in lines[1:]:
        if "Complejidad" in line or re.match(r'^[IVX]+\)', line.strip()):
            output.append(f"Page {page_num}: {line.strip()}")

with open("scratch/exercise_locations.txt", "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(output))
print("Done! Saved locations to scratch/exercise_locations.txt")
