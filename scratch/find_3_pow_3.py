import json

with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    exercises = json.load(f)

for ex in exercises:
    for step in ex['steps']:
        # check if '3^3' or '3³' or similar is in options or correctAnswer or feedbackError
        # also check if the number 33 was replaced
        has_issue = False
        text_to_check = str(step['options']) + " " + step['correctAnswer'] + " " + step['feedbackError']
        if '3^3' in text_to_check or '3³' in text_to_check:
            has_issue = True
            
        if has_issue:
            print(f"Ex: {ex['id']}, Step: {step['id']}")
            print(f"  Inst: {step['instruction']}")
            print(f"  Opts: {step['options']}")
            print(f"  Correct: {step['correctAnswer']}")
            print(f"  Feedback: {step['feedbackError']}")
            print()
