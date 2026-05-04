import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/robot_part_entity.dart';
import '../providers/player_profile_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// FarmScreen — Mi Granja
//
// El niño ve su llamita en el centro de la pantalla.
// Debajo, una lista de objetos o comida comprada.
// ─────────────────────────────────────────────────────────────────────────────

class FarmScreen extends ConsumerWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile  = ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);
    final equipped = profile.equippedPartIds.toSet();
    final owned    = profile.ownedPartIds.toSet();
    final allParts = LlamaObjectCatalog.all;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // ── Fondo degradado ──────────────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.scaffoldGradient),
            child: SizedBox.expand(),
          ),

          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── AppBar manual ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.textDark, size: 28),
                      ),
                      Text(
                        'Mi Granja 🏡',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const Spacer(),
                      // Contador de monedas disponibles
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                              width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🌟', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.availableCoins} Monedas',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryGreenDk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Robot visual central ──────────────────────────────────
                _GarageRobotAvatar(equippedIds: equipped),

                const SizedBox(height: 8),

                // Hint
                Center(
                  child: Text(
                    equipped.isEmpty
                        ? 'Toca un objeto para usarlo 👇'
                        : '${equipped.length} objeto(s) activos ✅',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Lista de piezas ──────────────────────────────────────
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: allParts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final part      = allParts[i];
                    final isOwned   = owned.contains(part.id);
                    final isEquip   = equipped.contains(part.id);
                    return _PartTile(
                      part: part,
                      isOwned: isOwned,
                      isEquipped: isEquip,
                      onTap: isOwned
                          ? () => notifier.toggleEquip(part.id)
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GarageRobotAvatar — Interfaz RPG de Equipamiento Orbital
// ─────────────────────────────────────────────────────────────────────────────

class _GarageRobotAvatar extends StatelessWidget {
  final Set<String> equippedIds;
  const _GarageRobotAvatar({required this.equippedIds});

  @override
  Widget build(BuildContext context) {
    // Buscamos dinámicamente qué hay equipado en cada categoría
    LlamaObjectEntity? _findEquipped(LlamaObjectType type) {
      try {
        return LlamaObjectCatalog.all.firstWhere(
          (p) => p.partType == type && equippedIds.contains(p.id),
        );
      } catch (_) {
        return null;
      }
    }

    final head     = _findEquipped(LlamaObjectType.head);
    final body     = _findEquipped(LlamaObjectType.body);
    final leftArm  = _findEquipped(LlamaObjectType.leftArm);
    final rightArm = _findEquipped(LlamaObjectType.rightArm);
    final legs     = _findEquipped(LlamaObjectType.legs);
    final skin     = _findEquipped(LlamaObjectType.skin);

    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Anillo decorativo exterior (RPG Aura) ──
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                width: 4,
                style: BorderStyle.solid,
              ),
            ),
          ),

          // ── Capa Base: La Llama Central ──
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryGreen.withValues(alpha: 0.2),
                  AppTheme.primaryGreen.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/llama_base.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🦙', style: TextStyle(fontSize: 90)),
            ),
          ),

          // ── Orbes de Equipamiento Dinámicos (RPG Slots) ──
          
          // Slot Head - Arriba Centro
          _buildOrbitalSlot(
            item: head,
            alignment: const Alignment(0, -0.9),
            color: Colors.purpleAccent,
          ),

          // Slot Body - Derecha
          _buildOrbitalSlot(
            item: body,
            alignment: const Alignment(0.9, 0),
            color: Colors.redAccent,
          ),

          // Slot Left Arm - Arriba Izquierda
          _buildOrbitalSlot(
            item: leftArm,
            alignment: const Alignment(-0.85, -0.6),
            color: Colors.teal,
          ),

          // Slot Right Arm - Arriba Derecha
          _buildOrbitalSlot(
            item: rightArm,
            alignment: const Alignment(0.85, -0.6),
            color: Colors.blueAccent,
          ),

          // Slot Legs - Abajo Izquierda
          _buildOrbitalSlot(
            item: legs,
            alignment: const Alignment(-0.85, 0.6),
            color: Colors.orangeAccent,
          ),

          // Slot Skin - Abajo Derecha
          _buildOrbitalSlot(
            item: skin,
            alignment: const Alignment(0.85, 0.6),
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  // Helper para construir el Slot Orbital Animado
  Widget _buildOrbitalSlot({
    required LlamaObjectEntity? item,
    required Alignment alignment,
    required Color color,
  }) {
    final bool isEquipped = item != null;
    
    return Align(
      alignment: alignment,
      child: AnimatedScale(
        scale: isEquipped ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: AnimatedOpacity(
          opacity: isEquipped ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            // Carga la imagen dinámica usando el ID. Toma como fallback su emoji exacto.
            child: Image.asset(
              isEquipped ? 'assets/${item.id}.png' : '',
              width: 45,
              height: 45,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Text(isEquipped ? item.emoji : '', style: const TextStyle(fontSize: 34)),
            ),
          ),
        ),
      ),
    );
  }
}

class _LlamaObject extends StatelessWidget {
  final String emoji;
  final double size;
  final Color color;
  final double? width;
  final double? height;
  final String? label;

  const _LlamaObject({
    required this.emoji,
    required this.size,
    required this.color,
    this.width,
    this.height,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      width: width ?? size * 1.2,
      height: height ?? size * 1.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.40),
              blurRadius: 10,
              offset: const Offset(0, 4)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 0,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.60)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PartTile — Tarjeta de pieza en la lista del garaje
// ─────────────────────────────────────────────────────────────────────────────

class _PartTile extends StatelessWidget {
  final LlamaObjectEntity part;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback? onTap;

  const _PartTile({
    required this.part,
    required this.isOwned,
    required this.isEquipped,
    this.onTap,
  });

  Color get _rarityColor => switch (part.rarity) {
        LlamaObjectRarity.common    => const Color(0xFF757575),
        LlamaObjectRarity.rare      => const Color(0xFF1976D2),
        LlamaObjectRarity.epic      => const Color(0xFF7B1FA2),
        LlamaObjectRarity.legendary => const Color(0xFFE65100),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isEquipped
              ? AppTheme.primaryGreen.withValues(alpha: 0.12)
              : (isOwned ? Colors.white : Colors.white.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEquipped
                ? AppTheme.primaryGreen
                : (isOwned
                    ? Colors.grey.withValues(alpha: 0.25)
                    : Colors.grey.withValues(alpha: 0.15)),
            width: isEquipped ? 2.0 : 1.0,
          ),
          boxShadow: isOwned && !isEquipped
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Row(
          children: [
            // ── Emoji de la pieza ───────────────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isOwned ? _rarityColor.withValues(alpha: 0.15) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _rarityColor.withValues(alpha: isOwned ? 0.40 : 0.15),
                    width: 1.5),
              ),
              child: Center(
                child: Text(
                  isOwned ? part.emoji : '🔒',
                  style: TextStyle(fontSize: isOwned ? 26 : 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Información ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          part.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isOwned
                                ? AppTheme.textDark
                                : AppTheme.textMedium.withValues(alpha: 0.60),
                          ),
                        ),
                      ),
                      // Badge rareza
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _rarityColor.withValues(
                              alpha: isOwned ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          part.rarity.name.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: _rarityColor.withValues(
                                alpha: isOwned ? 1.0 : 0.40),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isOwned ? part.description : 'Cuesta ${part.coinCost} Monedas',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppTheme.textMedium.withValues(
                          alpha: isOwned ? 0.80 : 0.50),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ── Estado (equipado / no equipado / bloqueado) ──────────────
            if (!isOwned)
              const Icon(Icons.lock_rounded, color: Color(0xFFBDBDBD), size: 20)
            else if (isEquipped)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✓ ON',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Usar',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textMedium,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
