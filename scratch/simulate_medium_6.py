import json

# Proposed overrides for medium_6
proposed = {
    3: "[",
    4: "[ 2 ^ 6 - ",
    5: "[ 2 ^ 6 - 10 ] + [",
    6: "[ 2 ^ 6 - 10 ] + [",
    7: "[ 2 ^ 6 - 10 ] + [ 18 - 15 ]",
    8: "[",
    9: "[ 64 - 10 ] + [",
    10: "[ 64 - 10 ] + [ 3 ]",
    11: "[ 54 ] + [ 3 ]",
    12: "57"
}

# Simple implementation of _isPrefix as done in Dart
def is_prefix(s1, s2):
    c1 = s1.replace(" ", "").replace("$", "")
    c2 = s2.replace(" ", "").replace("$", "")
    return c2.startswith(c1)

base_expression = "[ ( 2 ^ 2 ) ^ 3 - 50 / 5 ] + [ 9 * 2 - 15 ]"

print("SIMULATING PROPOSED PROGRESSION FOR MEDIUM 6:")
history = []
working_line = base_expression

for step_num in range(1, 13):
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
