import re

with open('lib/data/repositories/exercise_repository.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Buscamos "conservar" en general
matches = re.finditer(r"(id: '(.*?)',\s+(?:expressionOverride: '.*?',\s+)?instruction: '.*?(conservamos|conserva|conservar).*?')", content, re.IGNORECASE | re.DOTALL)
for m in matches:
    print(m.group(1))

