with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

pages = content.split("=== PAGE ")
target_pages = [75, 81, 87, 103, 111, 121, 136, 143]
out = []

for page in pages:
    if not page.strip():
        continue
    lines = page.split("\n")
    page_num = int(lines[0].split(" ===")[0].strip())
    if page_num in target_pages:
        out.append(f"=== PAGE {page_num} ===")
        for line in lines[1:8]:
            out.append(line)

with open("scratch/check_exercise_text.txt", "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(out))

print("Saved to scratch/check_exercise_text.txt")
