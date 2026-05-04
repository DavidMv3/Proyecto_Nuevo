import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppTheme — Tema "Eco-Tech Amigable"
//
// Paleta pensada para niños de zonas rurales:
//   • Verde Manzana  → crecimiento, naturaleza  (#5CB85C / #8BC34A)
//   • Naranja Cálido → CTA, botones de acción, avisos de error (#FF9800)
//   • Crema/Celeste  → fondo scaffold (no blanco puro, jamás oscuro)
//
// Filosofía de forma : TODO circular(24) — bloques de juguete, no UI fría.
// Filosofía de elevación: los botones son "físicos", apetecibles de tocar.
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  // ── Paleta principal ─────────────────────────────────────────────────────
  static const Color primaryGreen   = Color(0xFF558B2F); // Verde páramo
  static const Color primaryGreenDk = Color(0xFF33691E); // Selva profunda
  static const Color primaryGreenLt = Color(0xFF8BC34A); // Verde lima páramo
  static const Color accentOrange   = Color(0xFFF57F17); // Amarillo quinua / atardecer
  static const Color accentOrangeLt = Color(0xFFFFCA28); // Dorado andino (combo)
  static const Color accentOrangeBg = Color(0xFFFFF8E1); // Fondo suave amarillo

  // ── Verdes secundarios ───────────────────────────────────────────────────
  static const Color secondaryGreen = Color(0xFF8BC34A); // Verde lima hoja
  static const Color mintSoft       = Color(0xFFB9F6CA); // Menta muy suave

  // ── Neutros cálidos ──────────────────────────────────────────────────────
  static const Color earthBrown     = Color(0xFF5D4037); // Tierra andina
  static const Color warmSand       = Color(0xFFFFECB3); // Arena cálida / token idle
  static const Color skyBlue        = Color(0xFF5B9BD5); // Azul andino Chimborazo
  static const Color skyBlueLt      = Color(0xFFE3F2FD); // Celeste pálido

  // ── Fondo scaffold — crema-verdosa, jamás blanco puro ────────────────────
  /// Color crema-verdoso. Nunca blanco puro, nunca oscuro.
  static const Color backgroundLight  = Color(0xFFF0F8E8);
  static const Color backgroundCream  = Color(0xFFF7FAF0); // Crema muy clara
  static const Color surfaceCard      = Color(0xFFFAFDF5); // Superficie traslúc.

  // ── Texto ────────────────────────────────────────────────────────────────
  static const Color textDark   = Color(0xFF1B3A0F); // Verde muy oscuro andino
  static const Color textMedium = Color(0xFF4A5E35);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color errorRed    = Color(0xFFE53935);
  static const Color errorOrange = Color(0xFFF77F2A); // Error más amigable

  // ── Radios globales ──────────────────────────────────────────────────────
  static final BorderRadius globalRadius = BorderRadius.circular(24);
  static final BorderRadius cardRadius   = BorderRadius.circular(20);
  static final BorderRadius chipRadius   = BorderRadius.circular(16);
  static final BorderRadius tokenRadius  = BorderRadius.circular(18);

  // ─────────────────────────────────────────────────────────────────────────
  // ThemeData
  // ─────────────────────────────────────────────────────────────────────────
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundLight,

      // ── Esquema de color ────────────────────────────────────────────────
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary:                primaryGreen,
        onPrimary:              Colors.white,
        secondary:              accentOrange,
        onSecondary:            Colors.white,
        tertiary:               secondaryGreen,
        error:                  errorOrange,
        onError:                Colors.white,
        surface:                Colors.white,
        onSurface:              textDark,
        surfaceContainerHighest: backgroundLight,
        brightness:             Brightness.light,
      ),

      // ── Tipografía — Nunito: redondeada, amigable, legible ─────────────
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge:   GoogleFonts.nunito(fontWeight: FontWeight.w900, color: textDark),
        displayMedium:  GoogleFonts.nunito(fontWeight: FontWeight.w800, color: textDark),
        headlineLarge:  GoogleFonts.nunito(fontWeight: FontWeight.w800, color: textDark, fontSize: 28),
        headlineMedium: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: textDark, fontSize: 22),
        bodyLarge:      GoogleFonts.nunito(fontWeight: FontWeight.w600, color: textDark, fontSize: 17),
        bodyMedium:     GoogleFonts.nunito(fontWeight: FontWeight.w500, color: textMedium, fontSize: 15),
        labelLarge:     GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 18),
      ),

      // ── ElevatedButton — bloque de juguete físico, elevación 6 ─────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shadowColor:     primaryGreenDk.withValues(alpha: 0.55),
          elevation:       6,
          textStyle: GoogleFonts.nunito(
            fontSize:    22,
            fontWeight:  FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: globalRadius),
        ).copyWith(
          // Efecto "hundimiento": elevation 6 → 2 al presionar
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.pressed))  return 2;
            if (states.contains(WidgetState.disabled)) return 0;
            return 6;
          }),
          // El botón se oscurece sutilmente al presionar
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed))  return primaryGreenDk;
            if (states.contains(WidgetState.disabled)) return const Color(0xFFBDBDBD);
            if (states.contains(WidgetState.hovered))  return primaryGreenLt;
            return primaryGreen;
          }),
        ),
      ),

      // ── OutlinedButton — contorno redondeado naranja ────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentOrange,
          side: const BorderSide(color: accentOrange, width: 2.5),
          textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: globalRadius),
        ),
      ),

      // ── FilledButton — naranja "call to action" ─────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: globalRadius),
          elevation: 6,
        ),
      ),

      // ── Card — burbuja blanca con sombra verde suave ──────────────────
      cardTheme: CardThemeData(
        elevation:       4,
        color:           Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: cardRadius),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        shadowColor: primaryGreen.withValues(alpha: 0.22),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Dialog — redondeado 24 ───────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: globalRadius),
        elevation: 16,
        shadowColor: primaryGreen.withValues(alpha: 0.25),
        backgroundColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize:   22,
          fontWeight: FontWeight.w800,
          color:      textDark,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          color:    textMedium,
          height:   1.5,
        ),
      ),

      // ── SnackBar — redondeado, amigable ─────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior:         SnackBarBehavior.floating,
        shape:            RoundedRectangleBorder(borderRadius: chipRadius),
        backgroundColor:  errorOrange,
        elevation:        6,
        contentTextStyle: GoogleFonts.nunito(
          color:      Colors.white,
          fontWeight: FontWeight.w700,
          fontSize:   15,
        ),
      ),

      // ── AppBar — degradado verde natural ─────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:  primaryGreen,
        foregroundColor:  Colors.white,
        elevation:        0,
        centerTitle:      true,
        shadowColor:      primaryGreenDk.withValues(alpha: 0.4),
        titleTextStyle: GoogleFonts.nunito(
          fontSize:   26,
          fontWeight: FontWeight.w900,
          color:      Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),

      // ── Barra de progreso ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:            accentOrange,
        linearTrackColor: Color(0xFFCCE5B3),
        linearMinHeight:  8,
      ),

      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   Colors.white,
        border: OutlineInputBorder(
          borderRadius: chipRadius,
          borderSide: const BorderSide(color: Color(0xFFB5D6A7), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: chipRadius,
          borderSide: const BorderSide(color: Color(0xFFB5D6A7), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: chipRadius,
          borderSide: const BorderSide(color: primaryGreen, width: 2.5),
        ),
        labelStyle: GoogleFonts.nunito(color: textMedium),
        hintStyle:  GoogleFonts.nunito(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: warmSand,
        selectedColor:   primaryGreen,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: chipRadius),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );

    return base;
  }

  // ── Decoraciones de contenedor reutilizables ────────────────────────────

  /// Panel blanco translúcido — "tablero" sobre el que resaltan los tokens.
  /// Fondo ligeramente más oscuro que el scaffold para crear contraste visual.
  static BoxDecoration get equationPanelDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.78),
    borderRadius: cardRadius,
    border: Border.all(
      color: primaryGreen.withValues(alpha: 0.20),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withValues(alpha: 0.10),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.9),
        blurRadius: 0,
        offset: const Offset(0, 0),
      ),
    ],
  );

  /// Burbuja de diálogo del robot instructor.
  /// TopLeft con radio 6 da el efecto de "pico" apuntando al robot.
  static BoxDecoration get speechBubbleDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
      topLeft:     Radius.circular(6),  // "pico" de burbuja → lado del robot
      topRight:    Radius.circular(22),
      bottomLeft:  Radius.circular(22),
      bottomRight: Radius.circular(22),
    ),
    border: Border.all(
      color: primaryGreen.withValues(alpha: 0.28),
      width: 1.8,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryGreen.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: earthBrown.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Degradado sutil para el scaffold (úsalo en Stack como fondo extra).
  static const LinearGradient scaffoldGradient = LinearGradient(
    colors: [Color(0xFFEFF8E8), Color(0xFFDCF0D6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Decoración para la tarjeta de token matemático en estado normal.
  /// Imita bloque de plástico/madera con borde inferior 3D.
  static BoxDecoration tokenIdle({Color? baseColor}) => BoxDecoration(
    color: baseColor ?? Colors.white,
    borderRadius: tokenRadius,
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.06),
      width: 1,
    ),
    boxShadow: [
      // Sombra inferior nítida → efecto de bloque físico 3D
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
      // Sombra difusa para profundidad
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  /// Decoración para token seleccionado o correcto (hundido + brillante).
  static BoxDecoration tokenActive({required Color color}) => BoxDecoration(
    color: color,
    borderRadius: tokenRadius,
    border: Border.all(
      color: Colors.black.withValues(alpha: 0.10),
      width: 1,
    ),
    boxShadow: [
      // Sombra muy pequeña → efecto hundido
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.14),
        blurRadius: 2,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Decoración para token con pista (hint pulse): resplandor naranja.
  static BoxDecoration tokenHint({Color? baseColor}) => BoxDecoration(
    color: baseColor ?? Colors.white,
    borderRadius: tokenRadius,
    border: Border.all(
      color: accentOrange.withValues(alpha: 0.6),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 0,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: accentOrange.withValues(alpha: 0.35),
        blurRadius: 12,
        spreadRadius: 3,
      ),
    ],
  );
}
