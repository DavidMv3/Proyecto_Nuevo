import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/robot_part_entity.dart';
import '../providers/player_profile_provider.dart';

/// Pantalla Llamita: muestra visualmente los objetos que el jugador ya posee
/// y los que aún le faltan para cuidar a su llamita.
class LlamaScreen extends ConsumerWidget {
  const LlamaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    final owned = LlamaObjectCatalog.all
        .where((p) => profile.ownsPart(p.id))
        .toList();
    final missing = LlamaObjectCatalog.all
        .where((p) => !profile.ownsPart(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('🦙 Mi Llamita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progreso del robot
            _LlamaProgressCard(
              collected: owned.length,
              total: LlamaObjectCatalog.all.length,
              pieces: profile.availableCoins,
            ),
            const SizedBox(height: 24),

            // Partes coleccionadas
            if (owned.isNotEmpty) ...[
              const _SectionHeader(title: '✅ Objetos Conseguidos', emoji: '🟢'),
              const SizedBox(height: 12),
              ...owned.map((part) => _LlamaPartTile(part: part, owned: true)),
              const SizedBox(height: 24),
            ],

            // Piezas faltantes
            if (missing.isNotEmpty) ...[
              const _SectionHeader(title: 'Objetos por Conseguir', emoji: '🔒'),
              const SizedBox(height: 12),
              ...missing.map((part) => _LlamaPartTile(part: part, owned: false)),
            ],

            if (owned.length == LlamaObjectCatalog.all.length)
              const _CompletionBanner(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _LlamaProgressCard extends StatelessWidget {
  final int collected;
  final int total;
  final int pieces;
  const _LlamaProgressCard(
      {required this.collected, required this.total, required this.pieces});

  @override
  Widget build(BuildContext context) {
    final progress = collected / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen.withValues(alpha: 0.9),
                   AppTheme.secondaryGreen.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text('🦙', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 8),
          Text(
            '$collected / $total objetos',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                '${pieces} Monedas disponibles',
                style: const TextStyle(fontSize: 16, color: Colors.white70,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppTheme.textDark)),
      ],
    );
  }
}

class _LlamaPartTile extends StatelessWidget {
  final LlamaObjectEntity part;
  final bool owned;
  const _LlamaPartTile({required this.part, required this.owned});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: owned ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: owned ? AppTheme.primaryGreen : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            owned ? part.emoji : '❓',
            style: TextStyle(
                fontSize: 36,
                color: owned ? null : Colors.grey.shade400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owned ? part.name : '???',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: owned ? AppTheme.textDark : Colors.grey.shade400,
                  ),
                ),
                if (owned)
                  Text(
                    part.description,
                    style: TextStyle(fontSize: 13, color: AppTheme.earthBrown),
                  )
                  else
                  Text(
                    'Cuesta ${part.coinCost} Monedas — ¡completa ejercicios!',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Text('🎉', style: TextStyle(fontSize: 52)),
          SizedBox(height: 8),
          Text(
            '¡Llamita Completa!\n¡Eres un Maestro de las Matemáticas!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}
