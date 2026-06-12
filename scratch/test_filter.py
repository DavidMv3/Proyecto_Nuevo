def is_prefix(a, b):
    clean_a = a.replace(' ', '').replace('____', '').replace('?', '')
    clean_b = b.replace(' ', '').replace('____', '').replace('?', '')
    if not clean_a:
        return False
    return clean_b.startswith(clean_a)

raw_expressions = [
    "[ ( 2 * 3 ) ^ 2 - 30 ] + [ 18 / 3 + 10 ]", # Base
    "[ ( 6 ) ^ 2 - 30 ] + [ 18 / 3 + 10 ]",     # Step 4 completed
    "[ ( 6 ) ^ 2 - 30 ] + [ 6 + 10 ]",          # Step 6 completed
    "[ 36 - 30 ] + [ 6 + 10 ]",                 # Step 8 completed
    "[ 36 - 30 ] + [ 16 ]",                     # Step 9 completed
    "[ 6 ] + [ 16 ]",                           # Step 10 completed
    "22"                                        # Step 11 completed
]

filtered = []
for i in range(len(raw_expressions)):
    current = raw_expressions[i]
    is_prefix_of_later = False
    for j in range(i + 1, len(raw_expressions)):
        if is_prefix(current, raw_expressions[j]):
            is_prefix_of_later = True
            break
    if not is_prefix_of_later:
        filtered.append(current)

print("Filtered expressions for medium_4:")
for f in filtered:
    print(f)
