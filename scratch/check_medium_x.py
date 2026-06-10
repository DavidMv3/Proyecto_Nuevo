with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    content = f.read()

idx = content.find("X) [")
if idx != -1:
    with open("scratch/check_medium_x.txt", "w", encoding="utf-8") as f_out:
        f_out.write(content[idx:idx+8000])
    print("Saved to scratch/check_medium_x.txt")
else:
    print("Not found")
