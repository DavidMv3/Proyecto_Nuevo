import re

path = "lib/data/repositories/exercise_repository.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Find all occurrences of backslash followed by any character that is NOT:
# ' (quote), " (double quote), $ (dollar), n (newline), \ (backslash)
matches = re.findall(r'\\([^\'\"\$n\\])', content)
print("Unique backslash sequences found:", set(matches))
