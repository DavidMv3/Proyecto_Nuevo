import pypdf

reader = pypdf.PdfReader('ejercicios_algoritmosultimo.pdf')

full_text = ""
for page in reader.pages:
    full_text += page.extract_text() + "\n"

# Search for III) 8
parts = full_text.split('III) 8')
if len(parts) > 1:
    sub = parts[1]
    with open('easy_3_pdf.txt', 'w', encoding='utf-8') as out:
        out.write("III) 8" + sub[:3000])
    print("Done!")
else:
    print("Could not find exercise III")
