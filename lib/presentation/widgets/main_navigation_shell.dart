import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../providers/player_profile_provider.dart';

/// Shell de navegación circular: envuelve todas las pantallas principales
/// con una BottomNavigationBar siempre visible.
///
/// Estructura de tabs:
///   0 → Inicio (/)
///   1 → Practicar (/practice)
///   2 → Mi Robot (/robot)
///   3 → Tienda (/shop)
class MainNavigationShell extends ConsumerWidget {
  final Widget child;
  const MainNavigationShell({super.key, required this.child});

  static const List<_NavItem> _tabs = [
    _NavItem(label: 'Inicio',    icon: Icons.home_rounded,       path: '/',          matchPrefix: '/'),
    _NavItem(label: 'Practicar', icon: Icons.bolt_rounded,  path: '/practice/-1', matchPrefix: '/practice'),
    _NavItem(label: 'Mi Granja', icon: Icons.pets_rounded,       path: '/farm',      matchPrefix: '/farm'),
    _NavItem(label: 'Tienda',    icon: Icons.storefront_rounded, path: '/shop',      matchPrefix: '/shop'),
  ];

  int _tabIndexForLocation(String location) {
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i].matchPrefix)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabIndexForLocation(location);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Scaffold(
      body: Row(
        children: [
          Expanded(child: child),
          Container(
            color: Colors.white,
            child: SafeArea(
              left: false,
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(right: 14.0), // Margen físico adicional para la cámara/borde curvo
                child: SizedBox(
                  width: 86,
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: IntrinsicHeight(
                                  child: NavigationRail(
                                    minWidth: 86,
                                  selectedIndex: currentIndex,
                                  backgroundColor: Colors.white,
                                  indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.18),
                                  groupAlignment: -0.5,
                                  onDestinationSelected: (i) => context.go(_tabs[i].path),
                                  destinations: _tabs.map((tab) => NavigationRailDestination(
                                    icon: Icon(tab.icon, size: 28),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(tab.label, style: const TextStyle(fontSize: 11)),
                                    ),
                                  )).toList(),
                                  labelType: NavigationRailLabelType.all,
                                  selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryGreen, fontSize: 11),
                                  unselectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 11),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  return Scaffold(
    body: child,
    // Barra de piezas persistente encima del nav
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigationBar(
          selectedIndex: currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppTheme.primaryGreen.withValues(alpha: 0.18),
          onDestinationSelected: (i) => context.go(_tabs[i].path),
          destinations: _tabs.map((tab) => NavigationDestination(
            icon: Icon(tab.icon, size: 28),
            label: tab.label,
          )).toList(),
        ),
      ],
    ),
  );
}
}

class _NavItem {
final String label;
final IconData icon;
/// Ruta a la que navega el tab al tocarlo.
final String path;
/// Prefijo usado para detectar si el tab está activo.
final String matchPrefix;
const _NavItem({
  required this.label,
  required this.icon,
  required this.path,
  required this.matchPrefix,
});
}

/// Tira de economía: muestra el saldo de piezas en todo momento.
class _PiecesStrip extends StatelessWidget {
final int pieces;
final bool isVertical;
const _PiecesStrip({required this.pieces, this.isVertical = false});

@override
Widget build(BuildContext context) {
  return Container(
    width: double.infinity,
    color: AppTheme.earthBrown.withValues(alpha: 0.1),
    padding: EdgeInsets.symmetric(horizontal: isVertical ? 4 : 16, vertical: isVertical ? 8 : 4),
    child: isVertical 
      ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$pieces\nMonedas',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.earthBrown,
                  height: 1.1,
                ),
              ),
            ),
          ],
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('🌟', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$pieces Monedas',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.earthBrown,
              ),
            ),
          ],
        ),
  );
}
}
