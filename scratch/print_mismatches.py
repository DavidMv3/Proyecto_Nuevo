import json

with open('scratch/sequential_mismatches.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total mismatches: {len(data)}")
for i, m in enumerate(data[:10]):
    print(f"\n--- Mismatch {i+1} ---")
    print(f"Ex: {m['ex_id']}, Step: {m['step_id']}")
    print(f"Dart Inst: {m['dart_instruction']}")
    print(f"PDF Inst: {m['pdf_instruction']}")
    print(f"Dart Correct: {m['dart_correct']}")
    print(f"PDF Correct: {m['pdf_correct']}")
    print(f"Dart Opts: {m['dart_options']}")
    print(f"PDF Opts: {m['pdf_options']}")
