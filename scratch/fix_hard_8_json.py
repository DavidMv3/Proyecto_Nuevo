import json

def main():
    json_path = "assets/exercises.json"
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Find hard_8
    hard_8 = None
    for ex in data:
        if ex["exercise_id"] == "hard_8":
            hard_8 = ex
            break

    if not hard_8:
        print("Error: hard_8 not found in exercises.json")
        return

    steps = hard_8["workflow_steps"]
    
    # Step 3
    s3 = steps[2]
    s3["question"] = "En el primer bloque no hay operaciones internas, por lo tanto:"
    s3["display_append"] = "5"
    
    # Step 4
    s4 = steps[3]
    s4["display_append"] = "5 + [ 15 - ("
    for opt in s4["options"]:
        if opt["text"] == "La suma 23":
            opt["text"] = "La suma $2^3$"
            
    # Step 5
    s5 = steps[4]
    s5["display_append"] = "5 + [ 15 - ( 2 ) ^ 2 +"
    
    # Step 6
    s6 = steps[5]
    s6["display_append"] = "5 + [ 15 - ( 2 ) ^ 2 +"
    for opt in s6["options"]:
        if opt["text"] == "La potenciación 22":
            opt["text"] = "La potenciación $2^2$"
        elif opt["text"] == "La potenciación 23":
            opt["text"] = "La potenciación $2^3$"
    s6["correct_answer"] = "La potenciación $2^3$"
    s6["feedback_failure"] = "Estamos resolviendo el segundo bloque de izquierda a derecha, ahora se debe resolver la potenciación $2^3$"
    
    # Step 7
    s7 = steps[6]
    s7["display_append"] = "5 + [ 15 - ( 2 ) ^ 2 + 8 ] +"
    
    # Step 8
    s8 = steps[7]
    s8["display_append"] = "5 + [ 15 - ( 2 ) ^ 2 + 8 ] + root3"
    
    # Step 9
    s9 = steps[8]
    s9["display_append"] = "5 + [ 15 - ( 2 ) ^ 2 + 8 ] + root3( 8 )"
    
    # Step 10
    s10 = steps[9]
    s10["display_append"] = "5 + [ 15 -"
    for opt in s10["options"]:
        if opt["text"] == "La potencia $2^2$":
            opt["text"] = "La potencia $(2)^2$"
    s10["correct_answer"] = "La potencia $(2)^2$"
    
    # Step 11
    s11 = steps[10]
    s11["display_append"] = "5 + [ 15 - 4 + 8 ] +"
    
    # Step 12
    s12 = steps[11]
    s12["display_append"] = "5 + [ 15 - 4 + 8 ] +"
    
    # Step 14
    s14 = steps[13]
    s14["display_append"] = "5 + [ 19 ] + 2"

    # Save data back to exercises.json
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("Successfully updated assets/exercises.json for hard_8!")

if __name__ == "__main__":
    main()
