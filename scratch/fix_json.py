def main():
    path = "assets/exercises.json"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    replacements = {
        'En el producto de potencias de igual base, se conserva la base y se suman los exponentes$/$3$+$2 = 5':
        'En el producto de potencias de igual base, se conserva la base y se suman los exponentes: $3 + 2 = 5$.',
        
        'En la división de potencias de igual base, se conserva la base y se restan los exponentes$/$$4 - 2$ = 2':
        'En la división de potencias de igual base, se conserva la base y se restan los exponentes: $4 - 2 = 2$.',

        'Al dividir potencias de igual base se restan los exponentes$/$$76-5$ = 7':
        'Al dividir potencias de igual base se restan los exponentes: $6 - 5 = 1$ (obteniendo $7^1 = 7$).',

        '"La suma 8$1 + 2$$$"': '"La suma $81 + 2$"',
        'La suma 8$1 + 2$$$': 'La suma $81 + 2$',
        'Al volver a observar de izquierda a derecha, en el primer bloque queda pendiente la suma interna 8$1 + 2$$$':
        'Al volver a observar de izquierda a derecha, en el primer bloque queda pendiente la suma interna $81 + 2$.',
        'El resultado de la suma 8$1 + 2$$$ es:': 'El resultado de la suma $81 + 2$ es:',
        'El resultado de la suma 8$1 + 2$$$ es $83$,': 'El resultado de la suma $81 + 2$ es $83$.',
        'El resultado de la suma 8$1 + 2$$$ es $83$': 'El resultado de la suma $81 + 2$ es $83$.'
    }

    count = 0
    for k, v in replacements.items():
        if k in content:
            content = content.replace(k, v)
            print(f"Replaced: {k[:30]}... -> {v[:30]}...")
            count += 1
        else:
            print(f"NOT FOUND: {k[:30]}...")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Successfully fixed {count} typos in assets/exercises.json!")

if __name__ == "__main__":
    main()
