import json

with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    exercises = json.load(f)

# Find steps with exponents in options or correct answers
for ex in exercises:
    for step in ex['steps']:
        if step['options']:
            has_exponent = any('^' in opt for opt in step['options'])
            if has_exponent:
                print(f"Ex: {ex['id']}, Step: {step['id']}")
                print(f"  Inst: {step['instruction']}")
                print(f"  Opts: {step['options']}")
                print(f"  Correct: {step['correctAnswer']}")
                print(f"  Feedback: {step['feedbackError']}")
                print()
