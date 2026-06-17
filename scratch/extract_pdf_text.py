import pypdf

reader = pypdf.PdfReader('ejercicios_algoritmosultimo.pdf')
print(f"Number of pages: {len(reader.pages)}")

full_text = ""
for i, page in enumerate(reader.pages):
    text = page.extract_text()
    full_text += f"\n--- PAGE {i+1} ---\n" + text

with open('pdf_text.txt', 'w', encoding='utf-8') as f:
    f.write(full_text)

print("Saved PDF text to pdf_text.txt")
