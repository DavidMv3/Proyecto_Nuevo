import json

with open('scratch/sequential_mismatches.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Write directly to comparison output with UTF-8 encoding
with open('scratch/mismatches_summary.txt', 'w', encoding='utf-8') as out:
    out.write(f"Total mismatches: {len(data)}\n")
    for i, m in enumerate(data):
        first_pdf_line = m['pdf_instruction'].split('\n')[0] if m['pdf_instruction'] else ""
        out.write(f"\n--- {i+1} ---\n")
        out.write(f"Ex: {m['ex_id']}, Step Num: {m['step_num']}\n")
        out.write(f"  Dart Inst: {m['dart_instruction']}\n")
        out.write(f"  PDF Inst:  {first_pdf_line}\n")
        out.write(f"  Dart Opts: {m['dart_options']}\n")
        out.write(f"  PDF Opts:  {m['pdf_options']}\n")
        out.write(f"  Dart Correct: {m['dart_correct']}\n")
        out.write(f"  PDF Correct:  {m['pdf_correct']}\n")

print("Saved mismatches to scratch/mismatches_summary.txt")
