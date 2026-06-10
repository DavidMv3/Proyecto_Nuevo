import re

text = """6) En el tercer bloque, ¿qué se debe realizar primero?
a) Las potencias
b) La división
c) La propiedad de la división de potencias de igual base
Solución. La respuesta correcta es c) La propiedad de la división de potencias de
igual base.
En caso de que el estudiante seleccione cualquiera de las otras opciones, debe
desplegarse la palabra incorrecto, junto con la retroalimentación: Cuando se
presenta una división de potencias de igual base, primero se aplica la propiedad
correspondiente: se conserva la base y se restan los exponentes."""

options = [
    'Las potencias',
    'La división',
    'La propiedad de la división de potencias de igual base'
]

sol_match = re.search(r'Solución\.\s*(.*?)(?=\nDebe aparecer|\nEn caso de|$)', text, re.DOTALL)
if sol_match:
    sol_text = sol_match.group(1).strip()
    print("sol_text:", repr(sol_text))
    
    ans_match = re.search(r'(?:correcta es|correcta es:)\s*([a-d1-4])\)\s*(.*?)(?:\.|$)', sol_text)
    if ans_match:
        letter = ans_match.group(1)
        desc = ans_match.group(2).strip()
        print("letter:", letter)
        print("desc:", repr(desc))
        
        matched_option = None
        for opt in options:
            if opt.startswith(desc) or desc.startswith(opt) or (len(opt) > 2 and opt[2:].strip() == desc):
                matched_option = opt
                break
        print("matched_option:", matched_option)
    else:
        print("ans_match not found")
else:
    print("sol_match not found")
