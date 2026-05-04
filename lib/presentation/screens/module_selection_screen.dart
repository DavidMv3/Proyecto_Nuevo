import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ModuleSelectionScreen — RF09 "Menú de Temas"
// Ruta: /modules
//
// Muestra una cuadrícula de tarjetas de módulos temáticos.
//   Módulo 1: "Operaciones Combinadas"  → habilitado → /practice/0
//   Módulo 2: "Múltiplos y Divisores"   → deshabilitado (próximamente)
// ─────────────────────────────────────────────────────────────────────────────

class ModuleSelectionScreen extends ConsumerWidget {
  const ModuleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fondo degradado andino ─────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5B9BD5), // Azul andino
                  Color(0xFF87CEEB), // Celeste
                  Color(0xFFB8DFEF), // Celeste suave
                  Color(0xFFDCF0D6), // Verde muy suave
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.30, 0.60, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── Nubes decorativas ──────────────────────────────────────────
          Positioned(
            top: 60,
            left: -20,
            child: _cloudShape(160, 0.28),
          ),
          Positioned(
            top: 90,
            right: -10,
            child: _cloudShape(120, 0.20),
          ),

          // ── Contenido principal ────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── AppBar manual (sin Scaffold AppBar para mantener inmersión)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'MateBot',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Título principal ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Elige tu',
                        style: GoogleFonts.nunito(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(-2, -2),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'aventura 🚀',
                        style: GoogleFonts.nunito(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFE082),
                          height: 1.1,
                          shadows: const [
                            Shadow(
                              color: Color(0xFFBF5900),
                              offset: Offset(-2, -2),
                              blurRadius: 0,
                            ),
                            Shadow(
                              color: Color(0xFFBF5900),
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Selecciona un tema para practicar con ChaskiBot',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Grid de módulos ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      children: [
                        // ── Módulo 1: HABILITADO ─────────────────────────
                        _ModuleCard(
                          emoji: '🔢',
                          title: 'Operaciones\nCombinadas',
                          description:
                              'Suma, resta, multiplicación y división con jerarquía de operaciones.',
                          difficulty: 'Nivel 1',
                          difficultyColor: const Color(0xFF4CAF50),
                          isEnabled: true,
                          onTap: () => context.push('/practice/0'),
                        ),

                        const SizedBox(height: 16),

                        // ── Módulo 2: BLOQUEADO ──────────────────────────
                        const _ModuleCard(
                          emoji: '🔢',
                          title: 'Múltiplos y\nDivisores',
                          description:
                              'Descubre los múltiplos, divisores y factores de números enteros.',
                          difficulty: 'Próximamente',
                          difficultyColor: Color(0xFF9E9E9E),
                          isEnabled: false,
                        ),

                        const SizedBox(height: 16),

                        // ── Módulo 3: BLOQUEADO (extra) ──────────────────
                        const _ModuleCard(
                          emoji: '📐',
                          title: 'Fracciones y\nDecimales',
                          description:
                              'Aprende a sumar, restar y comparar fracciones y números decimales.',
                          difficulty: 'Próximamente',
                          difficultyColor: Color(0xFF9E9E9E),
                          isEnabled: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nube simple decorativa
  static Widget _cloudShape(double width, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: width * 0.45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(width * 0.5),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ModuleCard — Tarjeta de módulo temático
// ─────────────────────────────────────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String description;
  final String difficulty;
  final Color difficultyColor;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _ModuleCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.difficultyColor,
    required this.isEnabled,
    this.onTap,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isEnabled) _shimmer.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
      decoration: BoxDecoration(
        color: widget.isEnabled
            ? Colors.white.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isEnabled
              ? AppTheme.primaryGreen.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.30),
          width: 1.5,
        ),
        boxShadow: widget.isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreenDk.withValues(alpha: 0.30),
                  blurRadius: 0,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // ── Ícono / Emoji ───────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: widget.isEnabled
                    ? const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDk],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
                      ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: widget.isEnabled
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  widget.isEnabled ? widget.emoji : '🔒',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // ── Texto ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge de dificultad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.difficultyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.difficultyColor.withValues(alpha: 0.40),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.difficulty,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: widget.difficultyColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Título
                  Text(
                    widget.title,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: widget.isEnabled
                          ? AppTheme.textDark
                          : AppTheme.textMedium,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Descripción
                  Text(
                    widget.description,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMedium.withValues(alpha: 0.80),
                      height: 1.4,
                    ),
                  ),

                  // "Próximamente" si deshabilitado
                  if (!widget.isEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.lock_rounded,
                            size: 14, color: Color(0xFF9E9E9E)),
                        const SizedBox(width: 4),
                        Text(
                          'Próximamente',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Flecha (solo si habilitado) ──────────────────────────────
            if (widget.isEnabled)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentOrange.withValues(alpha: 0.40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.isEnabled) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: card,
    );
  }
}
