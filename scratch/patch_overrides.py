import re

with open('lib/data/repositories/exercise_repository.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# easy_1 (18 + 3 * 5)
# easy_1_s4: Conservar el número -> '18 + ____'
content = content.replace(
    "id: 'easy_1_s4',\n          instruction: 'Cuando en un bloque no hay",
    "id: 'easy_1_s4',\n          expressionOverride: '18 + ____',\n          instruction: 'Cuando en un bloque no hay"
)

# easy_2 (8 - 3 * 2 + 1)
# easy_2_s3: Conservar el primero y el tercero -> '8 - ____ + 1'
content = content.replace(
    "id: 'easy_2_s3',\n          instruction: 'Los bloques en los que se deben conservar",
    "id: 'easy_2_s3',\n          expressionOverride: '8 - ____ + 1',\n          instruction: 'Los bloques en los que se deben conservar"
)

# easy_3 (4 * 5 - 6 / 3)
# easy_3_s3: El resultado de la multiplicacion del primer bloque es -> '20 - 6 / 3' (Ya lo tiene!)
# wait! easy_3_s3 is "El resultado...". WHEN they click, it drops down to 20 - 6 / 3!
# But wait, BEFORE they answer it, it should just be 4 * 5 - 6 / 3.
# The user wants the number to drop down AFTER they select "conservar el numero"!
# So for easy_3, it's already perfectly structured: when they answer "20", it drops down "20 - 6 / 3".
# Is there any "Conservar el número" in easy_3? No! Both blocks are operations.

# easy_4 (10 - 3 * 2 + 2 ^ 3)
# easy_4_s3: Los bloques en los que se deben conservar los números son:
# Respuesta: El primero -> '10 - ____ + 2 ^ 3'
content = content.replace(
    "id: 'easy_4_s3',\n          instruction: 'Los bloques en los",
    "id: 'easy_4_s3',\n          expressionOverride: '10 - ____ + ____',\n          instruction: 'Los bloques en los"
)
# WAIT! "El primero" is conserved. So 10 - ____ + 2 ^ 3.
# Let's check easy_4_s3

# Let's check easy_5 (1 + 12 / 4 - 1 + 2 ^ 3)
# easy_5_s3: Los bloques en los que se deben conservar los números son:
# Respuesta: El primero y el tercero. -> '1 + ____ - 1 + ____'
content = content.replace(
    "id: 'easy_5_s3',\n          instruction: 'Los bloques en los",
    "id: 'easy_5_s3',\n          expressionOverride: '1 + ____ - 1 + ____',\n          instruction: 'Los bloques en los"
)

# easy_6 (3 - 2 + [ 8 - 2 * 3 ])
# easy_6_s4: Los bloques en los que se deben conservar los números son:
# Respuesta: El primero y el segundo -> '3 - 2 + ____'
content = content.replace(
    "id: 'easy_6_s4',\n          instruction: 'Los bloques en los",
    "id: 'easy_6_s4',\n          expressionOverride: '3 - 2 + ____',\n          instruction: 'Los bloques en los"
)

# easy_7 (6 - 4 / 2 + [ 3 ^ 2 - 1 ])
# easy_7_s4: Los bloques en los que se deben conservar los números son:
# Respuesta: El primero -> '6 - ____ + ____'
content = content.replace(
    "id: 'easy_7_s4',\n          instruction: 'Los bloques en los",
    "id: 'easy_7_s4',\n          expressionOverride: '6 - ____ + ____',\n          instruction: 'Los bloques en los"
)

# easy_8 (8 / 2 + 5 * 2 - [ 5 ^ 2 - 5 ])
# easy_8 has NO conservar el numero! All blocks have operations!

# easy_9 (12 - 4 * 2 + [ sqrt( 25 ) + 2 ])
# easy_9_s4: Conservar el número -> El primero -> '12 - ____ + ____'
content = content.replace(
    "id: 'easy_9_s4',\n          instruction: 'Los bloques en los",
    "id: 'easy_9_s4',\n          expressionOverride: '12 - ____ + ____',\n          instruction: 'Los bloques en los"
)

# easy_10 ([ 4 + 1 ] * 2 - [ 6 + 1 ] + 4 * 2 ^ 3)
# easy_10_s4: Conservar el numero -> No hay conservar el numero here, I think.

with open('lib/data/repositories/exercise_repository.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Patched easy levels!")
