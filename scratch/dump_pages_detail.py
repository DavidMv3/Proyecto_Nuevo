with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

pages = content.split("=== PAGE ")
target_pages = [75, 76, 81, 82, 87, 88, 103, 104, 111, 112, 121, 122, 136, 137, 143, 144]
out = []

for page in pages:
    if not page.strip():
        continue
    lines = page.split("\n")
    page_num = int(lines[0].split(" ===")[0].strip())
    if page_num in target_pages:
        out.append(f"=== PAGE {page_num} ===")
        for line in lines[1:35]:
            out.append(line)

with open("scratch/check_pages_detail.txt", "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(out))

print("Saved to scratch/check_pages_detail.txt")
