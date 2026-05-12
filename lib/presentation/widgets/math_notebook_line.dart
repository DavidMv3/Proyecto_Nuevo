import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'interactive_equation.dart';

/// Converts a raw math expression string to LaTeX format for rendering.
String _toLatex(String expr) {
  String output = expr;

  // Handle sqrt( ... ) → \sqrt{ ... }
  // First handle nested patterns: sqrt( ... )
  output = output.replaceAllMapped(
    RegExp(r'sqrt\s*\(\s*(.*?)\s*\)'),
    (match) => r'\sqrt{' + match.group(1)! + r'}',
  );
  // Fallback for remaining sqrt
  output = output.replaceAll(RegExp(r'(?<!\\)sqrt'), r'\sqrt');

  // Handle ^ for exponents: 3 ^ 2 → 3^{2}
  output = output.replaceAllMapped(
    RegExp(r'(\d+)\s*\^\s*(\d+)'),
    (match) => '${match.group(1)}^{${match.group(2)}}',
  );

  // Multiplication and division
  output = output.replaceAll(' * ', r' \times ');
  output = output.replaceAll('*', r'\times ');
  output = output.replaceAll(' / ', r' \div ');
  output = output.replaceAll('/', r'\div ');

  // Handle blank placeholder
  output = output.replaceAll('____', r'\boxed{?}');

  return output;
}

class MathNotebookLine extends StatelessWidget {
  final String equation;
  final bool showBoxesAndColors;

  const MathNotebookLine({
    super.key,
    required this.equation,
    this.showBoxesAndColors = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBoxesAndColors) {
      // Render with flutter_math_fork for real mathematical expressions
      final latex = _toLatex(equation);
      return Math.tex(
        latex,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        mathStyle: MathStyle.display,
      );
    }

    // ── Boxed mode: parse blocks and render with boxes ──
    final tokens = equation.split(' ').where((s) => s.isNotEmpty).toList();
    List<Widget> children = [];
    List<String> currentBlock = [];
    int parenDepth = 0;

    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (t.contains('(')) {
        parenDepth += t.split('(').length - 1;
      }
      if (t.contains(')')) {
        parenDepth -= t.split(')').length - 1;
      }

      if (parenDepth < 0) parenDepth = 0;

      if (parenDepth == 0 && (t == '+' || t == '-')) {
        if (currentBlock.isNotEmpty) {
          children.add(_buildBlockWidget(currentBlock));
          currentBlock.clear();
        }
        children.add(_buildSignWidget(t, isExternal: true));
      } else if (parenDepth == 0 && t == '=') {
        if (currentBlock.isNotEmpty) {
          children.add(_buildBlockWidget(currentBlock));
          currentBlock.clear();
        }
        children.add(_buildSignWidget(t, isExternal: false));
      } else {
        currentBlock.add(t);
      }
    }

    if (currentBlock.isNotEmpty) {
      children.add(_buildBlockWidget(currentBlock));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: children,
    );
  }

  Widget _buildBlockWidget(List<String> blockTokens) {
    // Join tokens back and convert to LaTeX for the block content
    final blockExpr = blockTokens.join(' ');
    final latex = _toLatex(blockExpr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.0),
      ),
      child: Math.tex(
        latex,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        mathStyle: MathStyle.display,
      ),
    );
  }

  Widget _buildSignWidget(String sign, {required bool isExternal}) {
    Color color = Colors.black87;
    if (isExternal && sign != '=') {
      color = Colors.blue.shade700;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        MathTokenWidget.formatMathText(sign),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
          color: color,
        ),
      ),
    );
  }
}
