import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/feedback_service.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/player_profile_local_datasource.dart';
import 'presentation/providers/player_profile_provider.dart';
import 'presentation/screens/level_selection_screen.dart';
import 'presentation/screens/module_selection_screen.dart';
import 'presentation/screens/practice_screen.dart';
import 'presentation/screens/farm_screen.dart';
import 'presentation/screens/shop_screen.dart';
import 'presentation/screens/llama_screen.dart';
import 'presentation/widgets/main_navigation_shell.dart';
import 'presentation/widgets/andean_background.dart';
import 'data/repositories/exercise_repository.dart';

// ---------------------------------------------------------------------------
// Entry Point
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización offline: Hive + datasource
  await Hive.initFlutter();
  final datasource = PlayerProfileLocalDatasource();
  await datasource.init();

  // Pre-cargar sonidos y activar haptics (latencia cero en el primer toque)
  await FeedbackService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inyectamos la instancia ya inicializada del datasource
        playerProfileDatasourceProvider
            .overrideWithValue(datasource),
      ],
      child: const MateAndinaApp(),
    ),
  );
}

// ---------------------------------------------------------------------------
// App Root
// ---------------------------------------------------------------------------

class MateAndinaApp extends StatefulWidget {
  const MateAndinaApp({super.key});

  @override
  State<MateAndinaApp> createState() => _MateAndinaAppState();
}

class _MateAndinaAppState extends State<MateAndinaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FeedbackService.instance.onForeground();
    } else {
      // paused, inactive, hidden, detached → silenciar todo
      FeedbackService.instance.onBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MateAndina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}

// ---------------------------------------------------------------------------
// Router — ShellRoute con Navegación Circular (4 tabs)
// ---------------------------------------------------------------------------

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainNavigationShell(child: child),
      routes: [
        // Tab 0: Inicio
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        // Selección de niveles (Fácil / Medio / Difícil)
        GoRoute(
          path: '/levels',
          builder: (context, state) => const LevelSelectionScreen(),
        ),
        // Selección de módulos (legacy)
        GoRoute(
          path: '/modules',
          builder: (context, state) => const ModuleSelectionScreen(),
        ),
        // Tab 2: Practicar — recibe el índice del ejercicio como path param
        GoRoute(
          path: '/practice/:index',
          builder: (context, state) {
            final raw = state.pathParameters['index'] ?? '0';
            final index = int.tryParse(raw) ?? 0;
            return PracticeScreen(exerciseIndex: index);
          },
        ),
        // Tab: Mi Granja
        GoRoute(
          path: '/farm',
          builder: (context, state) => const FarmScreen(),
        ),
        // Tab: Mi Llamita (workshop)
        GoRoute(
          path: '/llama',
          builder: (context, state) => const LlamaScreen(),
        ),
        // Tab: Tienda
        GoRoute(
          path: '/shop',
          builder: (context, state) => const ShopScreen(),
        ),
      ],
    ),
  ],
);

// ---------------------------------------------------------------------------
// HomeScreen — Pantalla de Inicio MateAndina
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  // ── Animación de flotación del logo ───────────────────────────────────────
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // ── Animación de entrada (fade + slide) ───────────────────────────────────
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Estado del botón 3D (efecto press) ───────────────────────────────────
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Logo flotante: sube/baja 10px en ciclo infinito suave
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Entrada dramática: todo el contenido aparece de abajo
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AndeanBackgroundWidget(
        child: Stack(
          children: [
            // ── Nubes decorativas en el fondo ───────────────────────────────
            Positioned(
              top: size.height * 0.06,
              left: -30,
              child: _CloudShape(width: 180, opacity: 0.35),
            ),
            Positioned(
              top: size.height * 0.10,
              right: -20,
              child: _CloudShape(width: 140, opacity: 0.25),
            ),
            Positioned(
              top: size.height * 0.18,
              left: size.width * 0.3,
              child: _CloudShape(width: 110, opacity: 0.20),
            ),

            // ── Estrellas/destellos en la parte superior ─────────────────────
            ..._buildSparkles(size),

            // ── Contenido principal ──────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.05),

                      // ── 2. LOGO ANIMADO (flotante) ────────────────────────
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: const Color(0xFF8BC34A).withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              // Fallback si el asset no existe
                              errorBuilder: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [Color(0xFF8BC34A), Color(0xFF388E3C)],
                                  ),
                                ),
                                child: const Icon(Icons.smart_toy_rounded,
                                    size: 80, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.03),

                      // ── 3. TÍTULO ESTILIZADO "MateAndina" ──────────────────
                      Text(
                        'MateAndina',
                        style: GoogleFonts.nunito(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            // Contorno grueso tipo caricatura (multiples sombras)
                            const Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(-3, -3),
                              blurRadius: 0,
                            ),
                            const Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(3, -3),
                              blurRadius: 0,
                            ),
                            const Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(-3, 3),
                              blurRadius: 0,
                            ),
                            const Shadow(
                              color: Color(0xFF2E7D32),
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                            // Sombra de profundidad
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Subtítulo con piezas e info del jugador
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '🦙  Monedas: ${profile.availableCoins}  •  Nivel: ${profile.highestUnlockedLevel}',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      // Descripción de la app
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Aprende a resolver ejercicios matemáticos paso a paso y ayuda a tu pequeña llamita a crecer.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── 4. BOTÓN PRINCIPAL 3D "Continuar Práctica" ───────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _isPressed = true),
                          onTapUp: (_) {
                            setState(() => _isPressed = false);
                            
                            // Lanzar Niveles
                            context.push('/levels');
                          },
                          onTapCancel: () => setState(() => _isPressed = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: _isPressed ? 16.0 : 18.0,
                            ),
                            transform: Matrix4.translationValues(
                              0,
                              _isPressed ? 4.0 : 0.0,
                              0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C00), // Naranja vibrante
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                // Sombra 3D hacia abajo
                                BoxShadow(
                                  color: const Color(0xFFBF5900),
                                  offset: Offset(0, _isPressed ? 2 : 6),
                                  blurRadius: 0,
                                ),
                                // Sombra difusa de profundidad
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 8),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🏔️', style: TextStyle(fontSize: 26)),
                                const SizedBox(width: 10),
                                Text(
                                  'Niveles',
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── 5. BOTONES SECUNDARIOS ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          children: [
                            // Tutorial
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/practice/-1'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('📘', style: TextStyle(fontSize: 22)),
                                      const SizedBox(height: 4),
                                      Text('Tutorial',
                                          style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Mi Granja
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go('/farm'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🏡', style: TextStyle(fontSize: 22)),
                                      const SizedBox(height: 4),
                                      Text('Mi Granja',
                                          style: GoogleFonts.nunito(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                        SizedBox(height: size.height * 0.06),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Genera destellos decorativos aleatorios (posición fija para no reconstruir)
  static final List<({double x, double y, double size, double opacity})> _sparkleData = [
    (x: 0.08, y: 0.08, size: 10, opacity: 0.7),
    (x: 0.85, y: 0.05, size: 8,  opacity: 0.6),
    (x: 0.15, y: 0.28, size: 6,  opacity: 0.5),
    (x: 0.78, y: 0.22, size: 9,  opacity: 0.65),
    (x: 0.55, y: 0.04, size: 7,  opacity: 0.55),
    (x: 0.92, y: 0.30, size: 5,  opacity: 0.45),
    (x: 0.04, y: 0.40, size: 6,  opacity: 0.40),
  ];

  List<Widget> _buildSparkles(Size size) {
    return _sparkleData.map((s) {
      return Positioned(
        left: size.width * s.x,
        top: size.height * s.y,
        child: Opacity(
          opacity: s.opacity,
          child: Icon(
            Icons.star_rounded,
            size: s.size * 2,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
}

// ── Widget auxiliar: forma de nube decorativa ─────────────────────────────
class _CloudShape extends StatelessWidget {
  final double width;
  final double opacity;

  const _CloudShape({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: width * 0.45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(width * 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}
