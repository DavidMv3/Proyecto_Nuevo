import re

with open('lib/data/repositories/exercise_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# easy_1 is currently 18 + ... -> should become easy_2
# easy_2 is currently 8 - ... -> should become easy_3
# easy_3 is currently 4 * ... -> should become easy_1

# Step 1: easy_1 -> temp_1
text = re.sub(r'easy_1', 'temp_1', text)
text = re.sub(r'Nivel Fácil 1', 'Nivel Fácil TEMP1', text)

# Step 2: easy_2 -> easy_3
text = re.sub(r'easy_2', 'easy_3', text)
text = re.sub(r'Nivel Fácil 2', 'Nivel Fácil 3', text)

# Step 3: easy_3 (the 4*5 one) -> easy_1
text = re.sub(r'easy_3', 'easy_1', text)
text = re.sub(r'Nivel Fácil 3', 'Nivel Fácil 1', text)

# Step 4: temp_1 -> easy_2
text = re.sub(r'temp_1', 'easy_2', text)
text = re.sub(r'Nivel Fácil TEMP1', 'Nivel Fácil 2', text)

with open('lib/data/repositories/exercise_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Swapped!")
