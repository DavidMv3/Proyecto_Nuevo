import json

def main():
    json_path = "assets/exercises.json"
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Find hard_9
    hard_9 = None
    for ex in data:
        if ex["exercise_id"] == "hard_9":
            hard_9 = ex
            break

    if not hard_9:
        print("Error: hard_9 not found in exercises.json")
        return

    steps = hard_9["workflow_steps"]
    
    # Step 3
    s3 = steps[2]
    s3["display_append"] = "("
    
    # Step 4
    s4 = steps[3]
    s4["display_append"] = "( 81 + 2 ) * 3 -"
            
    # Step 5
    s5 = steps[4]
    s5["display_append"] = "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ("
    
    # Step 6
    s6 = steps[5]
    s6["display_append"] = "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ("
    
    # Step 7
    s7 = steps[6]
    s7["display_append"] = "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) -"
    
    # Step 8
    s8 = steps[7]
    s8["display_append"] = "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) - ("
    
    # Step 9
    s9 = steps[8]
    s9["display_append"] = "( 81 + 2 ) * 3 - sqrt( 23 + 10 / ( 4 + 1 ) ) - ( 8 ) ^ 2"
    
    # Step 10
    s10 = steps[9]
    s10["display_append"] = "("
    
    # Step 11
    s11 = steps[10]
    s11["display_append"] = "( 83 ) * 3 -"
    
    # Step 12
    s12 = steps[11]
    s12["display_append"] = "( 83 ) * 3 - sqrt( 23 + 10 / ("
    
    # Step 13
    s13 = steps[12]
    s13["display_append"] = "( 83 ) * 3 - sqrt( 23 + 10 / ( 5 ) ) -"
    
    # Step 14
    s14 = steps[13]
    s14["display_append"] = "( 83 ) * 3 - sqrt( 23 + 10 / ( 5 ) ) -"

    # Step 15
    s15 = steps[14]
    s15["display_append"] = "( 83 ) * 3 - sqrt( 23 + 10 / ( 5 ) ) - 64"

    # Step 16
    s16 = steps[15]
    s16["display_append"] = "( 83 ) * 3 - sqrt( 23 + 10 / ( 5 ) ) - 64"

    # Step 17
    s17 = steps[16]
    s17["display_append"] = "249 -"

    # Step 18
    s18 = steps[17]
    s18["display_append"] = "249 - sqrt( 23 +"

    # Save data back to exercises.json
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("Successfully updated assets/exercises.json for hard_9!")

if __name__ == "__main__":
    main()
