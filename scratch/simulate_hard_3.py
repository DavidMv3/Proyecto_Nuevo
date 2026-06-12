import json

def get_progressive_expression(base_expr, current_expr, is_completed):
    base_tokens = base_expr.strip().split()
    current_tokens = current_expr.strip().split()

    if len(current_tokens) <= 1:
        return current_expr if is_completed else ""

    # Calculate depths
    depths = []
    current_depth = 0
    for token in base_tokens:
        if '(' in token or '[' in token or '{' in token:
            current_depth += 1
        depths.append(current_depth)
        if ')' in token or ']' in token or '}' in token:
            current_depth -= 1

    def get_block_index(token_idx):
        block = 0
        for k in range(token_idx + 1):
            val = base_tokens[k]
            depth = depths[k]
            if depth == 0 and (val == '+' or val == '-'):
                block += 1
        return block

    # LCS Alignment
    n = len(base_tokens)
    m = len(current_tokens)
    dp = [[0] * (m + 1) for _ in range(n + 1)]

    for i in range(1, n + 1):
        for j in range(1, m + 1):
            if base_tokens[i - 1] == current_tokens[j - 1]:
                dp[i][j] = dp[i - 1][j - 1] + 1
            else:
                dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])

    base_matched = [False] * n
    current_matched = [False] * m
    i, j = n, m
    while i > 0 and j > 0:
        if base_tokens[i - 1] == current_tokens[j - 1]:
            base_matched[i - 1] = True
            current_matched[j - 1] = True
            i -= 1
            j -= 1
        elif dp[i - 1][j] >= dp[i][j - 1]:
            i -= 1
        else:
            j -= 1

    # Build segments
    class TokenSegment:
        def __init__(self, base, current, base_indices):
            self.base = base
            self.current = current
            self.base_indices = base_indices
        
        @property
        def is_modified(self):
            if len(self.base) != len(self.current):
                return True
            for k in range(len(self.base)):
                if self.base[k] != self.current[k]:
                    return True
            return False

    segments = []
    base_ptr = 0
    current_ptr = 0

    while base_ptr < n or current_ptr < m:
        if base_ptr < n and current_ptr < m and base_matched[base_ptr] and current_matched[current_ptr] and base_tokens[base_ptr] == current_tokens[current_ptr]:
            segments.append(TokenSegment([base_tokens[base_ptr]], [current_tokens[current_ptr]], [base_ptr]))
            base_ptr += 1
            current_ptr += 1
        else:
            next_base_match = base_ptr
            while next_base_match < n and not base_matched[next_base_match]:
                next_base_match += 1
            next_current_match = current_ptr
            while next_current_match < m and not current_matched[next_current_match]:
                next_current_match += 1

            base_seg = base_tokens[base_ptr:next_base_match]
            current_seg = current_tokens[current_ptr:next_current_match]
            base_indices = list(range(base_ptr, next_base_match))
            segments.append(TokenSegment(base_seg, current_seg, base_indices))

            base_ptr = next_base_match
            current_ptr = next_current_match

    last_modified_idx = -1
    if is_completed:
        for k in range(len(segments)):
            if segments[k].is_modified:
                last_modified_idx = k
    else:
        for k in range(len(segments)):
            if segments[k].is_modified:
                last_modified_idx = k
                break

    def get_segment_block(seg_idx):
        seg = segments[seg_idx]
        if seg.base_indices:
            return get_block_index(seg.base_indices[0])
        for k in range(seg_idx - 1, -1, -1):
            if segments[k].base_indices:
                return get_block_index(segments[k].base_indices[-1])
        for k in range(seg_idx + 1, len(segments)):
            if segments[k].base_indices:
                return get_block_index(segments[k].base_indices[0])
        return 0

    output = []
    for k in range(len(segments)):
        seg = segments[k]
        block_idx = get_segment_block(k)

        if k < last_modified_idx:
            output.extend(seg.current)
        elif k == last_modified_idx:
            if is_completed:
                output.extend(seg.current)
            else:
                for token in seg.base:
                    if token == '(' or token == '[' or token == '{' or token.startswith('sqrt(') or token.startswith('root') or token.endswith('('):
                        output.append(token)
                    else:
                        break
                break
        else:
            output.extend(seg.current)

    while output and output[-1] == '^':
        output.pop()

    return " ".join(output)


def simulate():
    with open("assets/exercises.json", "r", encoding="utf-8") as f:
        exercises = json.load(f)
    
    # Find hard_3
    ex = None
    for item in exercises:
        if item["exercise_id"] == "hard_3":
            ex = item
            break
            
    if not ex:
        print("hard_3 not found!")
        return

    base_expr = ex["initial_expression"]
    steps = ex["workflow_steps"]
    
    print(f"Base Expression: {base_expr}\n")
    
    # Simulate step-by-step
    history = [base_expr]
    working_line = base_expr
    
    proposed_overrides = {
        3: "2 ^ ____ +",
        4: "2 ^ 3 +",
        5: "2 ^ 3 + 3 * (",
        6: "2 ^ 3 + 3 * ____ / (",
        7: "2 ^ 3 + 3 * 3 / (",
        8: "2 ^ 3 + 3 * 3 / ____",
        9: "2 ^ 3 + 3 * 3 / 1",
        10: "____ + 3 * 3 / 1",
        11: "8 + 3 * 3 / 1",
        12: "8 + ____ / 1",
        13: "8 + 9 / 1",
        14: "8 + ____",
        15: "8 + 9",
        16: "17"
    }
    
    for idx, step in enumerate(steps):
        s_num = step["step_index"]
        s_type = step["type"]
        is_mc = s_type in ["multiple_choice", "evaluation_step"] and "options" in step
        
        # Get override for active step
        override = proposed_overrides.get(s_num, step.get("display_append", None))
        if override == "":
            override = None
        
        # Determine working line for active step (before completing it)
        active_working = base_expr
        for prev_idx in range(idx - 1, -1, -1):
            prev_s_num = steps[prev_idx]["step_index"]
            prev_override = proposed_overrides.get(prev_s_num, steps[prev_idx].get("display_append", None))
            if prev_override:
                active_working = prev_override
                break
                
        # Unify raw expressions for display
        raw_exprs = list(history)
        clean_active = active_working.replace(" ", "").replace("$", "")
        last_clean = raw_exprs[-1].replace(" ", "").replace("$", "") if raw_exprs else ""
        if not raw_exprs or last_clean != clean_active:
            raw_exprs.append(active_working)
            
        # Filter prefixes
        filtered = []
        if raw_exprs:
            filtered.append(raw_exprs[0])
            for i in range(1, len(raw_exprs)):
                curr = raw_exprs[i]
                is_prefix = False
                for j in range(i + 1, len(raw_exprs)):
                    c1 = curr.replace(" ", "").replace("$", "")
                    c2 = raw_exprs[j].replace(" ", "").replace("$", "")
                    if c2.startswith(c1):
                        is_prefix = True
                        break
                if not is_prefix:
                    filtered.append(curr)
                    
        print(f"Step {s_num}: {step.get('instruction') or step.get('question')}")
        print("Notebook lines BEFORE answering:")
        for line in filtered:
            is_base = line.replace(" ", "") == base_expr.replace(" ", "")
            prefix = "" if is_base else "= "
            suffix = " =" if is_base else ""
            print(f"  {prefix}{line}{suffix}")
            
        # If not mc, we show interactive equation
        if not is_mc:
            print(f"  Interactive Equation: {active_working}")
        else:
            print(f"  Multiple Choice Options: {[opt['text'] for opt in step.get('options', [])]}")
            
        print("-" * 50)
        
        # Update history after completing step
        if override:
            working_line = override
            clean_working = working_line.replace(" ", "").replace("$", "")
            is_same = history and history[-1].replace(" ", "").replace("$", "") == clean_working
            if not is_same:
                history.append(working_line)

if __name__ == "__main__":
    simulate()
