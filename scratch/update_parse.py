import sys

with open('scratch/parse_by_ranges.py', 'r', encoding='utf-8') as f:
    text = f.read()

easy_bases = '''    ("easy", "I"): "4 * 5 - 6 / 3",
    ("easy", "II"): "18 + 3 * 5",
    ("easy", "III"): "8 - 3 * 2 + 1",
    ("easy", "IV"): "10 - 3 * 2 + 2 ^ 3",
    ("easy", "V"): "1 + 12 / 4 - 1 + 2 ^ 3",
    ("easy", "VI"): "3 - 2 + ( 8 - 2 * 3 )",
    ("easy", "VII"): "sqrt( 4 + 12 ) - 15 / 5",
    ("easy", "VIII"): "3 ^ 2 + 5 * 2 - sqrt( 30 - 5 )",
    ("easy", "IX"): "4 * ( 20 / 4 + 1 ) + 4 * 2 ^ 3",
    ("easy", "X"): "( 2 + 10 / 5 ) * 2 ^ 2 - 3",
'''

easy_ranges = '''    ("easy", "I"): (1, 2),
    ("easy", "II"): (3, 5),
    ("easy", "III"): (6, 7),
    ("easy", "IV"): (8, 10),
    ("easy", "V"): (11, 14),
    ("easy", "VI"): (15, 17),
    ("easy", "VII"): (18, 22),
    ("easy", "VIII"): (23, 26),
    ("easy", "IX"): (27, 32),
    ("easy", "X"): (33, 38),
'''

text = text.replace('base_expressions = {', 'base_expressions = {\n' + easy_bases)
text = text.replace('ranges = {', 'ranges = {\n' + easy_ranges)

with open('scratch/parse_by_ranges.py', 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated parse_by_ranges.py successfully.')
