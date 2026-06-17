import json

with open('extracted_exercises.json', 'r', encoding='utf-8') as f:
    exercises = json.load(f)

# Output a markdown file for easy review
with open('scratch/all_exercises_review.md', 'w', encoding='utf-8') as f:
    f.write("# Review of All Exercises and Steps\n\n")
    for ex in exercises:
        f.write(f"## {ex['id']} - {ex['title']} (Expression: `{ex['baseExpression']}`)\n\n")
        for step in ex['steps']:
            f.write(f"### Step: `{step['id']}`\n")
            f.write(f"- **Instruction:** {step['instruction']}\n")
            if step['options']:
                f.write(f"- **Options:** {step['options']}\n")
                f.write(f"- **Correct Answer:** `{step['correctAnswer']}`\n")
            else:
                f.write("- *No multiple-choice options (interactive step)*\n")
            if step['feedbackError']:
                f.write(f"- **Feedback Error:** {step['feedbackError']}\n")
            f.write("\n")

print("Saved review markdown to scratch/all_exercises_review.md")
