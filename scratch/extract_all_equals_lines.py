import json

with open("scratch/parsed_ranges.json", "r", encoding="utf-8") as f:
    data = json.load(f)

with open("scratch/pdf_text.txt", "r", encoding="utf-8") as f:
    pdf_text = f.read()

pages = pdf_text.split("=== PAGE ")
page_dict = {}
for p in pages:
    if not p.strip():
        continue
    lines = p.split("\n")
    p_num = int(lines[0].split(" ===")[0].strip())
    p_text = "\n".join(lines[1:])
    page_dict[p_num] = p_text

ranges = {
    ("medium", "II"): (44, 48),
    ("medium", "III"): (49, 53),
    ("medium", "IV"): (54, 58),
    ("medium", "V"): (59, 63),
    ("medium", "VI"): (64, 69),
    ("medium", "VII"): (70, 74),
    ("medium", "VIII"): (75, 80),
    ("medium", "IX"): (81, 86),
    ("medium", "X"): (87, 93),
    
    ("hard", "I"): (94, 99),
    ("hard", "II"): (100, 102),
    ("hard", "III"): (103, 110),
    ("hard", "IV"): (111, 115),
    ("hard", "V"): (116, 120),
    ("hard", "VI"): (121, 125),
    ("hard", "VII"): (126, 135),
    ("hard", "VIII"): (136, 142),
    ("hard", "IX"): (143, 152),
}

out = []
for (lvl, rom), (start, end) in ranges.items():
    out.append(f"=== {lvl.upper()} {rom} (Pages {start}-{end}) ===")
    seen_eqs = []
    for p in range(start, end + 1):
        if p not in page_dict:
            continue
        for line in page_dict[p].split("\n"):
            line_str = line.strip()
            if line_str.startswith("=") or line_str.startswith("II)") or line_str.startswith("III)") or line_str.startswith("IV)") or line_str.startswith("V)") or line_str.startswith("VI)") or line_str.startswith("VII)") or line_str.startswith("VIII)") or line_str.startswith("IX)") or line_str.startswith("X)"):
                if line_str not in seen_eqs:
                    seen_eqs.append(line_str)
                    out.append(f"  {line_str}")

with open("scratch/all_equations.txt", "w", encoding="utf-8") as f_out:
    f_out.write("\n".join(out))

print("Saved to scratch/all_equations.txt")
