import re

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace single backslash before times, div, sqrt with double backslash
new_content, count = re.subn(r'(?<!\\)\\(times|div|sqrt)', r'\\\\\1', content)

print(f"Number of replacements made: {count}")

with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("Finished escaping LaTeX backslashes!")
