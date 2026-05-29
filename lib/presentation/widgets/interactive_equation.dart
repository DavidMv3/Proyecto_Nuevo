import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../domain/entities/equation_token.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveEquation — Texto matemático con bloques recuadrados interactivos
//
// Los tokens se agrupan en bloques (entre + y - a profundidad 0).
// Cada bloque se envuelve en un Container con borde (recuadro).
// Los signos separadores (+, -) se muestran fuera de los recuadros en azul.
// Dentro de cada bloque, ^ se renderiza como superíndice y sqrt como √.
// ─────────────────────────────────────────────────────────────────────────────

/// Represents a group of tokens: either a block (needs box) or a separator sign.
class _TokenGroup {
  final List<EquationToken> tokens;
  final bool isSeparator;
  const _TokenGroup(this.tokens, {this.isSeparator = false});
}

class InteractiveEquation extends StatelessWidget {
  final List<EquationToken> tokens;
  final Set<String> selectedIds;
  final Set<String> correctIds;
  final void Function(String tokenId) onTokenTapped;
  final bool isStepDone;
  final String? errorTokenId;
  final Set<String> hintIds;
  final bool isEnabled;
  final Set<String> focusIds;
  final bool showBlockBoxes;

  const InteractiveEquation({
    super.key,
    required this.tokens,
    required this.selectedIds,
    required this.correctIds,
    required this.onTokenTapped,
    this.isStepDone = false,
    this.errorTokenId,
    this.hintIds = const {},
    this.isEnabled = true,
    this.focusIds = const {},
    this.showBlockBoxes = false,
  });

  /// Groups tokens into blocks (between +/- at paren depth 0) and separators.
  List<_TokenGroup> _groupTokens() {
    List<_TokenGroup> groups = [];
    List<EquationToken> currentBlock = [];
    int parenDepth = 0;

    for (final token in tokens) {
      final v = token.value;
      if (v.contains('(')) parenDepth += v.split('(').length - 1;
      if (v.contains(')')) parenDepth -= v.split(')').length - 1;
      if (parenDepth < 0) parenDepth = 0;

      if (parenDepth == 0 && (v == '+' || v == '-')) {
        // Flush current block
        if (currentBlock.isNotEmpty) {
          groups.add(_TokenGroup(List.from(currentBlock)));
          currentBlock.clear();
        }
        // Add separator
        groups.add(_TokenGroup([token], isSeparator: true));
      } else {
        currentBlock.add(token);
      }
    }
    if (currentBlock.isNotEmpty) {
      groups.add(_TokenGroup(List.from(currentBlock)));
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupTokens();

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 8,
      children: groups.map((group) {
        if (group.isSeparator) {
          final token = group.tokens.first;
          return _SeparatorTokenWidget(
            token: token,
            isSelected: selectedIds.contains(token.id),
            isCorrect: correctIds.contains(token.id),
            isStepDone: isStepDone,
            hasError: errorTokenId == token.id,
            isHint: hintIds.contains(token.id),
            isEnabled: isEnabled,
            isDimmed: focusIds.isNotEmpty && !focusIds.contains(token.id),
            onTap: () => onTokenTapped(token.id),
          );
        } else {
          return _BlockWidget(
            tokens: group.tokens,
            selectedIds: selectedIds,
            correctIds: correctIds,
            isStepDone: isStepDone,
            errorTokenId: errorTokenId,
            hintIds: hintIds,
            isEnabled: isEnabled,
            focusIds: focusIds,
            showBox: showBlockBoxes,
            onTokenTapped: onTokenTapped,
          );
        }
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BlockWidget — A boxed group of tokens
// ─────────────────────────────────────────────────────────────────────────────

class _BlockWidget extends StatelessWidget {
  final List<EquationToken> tokens;
  final Set<String> selectedIds;
  final Set<String> correctIds;
  final bool isStepDone;
  final String? errorTokenId;
  final Set<String> hintIds;
  final bool isEnabled;
  final Set<String> focusIds;
  final bool showBox;
  final void Function(String tokenId) onTokenTapped;

  const _BlockWidget({
    required this.tokens,
    required this.selectedIds,
    required this.correctIds,
    required this.isStepDone,
    required this.errorTokenId,
    required this.hintIds,
    required this.isEnabled,
    required this.focusIds,
    required this.showBox,
    required this.onTokenTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Build the token widgets, handling ^ for superscripts
    List<Widget> children = [];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final isCaretToken = token.value == '^';

      if (isCaretToken) {
        // Skip the caret itself — combine with the next token as superscript
        if (i + 1 < tokens.length) {
          final exponentToken = tokens[i + 1];
          children.add(
            MathTokenWidget(
              key: ValueKey('${token.id}_${exponentToken.id}'),
              token: exponentToken,
              displayOverride: exponentToken.value,
              isSuperscript: true,
              // Both the ^ and the exponent are tappable together
              isSelected: selectedIds.contains(token.id) || selectedIds.contains(exponentToken.id),
              isCorrect: correctIds.contains(token.id) || correctIds.contains(exponentToken.id),
              isStepDone: isStepDone,
              hasError: errorTokenId == token.id || errorTokenId == exponentToken.id,
              isHint: hintIds.contains(token.id) || hintIds.contains(exponentToken.id),
              isEnabled: isEnabled,
              isDimmed: focusIds.isNotEmpty && !focusIds.contains(exponentToken.id),
              onTap: () {
                // Tap the caret token (the ^ is the meaningful one for selection)
                onTokenTapped(token.id);
              },
            ),
          );
          i++; // Skip next token since we consumed it
        }
        continue;
      }

      children.add(
        MathTokenWidget(
          key: ValueKey(token.id),
          token: token,
          isSelected: selectedIds.contains(token.id),
          isCorrect: correctIds.contains(token.id),
          isStepDone: isStepDone,
          hasError: errorTokenId == token.id,
          isHint: hintIds.contains(token.id),
          isEnabled: isEnabled,
          isDimmed: focusIds.isNotEmpty && !focusIds.contains(token.id),
          onTap: () => onTokenTapped(token.id),
        ),
      );
    }

    Widget wrap = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      runSpacing: 4,
      children: children,
    );

    if (!showBox) return wrap;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.05),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: wrap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SeparatorTokenWidget — A standalone +/- sign outside blocks
// ─────────────────────────────────────────────────────────────────────────────

class _SeparatorTokenWidget extends StatefulWidget {
  final EquationToken token;
  final bool isSelected;
  final bool isCorrect;
  final bool isStepDone;
  final bool hasError;
  final bool isHint;
  final bool isEnabled;
  final bool isDimmed;
  final VoidCallback onTap;

  const _SeparatorTokenWidget({
    required this.token,
    required this.isSelected,
    required this.isCorrect,
    required this.isStepDone,
    required this.hasError,
    required this.isHint,
    required this.isEnabled,
    required this.isDimmed,
    required this.onTap,
  });

  @override
  State<_SeparatorTokenWidget> createState() => _SeparatorTokenWidgetState();
}

class _SeparatorTokenWidgetState extends State<_SeparatorTokenWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _errorCtrl;
  bool _showingError = false;

  @override
  void initState() {
    super.initState();
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _errorCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showingError = false);
      }
    });
  }

  @override
  void didUpdateWidget(_SeparatorTokenWidget old) {
    super.didUpdateWidget(old);
    if (widget.hasError && !old.hasError && !_showingError) {
      setState(() => _showingError = true);
      _errorCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _errorCtrl.dispose();
    super.dispose();
  }

  bool get _isActive =>
      widget.isSelected || (widget.isStepDone && widget.isCorrect);

  Color _resolveColor() {
    if (_showingError)                              return AppTheme.errorRed;
    if (widget.isStepDone && widget.isCorrect)      return AppTheme.primaryGreen;
    if (widget.isSelected)                          return Colors.blue.shade700;
    if (widget.isHint)                              return Colors.amber.shade800;
    return Colors.black87; // Default: black
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    return Opacity(
      opacity: widget.isDimmed ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: (widget.isStepDone || !widget.isEnabled) ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: _isActive ? color.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(6),
            border: _isActive
                ? Border(bottom: BorderSide(color: color, width: 2.5))
                : null,
          ),
          child: Text(
            widget.token.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: _isActive ? FontWeight.w800 : FontWeight.w600,
              fontFamily: 'Nunito',
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MathTokenWidget — Individual tappable token inside a block
// ─────────────────────────────────────────────────────────────────────────────

class MathTokenWidget extends StatefulWidget {
  final EquationToken token;
  final bool isSelected;
  final bool isCorrect;
  final bool isStepDone;
  final bool hasError;
  final bool isHint;
  final bool isEnabled;
  final bool isDimmed;
  final bool isSuperscript;
  final String? displayOverride;
  final VoidCallback onTap;

  const MathTokenWidget({
    super.key,
    required this.token,
    required this.isSelected,
    required this.isCorrect,
    required this.isStepDone,
    required this.onTap,
    this.hasError = false,
    this.isHint = false,
    this.isEnabled = true,
    this.isDimmed = false,
    this.isSuperscript = false,
    this.displayOverride,
  });

  /// Formatea el texto crudo (ej: sqrt -> √, * -> ×) para visualización robusta.
  static String formatMathText(String input) {
    String output = input
        .replaceAll(' * ', ' × ')
        .replaceAll('*', '×')
        .replaceAll(' / ', ' ÷ ')
        .replaceAll('/', '÷')
        .replaceAll('sqrt', '√');

    final Map<String, String> superscripts = {
      '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
      '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'
    };
    
    output = output.replaceAllMapped(RegExp(r'\^\s*(\d+)'), (match) {
      final numberStr = match.group(1)!;
      return numberStr.split('').map((char) => superscripts[char] ?? char).join('');
    });

    return output;
  }

  /// Formatea la expresión para que Math.tex (LaTeX) la interprete correctamente.
  static String formatTexText(String input) {
    String output = input;
    output = output.replaceAllMapped(
      RegExp(r'sqrt\s*\(\s*(.*?)\s*\)'), 
      (match) => r'\sqrt{' + match.group(1)! + r'}'
    );
    output = output.replaceAll(RegExp(r'(?<!\\)sqrt'), r'\sqrt{\ }');
    
    output = output.replaceAll(' * ', r' \times ');
    output = output.replaceAll('*', r'\times ');
    output = output.replaceAll(' / ', r' \div ');
    output = output.replaceAll('/', r'\div ');

    return output;
  }

  @override
  State<MathTokenWidget> createState() => _MathTokenWidgetState();
}

class _MathTokenWidgetState extends State<MathTokenWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _errorCtrl;
  late final Animation<double> _errorAnim;
  bool _showingError = false;

  @override
  void initState() {
    super.initState();
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _errorAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _errorCtrl, curve: Curves.easeOut));

    _errorCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showingError = false);
      }
    });
  }

  @override
  void didUpdateWidget(MathTokenWidget old) {
    super.didUpdateWidget(old);
    if (widget.hasError && !old.hasError && !_showingError) {
      setState(() => _showingError = true);
      _errorCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _errorCtrl.dispose();
    super.dispose();
  }

  bool get _isActive =>
      widget.isSelected || (widget.isStepDone && widget.isCorrect);

  Color _resolveTextColor() {
    if (_showingError)                              return AppTheme.errorRed;
    if (widget.isStepDone && widget.isCorrect)      return AppTheme.primaryGreen;
    if (widget.isSelected)                          return Colors.blue.shade700;
    if (widget.isHint)                              return Colors.amber.shade800;
    // Operators inside blocks: colored
    final v = widget.token.value;
    if (v == '*' || v == '/' || v == '×' || v == '÷') return Colors.black87;
    if (v == '+' || v == '-') return Colors.black87;
    return Colors.black87;
  }

  Color? _resolveBackgroundColor() {
    if (_showingError)                              return AppTheme.errorRed.withValues(alpha: 0.15);
    if (widget.isStepDone && widget.isCorrect)      return AppTheme.primaryGreen.withValues(alpha: 0.15);
    if (widget.isSelected)                          return Colors.blue.withValues(alpha: 0.12);
    if (widget.isHint)                              return Colors.amber.withValues(alpha: 0.18);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveBackgroundColor();
    final textColor = _resolveTextColor();
    final displayText = widget.displayOverride ?? widget.token.value;

    final double fontSize = widget.isSuperscript ? 16 : 22;

    // Determinar si el token necesita renderizado LaTeX
    final needsLatex = displayText.contains('sqrt') ||
        displayText.contains('^') ||
        displayText == '*' ||
        displayText == '/';

    Widget textChild;
    if (needsLatex) {
      final latex = MathTokenWidget.formatTexText(displayText);
      textChild = Math.tex(
        latex,
        textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: _isActive ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
        ),
        mathStyle: MathStyle.text,
      );
    } else {
      final formattedText = MathTokenWidget.formatMathText(displayText);
      textChild = Text(
        formattedText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: _isActive ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
          fontFamily: 'Nunito',
          height: 1.1,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _errorAnim,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isDimmed ? 0.35 : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: (widget.isStepDone || !widget.isEnabled) ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSuperscript ? 1 : 3,
            vertical: widget.isSuperscript ? 0 : 4,
          ),
          // Superscript: shift up
          transform: widget.isSuperscript
              ? Matrix4.translationValues(0, -10, 0)
              : null,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: _isActive
                ? Border(bottom: BorderSide(color: textColor, width: 2.5))
                : null,
          ),
          child: textChild,
        ),
      ),
    );
  }
}
