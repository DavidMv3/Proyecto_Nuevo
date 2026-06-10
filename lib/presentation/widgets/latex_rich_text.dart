import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Un widget que renderiza texto enriquecido con notación matemática LaTeX inline.
/// Busca bloques delimitados por el carácter '$' y los renderiza con [Math.tex].
class LatexRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const LatexRichText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = style ?? DefaultTextStyle.of(context).style;
    final parts = text.split('\$');

    if (parts.length <= 1) {
      return Text(
        text,
        style: defaultStyle,
        textAlign: textAlign,
      );
    }

    final List<InlineSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      if (i % 2 == 1) {
        // Bloque matemático LaTeX
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Math.tex(
                part,
                mathStyle: MathStyle.text,
                textStyle: defaultStyle.copyWith(
                  // Ajuste sutil de tamaño para que se alinee visualmente con el texto
                  fontSize: (defaultStyle.fontSize ?? 14) * 1.05,
                ),
              ),
            ),
          ),
        );
      } else {
        // Bloque de texto plano
        String formattedPart = part.replaceAll(' * ', ' × ').replaceAll(' x ', ' × ').replaceAll(' / ', ' ÷ ').replaceAll(' ÷ ', ' ÷ ');
        spans.add(
          TextSpan(
            text: formattedPart,
            style: defaultStyle,
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }
}
