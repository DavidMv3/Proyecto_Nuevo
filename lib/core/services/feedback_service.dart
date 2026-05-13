import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FeedbackService — Sonidos + Vibración para el "Game Feel"
//
// Singleton liviano. Se inicializa una vez en main() y permanece activo
// durante toda la sesión. Cada acción pedagógica llama a un método específico:
//
//   FeedbackService.instance.playCorrect()   → "Ding" + vibración corta
//   FeedbackService.instance.playError()     → "Buzz" + vibración doble
//   FeedbackService.instance.playVictory()   → Fanfarria + vibración larga
//
// HAPTICS: usa HapticFeedback de Flutter (sin permisos extra en Android).
// AUDIO  : usa audioplayers con AudioPool para latencia mínima (<30 ms).
// ─────────────────────────────────────────────────────────────────────────────

class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  // ── Jugadores de audio pre-cargados ────────────────────────────────────────
  AudioPlayer? _correctPlayer;
  AudioPlayer? _errorPlayer;
  AudioPlayer? _victoryPlayer;

  bool _initialized = false;

  /// true cuando la app está en segundo plano — silencia todo.
  bool _isInBackground = false;

  // ── Inicialización — llamar una sola vez en main() ──────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Crear un AudioPlayer por efecto para evitar conflictos de canal
    _correctPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
    _errorPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
    _victoryPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

    // Pre-cargar los assets en memoria (reduce latencia al primer toque)
    await _correctPlayer!.setSource(AssetSource('sounds/correct.wav'));
    await _errorPlayer!.setSource(AssetSource('sounds/error.wav'));
    await _victoryPlayer!.setSource(AssetSource('sounds/victory.wav'));

    // Volúmenes calibrados para niños (no ser ensordecedor)
    await _correctPlayer!.setVolume(0.75);
    await _errorPlayer!.setVolume(0.60);
    await _victoryPlayer!.setVolume(0.80);
  }

  // ── Ciclo de vida: segundo plano / primer plano ─────────────────────────────

  /// Llamar cuando la app pasa a segundo plano (AppLifecycleState.paused/hidden).
  void onBackground() {
    _isInBackground = true;
    // Detener cualquier sonido que esté reproduciéndose
    _correctPlayer?.stop();
    _errorPlayer?.stop();
    _victoryPlayer?.stop();
  }

  /// Llamar cuando la app vuelve a primer plano (AppLifecycleState.resumed).
  void onForeground() {
    _isInBackground = false;
  }

  // ── Liberar recursos ────────────────────────────────────────────────────────
  Future<void> dispose() async {
    await _correctPlayer?.dispose();
    await _errorPlayer?.dispose();
    await _victoryPlayer?.dispose();
    _initialized = false;
  }

  // ── Acierto: "Ding!" + vibración ligera ────────────────────────────────────
  void playCorrect() {
    if (_isInBackground) return;
    _correctPlayer?.stop().then((_) => _correctPlayer?.resume());
    HapticFeedback.lightImpact();
  }

  // ── Error: "Buzz" + doble vibración ────────────────────────────────────────
  void playError() {
    if (_isInBackground) return;
    _errorPlayer?.stop().then((_) => _errorPlayer?.resume());
    // Doble golpe fuerte — fire-and-forget sin bloquear el flujo async
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), () => HapticFeedback.heavyImpact());
  }

  // ── Victoria: fanfarria + vibración larga ──────────────────────────────────
  void playVictory() {
    if (_isInBackground) return;
    _victoryPlayer?.stop().then((_) => _victoryPlayer?.resume());
    // Vibración larga simulada — fire-and-forget
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
  }

  // ── Token parcialmente correcto (selección intermedia) ─────────────────────
  void playSelection() {
    if (_isInBackground) return;
    HapticFeedback.selectionClick();
  }
}
