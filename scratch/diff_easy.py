import sys

with open('scratch/repo_head_utf8.dart', encoding='utf-8') as f:
    head = f.read()

with open('lib/data/repositories/exercise_repository.dart', encoding='utf-8') as f:
    local = f.read()

# Let's extract _easyData from both
def get_easy_data(content):
    start = content.find("static final List<ExerciseEntity> _easyData")
    end = content.find("static final List<ExerciseEntity> _mediumData")
    if end == -1:
        end = content.find("List<ExerciseEntity> get easyExercises")
    return content[start:end]

head_easy = get_easy_data(head)
local_easy = get_easy_data(local)

if head_easy == local_easy:
    print("Easy data is identical")
else:
    print("Easy data differs!")
    # Let's print the line diff or check where it differs
    import difflib
    diff = list(difflib.unified_diff(head_easy.splitlines(), local_easy.splitlines(), n=1))
    for line in diff[:100]:
        print(line)
