# -*- coding: utf-8 -*-
import re
import sys
sys.stdout.reconfigure(encoding='utf-8')

step_content = '''Solución. La respuesta correcta es c) 1
En caso de que el estudiante seleccione cualquier otra opción, debe desplegarse la
palabra incorrecto, junto con la retroalimentación: El resultado de la resta3 − 2
es 1.
Debe aparecer:
3 − 2 + [8−2×3] =
= 1 + [8 −2×3]
'''
over_match = re.search(r'(?:Debe aparecer|debe aparecer la expresión aritmética de la siguiente manera:|Debe aparecer ahora lo siguiente:)\s*(.*?)(?=\n\d+\)|$)', step_content, re.DOTALL)
print(repr(over_match.group(1)))
