import re

with open('lib/data/repositories/exercise_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# I want to swap only the ids and titles:
# easy_1 -> level2_id
# Nivel Fácil 1 -> level2_title

# Function to isolate and replace carefully
def swap():
    global text
    # Swap easy_1 -> swap_2
    text = re.sub(r'easy_1', 'swap_2', text)
    text = re.sub(r'Nivel Fácil 1', 'Nivel Fácil SWAP2', text)
    
    # Swap easy_2 -> swap_3
    text = re.sub(r'easy_2', 'swap_3', text)
    text = re.sub(r'Nivel Fácil 2', 'Nivel Fácil SWAP3', text)
    
    # Swap easy_3 -> swap_1
    text = re.sub(r'easy_3', 'swap_1', text)
    text = re.sub(r'Nivel Fácil 3', 'Nivel Fácil SWAP1', text)
    
    # Now finalize
    text = re.sub(r'swap_2', 'easy_2', text)
    text = re.sub(r'Nivel Fácil SWAP2', 'Nivel Fácil 2', text)
    
    text = re.sub(r'swap_3', 'easy_3', text)
    text = re.sub(r'Nivel Fácil SWAP3', 'Nivel Fácil 3', text)
    
    text = re.sub(r'swap_1', 'easy_1', text)
    text = re.sub(r'Nivel Fácil SWAP1', 'Nivel Fácil 1', text)

swap()

with open('lib/data/repositories/exercise_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Swapped successfully!")
