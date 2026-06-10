import re

with open('scratch/repo_head_utf8.dart', encoding='utf-8') as f:
    content = f.read()

idx = content.find("id: 'hard_1'")
if idx != -1:
    print(content[idx:idx+8000])
else:
    print("hard_1 not found")
