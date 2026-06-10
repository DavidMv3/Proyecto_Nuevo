import pypdf

reader = pypdf.PdfReader("ejercicios_algoritmos.pdf")
print(f"Total pages: {len(reader.pages)}")

with open("scratch/pdf_text.txt", "w", encoding="utf-8") as f:
    for i, page in enumerate(reader.pages):
        text = page.extract_text()
        f.write(f"=== PAGE {i+1} ===\n")
        f.write(text)
        f.write("\n\n")

print("Done! Text saved to scratch/pdf_text.txt")
