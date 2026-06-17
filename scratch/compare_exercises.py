import re
import json
import sys

# Load the extracted exercises from dart
with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    dart_exercises = json.load(f)

# Load the PDF text
with open('pdf_text.txt', 'r', encoding='utf-8') as f:
    pdf_text = f.read()

# Let's clean math strings for comparison (remove LaTeX formatting, backslashes, spaces, convert multiplication/division symbols)
def clean_string(s):
    if not s:
        return ""
    # Convert latex tags
    s = s.replace('\\$', '').replace('$', '')
    s = s.replace('\\times', '×').replace('\\div', '÷').replace(':', '÷')
    s = s.replace('\\sqrt', '√')
    # Remove braces
    s = re.sub(r'\{([^}]+)\}', r'\1', s)
    s = re.sub(r'\[([^\]]+)\]', r'\1', s)
    # Remove spaces and normalize exponents
    s = s.replace('^', '')
    s = "".join(s.split()).lower()
    return s

# Write output to comparison_output.txt with utf-8 encoding
with open('scratch/comparison_output.txt', 'w', encoding='utf-8') as out:
    for ex in dart_exercises:
        ex_id = ex['id']
        out.write(f"\n========================================\nEXERCISE: {ex_id} ({ex['baseExpression']})\n========================================\n")
        
        for step in ex['steps']:
            if not step['options']:
                continue
                
            out.write(f"Step ID: {step['id']}\n")
            out.write(f"  Instruction: {step['instruction']}\n")
            out.write(f"  Options: {step['options']}\n")
            out.write(f"  Correct Answer: {step['correctAnswer']}\n")
            out.write(f"  Feedback: {step['feedbackError']}\n")
            
            # Clean instruction to search
            # Keep only alphanumeric and spaces for search
            clean_search_inst = re.sub(r'[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ ]', '', step['instruction'])
            short_inst = clean_search_inst[:40].strip()
            
            if short_inst:
                # Create a regex with wildcard between words
                words = short_inst.split()
                regex_pattern = ".*".join(re.escape(w) for w in words)
                matches = list(re.finditer(regex_pattern, pdf_text, re.IGNORECASE))
                if matches:
                    # Let's take the first match and print the surrounding text
                    pos = matches[0].start()
                    surr = pdf_text[pos:pos+500]
                    out.write("  --- Matches PDF Text: ---\n")
                    lines = surr.split('\n')[:10]
                    out.write("\n".join("    " + line for line in lines) + "\n")
                    out.write("  -------------------------\n")
                else:
                    out.write("  --- No direct match found in PDF text ---\n")
            else:
                out.write("  --- Empty instruction for search ---\n")
            out.write("\n")

print("Saved output to scratch/comparison_output.txt")
