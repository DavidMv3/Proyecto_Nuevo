import 'package:flutter/material.dart';
import '../../domain/entities/equation_token.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveEquation — "Aprender Haciendo" (sin pistas automáticas)
//
// Cambios vs. versión anterior:
//  • Se eliminó el Timer de 5 s y el pulse de pista visual (RNF pedagógico).
//  • Nuevo parámetro [errorTokenId]: el token incorrecto recibe un flash rojo
//    breve (animación interna) sin mostrar SnackBar ni texto explicativo.
// ─────────────────────────────────────────────────────────────────────────────

class InteractiveEquation extends StatelessWidget {
  final List<EquationToken> tokens;
  final Set<String> selectedIds;
  final Set<String> correctIds;
  final void Function(String tokenId) onTokenTapped;
  final bool isStepDone;

  /// ID del último token incorrecto tocado. Dispara el flash rojo en ese bloque.
  final String? errorTokenId;

  /// IDs de los tokens destacados por el sistema de pistas (clase 'hint').
  final Set<String> hintIds;

  /// Si es falso, los tokens no responden a clics (Tarea 1).
  final bool isEnabled;

  /// Lista de IDs de tokens que deben estar resaltados (Tarea 4).
  /// Si esta lista no está vacía, los tokens NO incluidos se verán atenuados (0.3 opacidad).
  final Set<String> focusIds;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Reducido para ahorrar espacio
      decoration: AppTheme.equationPanelDecoration,
      width: double.infinity,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: tokens
                            .map((token) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6), // Reducido de 10 a 6
                                  child: MathTokenWidget(
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
                                ))
                            .toList(),
                      ),
                    ),
                    // Indicador de más contenido (degradado derecho)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 40,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swipe_left_rounded, size: 14, color: Colors.grey),
              SizedBox(width: 4),
              Text('Desliza para ver más', 
                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MathTokenWidget — Bloque táctil tipo ficha de Scrabble / bloque de madera
//
// Estados visuales:
//  • idle    → bloque blanco/sand con borde inferior grueso (efecto 3D)
//  • selected→ naranja brillante + hundido
//  • correct → verde brillante + hundido (celebración)
//  • error   → flash rojo breve (300ms) y luego vuelve a idle
// ─────────────────────────────────────────────────────────────────────────────

class MathTokenWidget extends StatefulWidget {
  final EquationToken token;
  final bool isSelected;
  final bool isCorrect;
  final bool isStepDone;
  final bool hasError;   // ← dispara el flash rojo
  final bool isHint;     // ← dispara el resplandor de pista
  final bool isEnabled;  // ← permite interacción
  final bool isDimmed;   // ← baja la opacidad si no está en el foco (Tarea 4)
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
    // Convierte "sqrt ( ... )" o "sqrt(...)" a "\sqrt{...}"
    output = output.replaceAllMapped(
      RegExp(r'sqrt\s*\(\s*(.*?)\s*\)'), 
      (match) => r'\sqrt{' + match.group(1)! + r'}'
    );
    // Por si queda un sqrt suelto que no ha sido mapeado a \sqrt{}
    // output = output.replaceAll('sqrt', r'\sqrt'); // <-- Esto causaba doble escape: \\sqrt{}
    // En su lugar, comprobamos si queda alguno crudo que no empiece por \
    output = output.replaceAll(RegExp(r'(?<!\\)sqrt'), r'\sqrt');
    
    // Multiplicaciones y divisiones
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
  // ── Flash de error: 1 ciclo rápido de opacidad roja ──────────────────────
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
    // 0→1→0 (una sola pulsación de color rojo)
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
    // Activa el flash solo cuando llega un error nuevo
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

  // ── Lógica de estado visual ───────────────────────────────────────────────

  bool get _isActive =>
      widget.isSelected || (widget.isStepDone && widget.isCorrect);

  Color _resolveBackground() {
    if (_showingError)                           return AppTheme.errorRed;
    if (widget.isStepDone && widget.isCorrect)   return AppTheme.primaryGreen;
    if (widget.isSelected)                       return AppTheme.accentOrange;
    return Colors.white;
  }

  Color _resolveTextColor() {
    if (_showingError)  return Colors.white;
    if (_isActive)      return Colors.white;
    return AppTheme.textDark;
  }

  Color get _bottomEdgeColor {
    if (_showingError)                              return AppTheme.errorRed;
    if (widget.isStepDone && widget.isCorrect)      return AppTheme.primaryGreenDk;
    if (widget.isSelected)                         return AppTheme.accentOrange.withValues(alpha: 0.8);
    return const Color(0xFFBBBBBB);
  }

  List<BoxShadow> _resolveShadow() {
    if (_isActive) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 2,
          offset: const Offset(0, 2),
        ),
      ];
    }
    
    final List<BoxShadow> shadows = [
      BoxShadow(color: _bottomEdgeColor, blurRadius: 0, offset: const Offset(0, 5)),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.07),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];

    if (widget.isHint) {
      shadows.add(
        BoxShadow(
          color: Colors.amber.withValues(alpha: 0.9),
          blurRadius: 15,
          spreadRadius: 3,
        ),
      );
    }

    return shadows;
  }


  @override
  Widget build(BuildContext context) {
    final bool pressed = _isActive;

    return AnimatedBuilder(
      animation: _errorAnim,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isDimmed ? 0.35 : 1.0, // TAREA 4
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(
              top:    pressed ? 4.0 : 0.0,
              bottom: pressed ? 0.0 : 4.0,
            ),
            decoration: BoxDecoration(
              color: _resolveBackground(),
              borderRadius: AppTheme.tokenRadius,
              border: Border.all(
                color: _showingError
                    ? AppTheme.errorRed
                    : (pressed
                        ? Colors.black.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.06)),
                width: _showingError ? 2.0 : 1.2,
              ),
              boxShadow: _resolveShadow(),
            ),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: AppTheme.tokenRadius,
        child: InkWell(
          onTap: (widget.isStepDone || !widget.isEnabled) ? null : widget.onTap, 
          borderRadius: AppTheme.tokenRadius,
          splashColor: Colors.white.withValues(alpha: 0.35),
          highlightColor: Colors.black.withValues(alpha: 0.05),
          child: Container(
            // TAREA 2: Restricciones estrictas
            constraints: const BoxConstraints(minWidth: 38, minHeight: 48, maxHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            alignment: Alignment.center,
            child: Text(
              MathTokenWidget.formatMathText(widget.token.value),
              style: TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.w900,
                color:      _resolveTextColor(),
                fontFamily: 'Nunito',
                height:     1.0,
                shadows: pressed
                    ? [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
