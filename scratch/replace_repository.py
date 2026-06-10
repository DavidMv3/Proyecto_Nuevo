import re

# Read the original repository file
repo_path = "lib/data/repositories/exercise_repository.dart"
with open(repo_path, "r", encoding="utf-8") as f:
    repo_content = f.read()

# Extract the old hard_1 exercise (lines 1021 to 1234 in the original file)
# We can find it using a regex targeting the ExerciseEntity with id: 'hard_1'
# up to the end of the list matching.
hard_1_match = re.search(r"\s+ExerciseEntity\(\s+id:\s+'hard_1',.*?\n\s+\),\s+(?=\s+\];\s+// Getters|\s+\];\s+\n\s+// Getters)", repo_content, re.DOTALL)
if not hard_1_match:
    # Try a broader regex
    hard_1_match = re.search(r"ExerciseEntity\(\s+id:\s+'hard_1',.*?\n\s+\),", repo_content, re.DOTALL)

if not hard_1_match:
    raise ValueError("Could not find the old hard_1 exercise in the repository content!")

old_hard_1_str = hard_1_match.group(0)

# Rename old hard_1 to hard_10
old_hard_1_str = old_hard_1_str.replace("id: 'hard_1'", "id: 'hard_10'")
old_hard_1_str = old_hard_1_str.replace("title: 'Nivel Difícil 1'", "title: 'Nivel Difícil 10'")
# Rename all step IDs: hard_1_s1 to hard_10_s1, etc.
old_hard_1_str = re.sub(r"id:\s+'hard_1_s(\d+)'", r"id: 'hard_10_s\1'", old_hard_1_str)

# Read the generated exercises
with open("scratch/dart_repository_code.txt", "r", encoding="utf-8") as f:
    generated_code = f.read()

# Split generated code into Medium and Hard parts
medium_part = generated_code.split("=== MEDIUM EXERCISES ===\n\n")[1].split("\n\n=== HARD EXERCISES ===\n\n")[0]
hard_part = generated_code.split("\n\n=== HARD EXERCISES ===\n\n")[1]

# Now let's extract the first part of exercise_repository.dart (up to _mediumData list start)
medium_start_idx = repo_content.find("static final List<ExerciseEntity> _mediumData = [")
if medium_start_idx == -1:
    raise ValueError("Could not find static final List<ExerciseEntity> _mediumData = [")

first_part = repo_content[:medium_start_idx]

# Extract medium_1 exercise
# It starts right after the opening bracket of _mediumData
medium_1_start_idx = repo_content.find("ExerciseEntity(", medium_start_idx)
# And ends before the closing bracket of _mediumData
medium_end_idx = repo_content.find("];", medium_1_start_idx)
medium_1_str = repo_content[medium_1_start_idx:medium_end_idx].strip()
if medium_1_str.endswith(","):
    medium_1_str = medium_1_str[:-1].strip()

# Now construct the new _mediumData list
new_medium_data = f"static final List<ExerciseEntity> _mediumData = [\n    {medium_1_str},\n\n{medium_part}\n  ];"

# Construct the new _hardData list
new_hard_data = f"static final List<ExerciseEntity> _hardData = [\n{hard_part},\n\n{old_hard_1_str}\n  ];"

# Find index where _hardData ends in original file
hard_end_idx = repo_content.find("];", repo_content.find("static final List<ExerciseEntity> _hardData = ["))
last_part = repo_content[hard_end_idx + 2:]

# Combine everything
new_repo_content = first_part + new_medium_data + "\n\n  // ==========================================\n  // NIVEL DIFÍCIL\n  // ==========================================\n  " + new_hard_data + last_part

# Write back
with open(repo_path, "w", encoding="utf-8") as f:
    f.write(new_repo_content)

print("Successfully updated exercise_repository.dart!")
