import re
import sys
sys.stdout.reconfigure(encoding='utf-8')

with open('scratch/pdf_text.txt', 'r', encoding='utf-8') as f:
    pdf_text = f.read()

pages = pdf_text.split('--- PAGE ')
page_dict = {}
for p in pages:
    if not p.strip(): continue
    lines = p.split('\n')
    p_num = int(lines[0].split(' ---')[0].strip())
    p_text = '\n'.join(lines[1:])
    page_dict[p_num] = p_text

ex_text_parts = []
for p in range(15, 18 + 1):
    if p in page_dict:
        ex_text_parts.append(page_dict[p])

full_ex_text = '\n'.join(ex_text_parts)

for match in re.finditer(r'(?:^|\n)(\d+)\)\s*(.*?)(?=\n\d+\)|$)', full_ex_text, re.DOTALL):
    step_num = int(match.group(1))
    if step_num == 7:
        step_content = match.group(2)
        print('STEP CONTENT:')
        print(repr(step_content))
        over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)(?=\n\d+\)|$)', step_content, re.DOTALL)
        if over_match:
            print('MATCHED:', repr(over_match.group(1)))
        else:
            print('NO MATCH')
