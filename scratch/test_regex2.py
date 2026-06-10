# -*- coding: utf-8 -*-
import re
import sys
sys.stdout.reconfigure(encoding='utf-8')

step_content = '''7) El resultado de las operaciones internas es:
a) 2
b) 9
c) 5
d) 4
Solución. La respuesta correcta es a) 2
En caso de que el estudiante seleccione otra opción, debe desplegarse la palabra
incorrecto, junto con la retroalimentación: El resultado de la resta8 − 6 es 2.


18 ---
Debe aparecer:
3 − 2 + [8−2×3] =
= 1 + [8 −2×3]
= 1 + [8 − 6]
= 1 + [2]
'''

over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)(?=\n\d+\)|$)', step_content, re.DOTALL)
if over_match:
    over_lines = over_match.group(1).strip().split('\n')
    last_valid = None
    for ol in over_lines:
        ol = ol.strip()
        if not ol: continue
        if "---" in ol: continue
        if re.match(r'^[a-d1-4]\)', ol): continue
        if any(c in ol for c in ["+", "-", "*", "/", "sqrt", "root", "^", "[", "(", "{", "=", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]):
            last_valid = ol
            print(f"valid: {ol}")
    if last_valid:
        override = last_valid
        if override.startswith("="):
            override = override[1:].strip()
        print(f"Final override: {override}")
    else:
        print("last_valid is None")
else:
    print("No over_match")
