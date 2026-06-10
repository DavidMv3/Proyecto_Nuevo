import sys

with open('scratch/parse_by_ranges.py', 'r', encoding='utf-8') as f:
    text = f.read()

med_bases = '''    ("medium", "I"): "3 ^ 6 / 3 ^ 4 - 2 * ( 5 - 2 )",\n'''
med_ranges = '''    ("medium", "I"): (39, 43),\n'''

text = text.replace('("medium", "II"): "[ 2 ^ 3 * 2 ^ 2 - 20 ] + [ 6 + 3 ^ 2 ]",', med_bases + '    ("medium", "II"): "[ 2 ^ 3 * 2 ^ 2 - 20 ] + [ 6 + 3 ^ 2 ]",')
text = text.replace('("medium", "II"): (44, 48),', med_ranges + '    ("medium", "II"): (44, 48),')

with open('scratch/parse_by_ranges.py', 'w', encoding='utf-8') as f:
    f.write(text)

print('Updated parse_by_ranges.py for medium I successfully.')
