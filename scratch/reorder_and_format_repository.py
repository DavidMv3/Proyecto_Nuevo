import re

def main():
    file_path = 'lib/data/repositories/exercise_repository.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Part 1: Reorder _easyData so easy_1 is the first element
    # We will locate the _easyData array contents
    easy_data_match = re.search(r'static final List<ExerciseEntity> _easyData = \[(.*?)\];\s+// ==========================================\s+// NIVEL MEDIO', content, re.DOTALL)
    if not easy_data_match:
        print("Error: Could not find _easyData array in the repository file.")
        return

    easy_data_content = easy_data_match.group(1)

    # Let's extract each ExerciseEntity block from easy_data_content.
    # Each starts with ExerciseEntity(...)
    exercise_blocks = []
    # We can split by ExerciseEntity(
    parts = re.split(r'(ExerciseEntity\()', easy_data_content)
    
    # The first part is leading whitespace
    header = parts[0]
    
    # Reconstruct the blocks
    for i in range(1, len(parts), 2):
        block = parts[i] + parts[i+1]
        # Clean trailing commas/whitespace
        exercise_blocks.append(block)

    # Find easy_1 block
    easy_1_block = None
    other_blocks = []
    for block in exercise_blocks:
        if "id: 'easy_1'" in block:
            easy_1_block = block
        else:
            other_blocks.append(block)

    if not easy_1_block:
        print("Error: Could not find easy_1 block in _easyData.")
        return

    # Put easy_1 first
    reordered_blocks = [easy_1_block] + other_blocks
    
    # Reassemble reordered _easyData content
    # We want to format them nicely with double newlines
    new_easy_data_content = header + "\n\n    ".join([b.strip().rstrip(',') + ',' for b in reordered_blocks]) + "\n  "
    
    # Replace the old _easyData content with the new one
    old_full_easy_data = easy_data_match.group(0)
    new_full_easy_data = f"static final List<ExerciseEntity> _easyData = [{new_easy_data_content}];\n\n  // ==========================================\n  // NIVEL MEDIO"
    content = content.replace(old_full_easy_data, new_full_easy_data)

    # Part 2: Replace operators * and / with x and ÷
    # We will define a function to replace operators in target string literals in the Dart code
    # We want to find string literals like '...' or "..." and replace * and / in them
    # Specifically, inside instructions, options, feedback, overrides, and base expressions.
    # To be extremely safe, we can target specific fields:
    # - baseExpression: '...'
    # - expressionOverride: '...'
    # - instruction: '...'
    # - feedbackError: '...'
    # - options: [...]
    # - correctAnswer: '...'
    # - correctIds comments (like // 4(t0) *(t1) ...)
    
    def replacer(match):
        field_name = match.group(1)
        quote_char = match.group(2)
        string_val = match.group(3)
        
        # Replace * with x and / with ÷
        new_val = string_val
        new_val = new_val.replace(' * ', ' x ')
        new_val = new_val.replace(' / ', ' ÷ ')
        
        # Also replace standalone operators if they are surrounded by spaces
        # or inside mathematical context in the string
        # Let's replace * with x and / with ÷ in typical math strings
        # e.g. '18 + 3 * 5' -> '18 + 3 x 5'
        # e.g. '4 * 5 - 6 / 3' -> '4 x 5 - 6 ÷ 3'
        # e.g. '15 / 5' -> '15 ÷ 5'
        # e.g. '3 * 2' -> '3 x 2'
        # e.g. '4 * 8' -> '4 x 8'
        # e.g. '2 * 3' -> '2 x 3'
        # e.g. '2 * 7' -> '2 x 7'
        # e.g. '8 * 4' -> '8 x 4'
        # e.g. '2 * ( 5 + 4 / 2 )' -> '2 x ( 5 + 4 ÷ 2 )'
        # e.g. '7 ^ 8 / 7 ^ 6' -> '7 ^ 8 ÷ 7 ^ 6'
        
        # Let's do general replacements in these specific fields
        # Note: if it's correctIds, we don't match this pattern (it's not a field we parse this way, but we will handle it separately)
        new_val = re.sub(r'\b\*\b', 'x', new_val) # standalone *
        new_val = re.sub(r'\b/\b', '÷', new_val) # standalone /
        new_val = new_val.replace('*', 'x')
        new_val = new_val.replace('/', '÷')
        
        return f"{field_name}: {quote_char}{new_val}{quote_char}"

    # Target specific fields: baseExpression, expressionOverride, instruction, feedbackError, correctAnswer
    content = re.sub(r'\b(baseExpression|expressionOverride|instruction|feedbackError|correctAnswer)\s*:\s*([\'"])(.*?)\2', replacer, content)

    # Target options array items
    def options_replacer(match):
        options_block = match.group(0)
        # Replace * and / inside the options block
        options_block = options_block.replace(' * ', ' x ').replace('*', 'x')
        options_block = options_block.replace(' / ', ' ÷ ').replace('/', '÷')
        return options_block

    content = re.sub(r'options\s*:\s*\[.*?\]', options_replacer, content, flags=re.DOTALL)

    # Replace operators in the comments of correctIds (like t9 and t11 comments)
    content = content.replace('*(t1)', 'x(t1)').replace('/(t4)', '÷(t4)').replace('*(t11)', 'x(t11)')
    content = content.replace('/(t4)', '÷(t4)').replace('*(t7)', 'x(t7)').replace('/(t25)', '÷(t25)').replace('*(t19)', 'x(t19)')
    content = content.replace('*(t5)', 'x(t5)').replace('*(t11)', 'x(t11)').replace('/(t13)', '÷(t13)')
    content = content.replace('El \'+\' en \'2 + 3 * 4\'', 'El \'+\' en \'2 + 3 x 4\'')
    content = content.replace('\'3 * 4\'', '\'3 x 4\'')

    # Also clean up double spaces if any was created
    # Write the modified content back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Success: Repository file updated successfully!")

if __name__ == '__main__':
    main()
