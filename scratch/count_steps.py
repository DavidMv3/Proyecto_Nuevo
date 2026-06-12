import json

def main():
    with open("assets/exercises.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"Total exercises in JSON: {len(data)}")
    for x in data:
        print(f"{x['exercise_id']}: {len(x['workflow_steps'])} steps")

if __name__ == "__main__":
    main()
