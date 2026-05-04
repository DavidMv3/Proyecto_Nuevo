import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AndeanBackgroundWidget — RNF03 "Entorno Visual Rural Andino"
//
// Paisaje vectorial minimalista inspirado en San Andrés, Ecuador:
//   • Cielo degradado azul andino (opaco — fondo real)
//   • Silueta del Volcán Chimborazo nevado
//   • Dos colinas de páramo en verde cálido
//   • Silueta de alpaca/llama a baja opacidad (marca de agua, ~0.18)
//
// El paisaje tiene dos capas:
//   1. Fondo sólido (cielo + volcán + colinas) — visible, colorido
//   2. Silueta de alpaca — muy baja opacidad para no distraer de los números
// ─────────────────────────────────────────────────────────────────────────────

class AndeanBackgroundWidget extends StatelessWidget {
  final Widget child;

  const AndeanBackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Paisaje base (cielo + volcán + colinas) ────────────────────
        CustomPaint(
          painter: _AndeanLandscapePainter(),
          child: const SizedBox.expand(),
        ),

        // ── 2. Silueta de alpaca — marca de agua muy suave ────────────────
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: CustomPaint(
              painter: _AlpacaSilhouettePainter(),
            ),
          ),
        ),

        // ── 3. UI encima del paisaje ──────────────────────────────────────
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AndeanLandscapePainter — Paisaje base
// ─────────────────────────────────────────────────────────────────────────────

class _AndeanLandscapePainter extends CustomPainter {
  static const Color _skyTop    = Color(0xFF5B9BD5);
  static const Color _skyMid    = Color(0xFF87CEEB);
  static const Color _skyBot    = Color(0xFFB8DFEF);
  static const Color _volcanoDk = Color(0xFF7A97B8);
  static const Color _volcanoLt = Color(0xFF9BB5CC);
  static const Color _snow      = Color(0xFFF0F4F8);
  static const Color _hill1     = Color(0xFF558B2F); // Verde páramo oscuro
  static const Color _hill2     = Color(0xFF689F38); // Verde páramo medio
  static const Color _hill3     = Color(0xFF8BC34A); // Verde colina delantera

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. CIELO ──────────────────────────────────────────────────────────
    final skyShader = const LinearGradient(
      colors:  [_skyTop, _skyMid, _skyBot],
      stops:   [0.0, 0.45, 1.0],
      begin:   Alignment.topCenter,
      end:     Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = skyShader,
    );

    // ── 2. VOLCÁN CHIMBORAZO ──────────────────────────────────────────────
    // Centrado ligeramente a la derecha
    final vx   = w * 0.62;
    final vtop = h * 0.06;
    final vbase = h * 0.50;

    // Ladera izquierda (más oscura)
    final vPathDk = Path()
      ..moveTo(vx - w * 0.36, vbase)
      ..lineTo(vx - w * 0.04, vtop + h * 0.055)
      ..lineTo(vx,             vtop)
      ..lineTo(vx + w * 0.04, vtop + h * 0.06)
      ..lineTo(vx + w * 0.08, vbase)
      ..close();

    // Ladera derecha (más clara)
    final vPathLt = Path()
      ..moveTo(vx,             vtop)
      ..lineTo(vx + w * 0.04, vtop + h * 0.06)
      ..lineTo(vx + w * 0.30, vbase)
      ..lineTo(vx + w * 0.08, vbase)
      ..close();

    canvas.drawPath(vPathDk, Paint()..color = _volcanoDk);
    canvas.drawPath(vPathLt, Paint()..color = _volcanoLt);

    // Cima nevada
    final snowPath = Path()
      ..moveTo(vx - w * 0.055, vtop + h * 0.042)
      ..lineTo(vx,              vtop)
      ..lineTo(vx + w * 0.04,  vtop + h * 0.048)
      ..lineTo(vx + w * 0.015, vtop + h * 0.072)
      ..lineTo(vx - w * 0.025, vtop + h * 0.072)
      ..close();

    canvas.drawPath(snowPath, Paint()..color = _snow);

    // ── 3. COLINA TRASERA ─────────────────────────────────────────────────
    final hill1 = Path()
      ..moveTo(0, vbase + h * 0.02)
      ..cubicTo(w * 0.18, h * 0.36, w * 0.42, h * 0.44, w * 0.62, h * 0.47)
      ..cubicTo(w * 0.78, h * 0.495, w * 0.90, h * 0.48, w, h * 0.50)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill1, Paint()..color = _hill1);

    // ── 4. COLINA MEDIA ────────────────────────────────────────────────────
    final hill2 = Path()
      ..moveTo(0, h * 0.62)
      ..cubicTo(w * 0.22, h * 0.52, w * 0.48, h * 0.56, w * 0.68, h * 0.58)
      ..cubicTo(w * 0.82, h * 0.595, w * 0.92, h * 0.60, w, h * 0.56)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill2, Paint()..color = _hill2);

    // ── 5. COLINA DELANTERA ────────────────────────────────────────────────
    final hill3 = Path()
      ..moveTo(0, h * 0.74)
      ..cubicTo(w * 0.18, h * 0.64, w * 0.42, h * 0.66, w * 0.60, h * 0.68)
      ..cubicTo(w * 0.76, h * 0.70, w * 0.88, h * 0.71, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill3, Paint()..color = _hill3);

    // ── 6. NUBES ──────────────────────────────────────────────────────────
    _cloud(canvas, w * 0.08, h * 0.09, w * 0.13, 0.28);
    _cloud(canvas, w * 0.54, h * 0.05, w * 0.09, 0.18);
    _cloud(canvas, w * 0.80, h * 0.11, w * 0.11, 0.22);
  }

  void _cloud(Canvas canvas, double cx, double cy, double r, double opacity) {
    final p = Paint()..color = Colors.white.withValues(alpha: opacity);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2.4, height: r * 0.75), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.55, cy + r * 0.12), width: r * 1.2, height: r * 0.65), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.65, cy + r * 0.08), width: r * 1.4, height: r * 0.72), p);
  }

  @override
  bool shouldRepaint(_AndeanLandscapePainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// _AlpacaSilhouettePainter — Silueta minimalista de alpaca / llama
//
// Dibujada como marca de agua (opacity=0.15 aplicada en el padre).
// Posicionada en la colina media derecha para máxima inmersión sin distracción.
//
// Construcción: bezier curves unidas para el cuerpo, cuello, cabeza y orejas.
// ─────────────────────────────────────────────────────────────────────────────

class _AlpacaSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFF1B3A0F) // verde oscuro andino
      ..style = PaintingStyle.fill;

    // ── Origen: esquina inferior-derecha de la colina media ────────────────
    // La alpaca tiene ~10% de la altura total de pantalla
    final ox  = w * 0.76;  // x base izquierda
    final oy  = h * 0.62;  // y terreno donde parada
    final sc  = h * 0.11;  // escala general (~11% de la altura)

    // ── CUERPO (elipse horizontal) ─────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ox + sc * 0.60, oy - sc * 0.38),
        width:  sc * 1.30,
        height: sc * 0.60,
      ),
      paint,
    );

    // ── CUELLO (rectángulo inclinado con bezier) ───────────────────────────
    final cuelloPath = Path()
      ..moveTo(ox + sc * 0.18, oy - sc * 0.56)
      ..cubicTo(
        ox + sc * 0.10, oy - sc * 1.05,
        ox + sc * 0.28, oy - sc * 1.10,
        ox + sc * 0.38, oy - sc * 0.78,
      )
      ..cubicTo(
        ox + sc * 0.44, oy - sc * 0.55,
        ox + sc * 0.34, oy - sc * 0.50,
        ox + sc * 0.18, oy - sc * 0.56,
      )
      ..close();
    canvas.drawPath(cuelloPath, paint);

    // ── CABEZA (elipse) ────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ox + sc * 0.24, oy - sc * 1.22),
        width:  sc * 0.34,
        height: sc * 0.28,
      ),
      paint,
    );

    // ── OREJAS ────────────────────────────────────────────────────────────
    // Oreja izquierda
    final orejaL = Path()
      ..moveTo(ox + sc * 0.14, oy - sc * 1.32)
      ..lineTo(ox + sc * 0.08, oy - sc * 1.54)
      ..lineTo(ox + sc * 0.18, oy - sc * 1.50)
      ..close();
    canvas.drawPath(orejaL, paint);

    // Oreja derecha
    final orejaR = Path()
      ..moveTo(ox + sc * 0.28, oy - sc * 1.32)
      ..lineTo(ox + sc * 0.32, oy - sc * 1.54)
      ..lineTo(ox + sc * 0.40, oy - sc * 1.45)
      ..close();
    canvas.drawPath(orejaR, paint);

    // ── PATAS (4 rectángulos redondeados) ─────────────────────────────────
    final legPaint = Paint()
      ..color = const Color(0xFF1B3A0F)
      ..style = PaintingStyle.fill;

    // Pata delantera izquierda
    _leg(canvas, legPaint, ox + sc * 0.14, oy - sc * 0.18, sc);
    // Pata delantera derecha
    _leg(canvas, legPaint, ox + sc * 0.34, oy - sc * 0.18, sc);
    // Pata trasera izquierda
    _leg(canvas, legPaint, ox + sc * 0.78, oy - sc * 0.18, sc);
    // Pata trasera derecha
    _leg(canvas, legPaint, ox + sc * 0.98, oy - sc * 0.18, sc);

    // ── LANA — círculos pequeños sobre el cuerpo ──────────────────────────
    // Textura de vellón: 5 pequeños círculos superpuestos
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(ox + sc * (0.18 + i * 0.24), oy - sc * 0.60),
        sc * 0.12,
        paint,
      );
    }
  }

  void _leg(Canvas canvas, Paint p, double x, double y, double sc) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, sc * 0.12, sc * 0.22),
        const Radius.circular(4),
      ),
      p,
    );
  }

  @override
  bool shouldRepaint(_AlpacaSilhouettePainter old) => false;
}
