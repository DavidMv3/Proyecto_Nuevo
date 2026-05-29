import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTIDAD DE PIEZA DEL ROBOT
// ─────────────────────────────────────────────────────────────────────────────

/// Categoría de la pieza (define dónde se muestra en el robot visual).
enum LlamaObjectType { head, body, leftArm, rightArm, legs, skin }

/// Rareza de la pieza (afecta colores y bordes en la tienda).
enum LlamaObjectRarity { common, rare, epic, legendary }

/// Objeto de mejora que el jugador compra con puntos (🌟).
class LlamaObjectEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final int coinCost;
  final LlamaObjectType partType;
  final LlamaObjectRarity rarity;

  /// Ícono de Material que representa visualmente la pieza en la UI.
  final String emoji;

  const LlamaObjectEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.partType,
    required this.rarity,
    required this.emoji,
  });

  @override
  List<Object?> get props => [id];
}

// ─────────────────────────────────────────────────────────────────────────────
// CATÁLOGO DE PIEZAS — 10 mejoras disponibles en la tienda
// ─────────────────────────────────────────────────────────────────────────────

class LlamaObjectCatalog {
  static const List<LlamaObjectEntity> all = [

    // ── Nivel COMMON ─────────────────────────────────────────────────────────

    LlamaObjectEntity(
      id: 'part_body_basic',
      name: 'Poncho de Lana',
      description: 'Te mantiene calientito mientras calculas.',
      coinCost: 50,
      partType: LlamaObjectType.body,
      rarity: LlamaObjectRarity.common,
      emoji: '🧣',
    ),
    LlamaObjectEntity(
      id: 'part_left_arm',
      name: 'Guantes de Alpaca',
      description: 'Para escribir sumas sin frío.',
      coinCost: 60,
      partType: LlamaObjectType.leftArm,
      rarity: LlamaObjectRarity.common,
      emoji: '🧤',
    ),
    LlamaObjectEntity(
      id: 'part_right_arm',
      name: 'Amuleto de Suerte',
      description: 'Atrae la sabiduría de los ancestros.',
      coinCost: 80,
      partType: LlamaObjectType.rightArm,
      rarity: LlamaObjectRarity.common,
      emoji: '🧿',
    ),

    // ── Nivel RARE ────────────────────────────────────────────────────────────

    LlamaObjectEntity(
      id: 'part_legs_boosters',
      name: 'Oshas Chaski',
      description: 'Corres por las montañas como un rayo.',
      coinCost: 150,
      partType: LlamaObjectType.legs,
      rarity: LlamaObjectRarity.rare,
      emoji: '🩴',
    ),
    LlamaObjectEntity(
      id: 'part_head_basic',
      name: 'Chullo de Colores',
      description: 'Gorro tejido con hilos de sabiduría.',
      coinCost: 200,
      partType: LlamaObjectType.head,
      rarity: LlamaObjectRarity.rare,
      emoji: '🧶',
    ),
    LlamaObjectEntity(
      id: 'part_skin_neon',
      name: 'Espejo Solar',
      description: 'Refleja la luz del Inti en tus ojos.',
      coinCost: 250,
      partType: LlamaObjectType.skin,
      rarity: LlamaObjectRarity.rare,
      emoji: '🌞',
    ),

    // ── Nivel EPIC ────────────────────────────────────────────────────────────

    LlamaObjectEntity(
      id: 'part_legs_tracks',
      name: 'Pezuña de Oro',
      description: 'Avanza seguro por los senderos rocosos.',
      coinCost: 400,
      partType: LlamaObjectType.legs,
      rarity: LlamaObjectRarity.epic,
      emoji: '👟',
    ),
    LlamaObjectEntity(
      id: 'part_head_titan',
      name: 'Sombrero de Paja',
      description: 'Protección clásica para días soleados.',
      coinCost: 500,
      partType: LlamaObjectType.head,
      rarity: LlamaObjectRarity.epic,
      emoji: '👒',
    ),

    // ── Nivel LEGENDARY ──────────────────────────────────────────────────────

    LlamaObjectEntity(
      id: 'part_cannon_arm',
      name: 'Cetro del Inca',
      description: 'Poder ancestral para resolver todo.',
      coinCost: 800,
      partType: LlamaObjectType.leftArm,
      rarity: LlamaObjectRarity.legendary,
      emoji: '🔱',
    ),
    LlamaObjectEntity(
      id: 'part_core_quantum',
      name: 'Corazón de los Andes',
      description: 'El espíritu eterno de la montaña contigo.',
      coinCost: 1500,
      partType: LlamaObjectType.body,
      rarity: LlamaObjectRarity.legendary,
      emoji: '🌋',
    ),
  ];
}
