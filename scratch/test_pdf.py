import sys
sys.stdout.reconfigure(encoding='utf-8')
with open('scratch/pdf_text.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, l in enumerate(lines):
    if '47 ---' in l:
        start = max(0, i - 3)
        end = min(len(lines), i + 4)
        print(''.join(lines[start:end]))
