with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

pages = content.split("=== PAGE ")
out = []
for page in pages:
    if not page.strip():
        continue
    lines = page.split("\n")
    page_num = int(lines[0].split(" ===")[0].strip())
    if page_num in [44, 45, 46]:
        out.append(f"--- PAGE {page_num} ---")
        for line in lines[1:50]:  # print first 50 lines of each page
            out.append(line)

with open("scratch/dump_pages.txt", "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(out))
print("Done! Saved to scratch/dump_pages.txt")
