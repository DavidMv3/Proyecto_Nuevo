import 'package:flutter/material.dart';
import 'interactive_equation.dart';

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
      // Just render the text normally
      return Text(
        MathTokenWidget.formatMathText(equation),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
          color: Colors.black87,
        ),
      );
    }

    // Parse blocks and signs
    final tokens = equation.split(' ').where((s) => s.isNotEmpty).toList();
    List<Widget> children = [];
    List<String> currentBlock = [];
    int parenDepth = 0;

    for (int i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      if (t == '(') parenDepth++;
      if (t == ')') parenDepth--;

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
      children: children,
    );
  }

  Widget _buildBlockWidget(List<String> blockTokens) {
    List<TextSpan> spans = [];
    for (int i = 0; i < blockTokens.length; i++) {
      final t = blockTokens[i];
      Color color = Colors.black87;
      if (t == '*' || t == '/' || t == '×' || t == '÷') {
        color = Colors.red;
      } else if (t == '+' || t == '-') {
        // Internal signs inside a block
        color = Colors.red;
      }
      
      spans.add(TextSpan(
        text: MathTokenWidget.formatMathText(t),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          color: color,
        ),
      ));
      
      if (i < blockTokens.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.0),
      ),
      child: RichText(
        text: TextSpan(children: spans),
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
          fontWeight: FontWeight.w500,
          fontFamily: 'Nunito',
          color: color,
        ),
      ),
    );
  }
}
