import subprocess

res = subprocess.run(["git", "diff", "lib/data/repositories/exercise_repository.dart"], capture_output=True, text=True, encoding='utf-8')
diff_text = res.stdout

hunks = diff_text.split("@@")
with open("scratch/medium_4_diff.txt", "w", encoding="utf-8") as f:
    for hunk in hunks:
        if "medium_4" in hunk:
            f.write("@@" + hunk + "\n" + "="*80 + "\n")
print("Written diff to scratch/medium_4_diff.txt")
