import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/robot_part_entity.dart';
import '../providers/player_profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShopScreen — Tienda de Mejoras del Robot
//
// • AppBar muestra las ⭐ piezas disponibles en tiempo real.
// • GridView.builder con tarjetas divididas por rareza.
// • Lógica de compra con descuento en Hive + feedback inmediato.
// ─────────────────────────────────────────────────────────────────────────────

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);

    // Agrupar piezas por rareza para mostrar secciones
    final byRarity = <LlamaObjectRarity, List<LlamaObjectEntity>>{};
    for (final part in LlamaObjectCatalog.all) {
      byRarity.putIfAbsent(part.rarity, () => []).add(part);
    }
    final rarityOrder = [
      LlamaObjectRarity.common,
      LlamaObjectRarity.rare,
      LlamaObjectRarity.epic,
      LlamaObjectRarity.legendary,
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      // ── AppBar con contador de piezas reactivo ──────────────────────────
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Tienda de la Granja',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          // Contador de piezas en el AppBar — se actualiza al comprar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: profile.availableCoins),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$val',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // ── Cuerpo: secciones por rareza ────────────────────────────────────
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Progreso de colección
          _CollectionProgress(
            owned: LlamaObjectCatalog.all
                .where((p) => profile.ownsPart(p.id))
                .length,
            total: LlamaObjectCatalog.all.length,
          ),
          const SizedBox(height: 16),

          // Secciones por rareza
          for (final rarity in rarityOrder)
            if (byRarity.containsKey(rarity)) ...[
              _RarityHeader(rarity: rarity),
              const SizedBox(height: 8),
              _PartsGrid(
                parts: byRarity[rarity]!,
                profile: profile,
                onBuy: (part) async {
                  final success = await notifier.buyPart(part);
                  if (context.mounted) {
                    _showFeedback(context, success, part);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
        ],
      ),
    );
  }

  // ── Feedback de compra ──────────────────────────────────────────────────
  void _showFeedback(
      BuildContext context, bool success, LlamaObjectEntity part) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 2500),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor:
              success ? AppTheme.primaryGreen : AppTheme.errorRed,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Row(
            children: [
              Text(
                success ? part.emoji : '😕',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success
                      ? '¡Conseguiste "${part.name}"!\nGuardado automáticamente ✅'
                      : '¡Necesitas más monedas para este objeto!\nSigue resolviendo ejercicios.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

/// Barra de progreso de colección (piezas compradas / total).
class _CollectionProgress extends StatelessWidget {
  final int owned;
  final int total;
  const _CollectionProgress({required this.owned, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = (owned / total.clamp(1, 99)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🦙 Colección de Objetos',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                '$owned / $total',
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: val,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          if (owned == total) ...[
            const SizedBox(height: 8),
            const Text(
              '🏆 ¡Colección completa! ¡Eres un campeón!',
              style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

/// Encabezado visual de sección con el nombre y color de la rareza.
class _RarityHeader extends StatelessWidget {
  final LlamaObjectRarity rarity;
  const _RarityHeader({required this.rarity});

  static const _data = {
    LlamaObjectRarity.common: (label: 'Común', icon: '🔧', color: Color(0xFF78909C)),
    LlamaObjectRarity.rare: (label: 'Raro', icon: '💎', color: Color(0xFF1976D2)),
    LlamaObjectRarity.epic: (label: 'Épico', icon: '⚡', color: Color(0xFF7B1FA2)),
    LlamaObjectRarity.legendary: (label: 'Legendario', icon: '🔥', color: Color(0xFFE65100)),
  };

  @override
  Widget build(BuildContext context) {
    final d = _data[rarity]!;
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: d.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(d.icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        Text(
          d.label.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: d.color,
          ),
        ),
      ],
    );
  }
}

/// Grid 2 columnas para las tarjetas de una rareza.
class _PartsGrid extends StatelessWidget {
  final List<LlamaObjectEntity> parts;
  final dynamic profile; // PlayerProfileEntity
  final Future<void> Function(LlamaObjectEntity) onBuy;

  const _PartsGrid({
    required this.parts,
    required this.profile,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: parts.length,
      itemBuilder: (context, i) {
        final part = parts[i];
        final owned = profile.ownsPart(part.id) as bool;
        final affordable = profile.canAfford(part.coinCost) as bool;
        return _PartCard(
          part: part,
          owned: owned,
          affordable: affordable,
          onBuy: () => onBuy(part),
        );
      },
    );
  }
}

/// Tarjeta individual de pieza con animación de compra.
class _PartCard extends StatefulWidget {
  final LlamaObjectEntity part;
  final bool owned;
  final bool affordable;
  final VoidCallback onBuy;

  const _PartCard({
    required this.part,
    required this.owned,
    required this.affordable,
    required this.onBuy,
  });

  @override
  State<_PartCard> createState() => _PartCardState();
}

class _PartCardState extends State<_PartCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _buyCtrl;
  late final Animation<double> _buyScale;

  @override
  void initState() {
    super.initState();
    _buyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _buyScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.93), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _buyCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _buyCtrl.dispose();
    super.dispose();
  }

  Color get _rarityColor => switch (widget.part.rarity) {
        LlamaObjectRarity.common     => const Color(0xFF78909C),
        LlamaObjectRarity.rare       => const Color(0xFF1976D2),
        LlamaObjectRarity.epic       => const Color(0xFF7B1FA2),
        LlamaObjectRarity.legendary  => const Color(0xFFE65100),
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _buyCtrl,
      builder: (context, child) =>
          Transform.scale(scale: _buyScale.value, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          color: widget.owned
              ? _rarityColor.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.owned
                ? _rarityColor
                : _rarityColor.withValues(alpha: 0.30),
            width: widget.owned ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.owned
                  ? _rarityColor.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: widget.owned ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Emoji grande + badge de rareza ────────────────────────
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child: Text(
                      widget.part.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  if (widget.owned)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _rarityColor,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12),
                    ),
                ],
              ),

              // ── Nombre ─────────────────────────────────────────────────
              Text(
                widget.part.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: widget.owned ? _rarityColor : AppTheme.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Descripción ────────────────────────────────────────────
              Text(
                widget.part.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.earthBrown.withValues(alpha: 0.8),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Botón o badge de "Tuyo" ────────────────────────────────
              widget.owned
                  ? _OwnedBadge(color: _rarityColor)
                  : _BuyButton(
                      cost: widget.part.coinCost,
                      affordable: widget.affordable,
                      rarityColor: _rarityColor,
                      onTap: () {
                        _buyCtrl.forward(from: 0);
                        widget.onBuy();
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _OwnedBadge extends StatelessWidget {
  final Color color;
  const _OwnedBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'EQUIPADO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  final int cost;
  final bool affordable;
  final Color rarityColor;
  final VoidCallback onTap;

  const _BuyButton({
    required this.cost,
    required this.affordable,
    required this.rarityColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: affordable ? onTap : onTap, // Siempre dispara el feedback
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: affordable
              ? rarityColor
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: affordable
              ? [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              affordable
                  ? Icons.star_rounded
                  : Icons.lock_rounded,
              color: affordable ? const Color(0xFFFFD700) : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              affordable ? '$cost Monedas' : 'Faltan Monedas',
              style: TextStyle(
                color: affordable ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
