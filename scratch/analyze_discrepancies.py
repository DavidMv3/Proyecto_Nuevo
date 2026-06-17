import json
import re

# Load the extracted exercises from dart
with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    dart_exercises = json.load(f)

# Load the PDF text
with open('pdf_text.txt', 'r', encoding='utf-8') as f:
    pdf_text = f.read()

def normalize_val(s):
    if not s:
        return ""
    # strip LaTeX
    s = s.replace('\\$', '').replace('$', '').replace('{', '').replace('}', '')
    s = s.replace('\\times', '×').replace('\\div', '÷').replace(':', '÷').replace('\\sqrt', '√')
    s = s.replace('[', '').replace(']', '')
    # replace superscript numbers with normal numbers for some exponents if LaTeX was used
    # e.g. 2^3 -> 23 or 2^3
    s = s.replace('^', '')
    # strip spacing
    s = "".join(s.split()).lower()
    return s

# Let's search the PDF text for questions.
# The PDF text has numbered questions like "2) ¿En cuántos bloques..." or "3) El resultado...".
# Let's parse each page or search sequentially.
# For each exercise, we can find its base expression, and then search for questions below it.

# Let's write a parser that extracts all multiple choice questions from the PDF text.
# A question in PDF text is of the form:
# N) [Question text]
# a) [Opt A]
# b) [Opt B]
# c) [Opt C]
# d) [Opt D]
# Solución. La respuesta correcta es ...

# Let's find all question blocks using regex:
pattern = r"(\d+)\)\s*(.*?)\n\s*a\)\s*(.*?)\n\s*b\)\s*(.*?)\n\s*c\)\s*(.*?)\n\s*d\)\s*(.*?)\n\s*Solución\."
# Wait, some questions might only have 2 options (like Verdadero/Falso or 1), 2)), or 3 options.
# Let's write a regex that matches question number, followed by options, followed by Solución.

# Let's do a more flexible search:
# We find all segments starting with "N)" and ending with "Solución."
q_blocks = []
for match in re.finditer(r"(\d+)\)\s*(.*?)(?=Solución\.)", pdf_text, re.DOTALL):
    q_num = match.group(1)
    body = match.group(2)
    # Extract options: a), b), c), d) or 1), 2), 3), 4)
    opts = []
    # Try a), b), c), d)
    opt_matches = re.findall(r"\b([a-d])\)\s*(.*?)(?=\b[a-d]\)|\n|$)", body, re.DOTALL)
    if opt_matches:
        opts = [m[1].strip() for m in opt_matches]
    else:
        # Try 1), 2), 3), 4)
        opt_matches = re.findall(r"\b([1-4])\)\s*(.*?)(?=\b[1-4]\)|\n|$)", body, re.DOTALL)
        if opt_matches:
            opts = [m[1].strip() for m in opt_matches]
            
    # Also find correct answer in Solución
    # The solution block is after this match
    sol_start = match.end()
    sol_end = pdf_text.find('\n', sol_start + 100) # read a bit
    sol_text = pdf_text[sol_start:sol_start+150]
    # Extract correct option or correct answer text
    # e.g., "La respuesta correcta es d) 2" or "b) 33"
    correct_opt = ""
    correct_text = ""
    correct_match = re.search(r"correcta\s+es\s+([a-d1-4])\)?\s*(.*)", sol_text, re.IGNORECASE)
    if correct_match:
        correct_opt = correct_match.group(1)
        correct_text = correct_match.group(2).split('\n')[0].strip()
    
    q_blocks.append({
        'q_num': q_num,
        'body': body.split('\n')[0].strip(),
        'options': opts,
        'correct_opt': correct_opt,
        'correct_text': correct_text,
        'full_text': match.group(0) + sol_text
    })

print(f"Parsed {len(q_blocks)} questions from PDF text.")

# Now let's try to match each step in our JSON with a parsed question in the PDF.
# We'll match by comparing the normalized instruction text.
mismatches = []
for ex in dart_exercises:
    for step in ex['steps']:
        if not step['options']:
            continue
        
        # Search for a question in q_blocks that matches
        norm_inst = normalize_val(step['instruction'])
        # Find best match in PDF
        best_match = None
        best_score = 0
        for q in q_blocks:
            norm_body = normalize_val(q['body'])
            # Calculate overlapping characters or check if one is inside the other
            if norm_inst in norm_body or norm_body in norm_inst:
                best_match = q
                break
        
        if not best_match:
            # Try fuzzy matching using words
            words_inst = set(normalize_val(step['instruction']).split())
            for q in q_blocks:
                words_body = set(normalize_val(q['body']).split())
                score = len(words_inst.intersection(words_body))
                if score > best_score:
                    best_score = score
                    best_match = q
            if best_score < 2:
                best_match = None
                
        if best_match:
            # Compare options
            norm_dart_opts = sorted([normalize_val(o) for o in step['options']])
            norm_pdf_opts = sorted([normalize_val(o) for o in best_match['options']])
            
            # Since some options might be missing from PDF parse or have minor OCR noise,
            # let's see if the correct answer matches or if there is a real difference in numbers
            dart_correct = normalize_val(step['correctAnswer'])
            pdf_correct = normalize_val(best_match['correct_text'])
            
            # If the correct answer doesn't match, or if the option lists are very different
            # (e.g. they don't contain the correct answer or contain different numbers)
            is_different = False
            if dart_correct != pdf_correct and pdf_correct != "":
                # Check if they are equivalent (like 7^2 vs 49, but here we expect same text representation)
                # Let's flag it if they differ
                is_different = True
            
            # Check if all elements of pdf_opts are close to dart_opts
            # We want to be sure that the numbers in the options are the same
            # Let's flag if the options count is different and they are not subset
            if len(step['options']) != len(best_match['options']):
                # Only flag if not a sub-match or if options are totally different
                is_different = True
            else:
                # Check if they match
                for d_opt in norm_dart_opts:
                    # find closest in norm_pdf_opts
                    if not any(d_opt in p_opt or p_opt in d_opt for p_opt in norm_pdf_opts):
                        is_different = True
                        break
            
            if is_different:
                mismatches.append({
                    'ex_id': ex['id'],
                    'step_id': step['id'],
                    'dart_instruction': step['instruction'],
                    'pdf_instruction': best_match['body'],
                    'dart_options': step['options'],
                    'pdf_options': best_match['options'],
                    'dart_correct': step['correctAnswer'],
                    'pdf_correct_text': best_match['correct_text'],
                    'pdf_correct_opt': best_match['correct_opt']
                })
        else:
            print(f"Could not find PDF question for {ex['id']} - {step['id']} ({step['instruction'][:30]}...)")

print(f"\nFound {len(mismatches)} potential mismatches:")
for m in mismatches:
    print(json.dumps(m, indent=2, ensure_ascii=False))
