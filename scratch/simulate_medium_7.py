import json

# Proposed overrides for medium_7
proposed = {
    3: "[ 15 - (",
    4: "[ 15 - ( 3 ) ^ 2 ] + [",
    5: "[ 15 - ( 3 ) ^ 2 ] + [",
    6: "[ 15 - ( 3 ) ^ 2 ] + [ 15 + 20 ]",
    7: "[ 15 - ",
    8: "[ 15 - 9 ] + [",
    9: "[ 15 - 9 ] + [ 35 ]",
    10: "[ 6 ] + [ 35 ]",
    11: "41"
}

# Simple implementation of _isPrefix as done in Dart
def is_prefix(s1, s2):
    c1 = s1.replace(" ", "").replace("$", "")
    c2 = s2.replace(" ", "").replace("$", "")
    return c2.startswith(c1)

base_expression = "[ 15 - ( 7 - 4 ) ^ 2 ] + [ 3 * 5 + 20 ]"

print("SIMULATING PROPOSED PROGRESSION FOR MEDIUM 7:")
history = []
working_line = base_expression

for step_num in range(1, 12):
    # Before answering step_num:
    if step_num > 1:
        working_line = base_expression
        for i in range(step_num - 1, 0, -1):
            if i in proposed:
                working_line = proposed[i]
                break

    # Build rawExpressions list
    raw_expressions = list(history)
    if working_line and working_line.strip():
        clean_active = working_line.replace(" ", "").replace("$", "")
        last_clean = raw_expressions[-1].replace(" ", "").replace("$", "") if raw_expressions else ""
        if not raw_expressions or last_clean != clean_active:
            raw_expressions.append(working_line)

    # Filter prefixes
    filtered = []
    if raw_expressions:
        filtered.append(raw_expressions[0])
        for i in range(1, len(raw_expressions)):
            current = raw_expressions[i]
            is_prefix_of_later = False
            for j in range(i + 1, len(raw_expressions)):
                if is_prefix(current, raw_expressions[j]):
                    is_prefix_of_later = True
                    break
            if not is_prefix_of_later:
                filtered.append(current)

    print(f"\nStep {step_num}: BEFORE ANSWERING")
    print("  Filtered Notebook Lines:")
    for eq in filtered:
        is_base = eq.replace(" ", "") == base_expression.replace(" ", "")
        prefix = "" if is_base else "= "
        suffix = " =" if is_base else ""
        print(f"    {prefix}{eq}{suffix}")

    # After answering step_num:
    if step_num in proposed:
        working_line = proposed[step_num]

    # Add to history for next step
    if working_line:
        clean_working = working_line.replace(" ", "").replace("$", "")
        is_same_as_last = history and history[-1].replace(" ", "").replace("$", "") == clean_working
        if not is_same_as_last:
            history.append(working_line)
