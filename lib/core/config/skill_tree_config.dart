/// Árbol de habilidades: costos, ramas y modificadores por estilo.
/// Los PH (Puntos de Habilidad) son la única moneda de este sistema.
/// NO se compran — solo se ganan entrenando.
class SkillTreeConfig {
  SkillTreeConfig._();

  // ─── COSTOS POR PROFUNDIDAD DEL NODO (0-indexed) ──────────────────────────
  // depth 0 = nodo raíz "Fundamentos"
  // depth 1 = primer nivel de cada rama
  // depth 4 = nodos Elite (requieren faja mínima)
  static const List<int> phCostByNodeDepth = [1, 2, 4, 8, 20];

  // ─── NIVEL DE FAJA MÍNIMO PARA NODOS ELITE ────────────────────────────────
  static const int minBeltLevelForEliteNodes = 7; // faja marrón

  // ─── RAMAS DEL ÁRBOL ──────────────────────────────────────────────────────
  static const List<SkillBranchDefinition> branches = [
    SkillBranchDefinition(
      id: 'power',
      titleKey: 'skill_branch_power',
      colorHex: 0xFFC0392B,
      nodes: [
        SkillNodeDefinition(id: 'heavy_strike',   titleKey: 'skill_heavy_strike',   statBonuses: {'str': 3}, depth: 1),
        SkillNodeDefinition(id: 'takedown',        titleKey: 'skill_takedown',        statBonuses: {'str': 4, 'tec': 2}, depth: 2),
        SkillNodeDefinition(id: 'raw_power',       titleKey: 'skill_raw_power',       statBonuses: {'str': 8}, depth: 3, isElite: true),
      ],
    ),
    SkillBranchDefinition(
      id: 'agility',
      titleKey: 'skill_branch_agility',
      colorHex: 0xFF2980B9,
      nodes: [
        SkillNodeDefinition(id: 'sprint',          titleKey: 'skill_sprint',          statBonuses: {'spd': 3}, depth: 1),
        SkillNodeDefinition(id: 'evasion',         titleKey: 'skill_evasion',         statBonuses: {'spd': 3, 'def': 2}, depth: 2),
        SkillNodeDefinition(id: 'max_speed',       titleKey: 'skill_max_speed',       statBonuses: {'spd': 8}, depth: 3, isElite: true),
      ],
    ),
    SkillBranchDefinition(
      id: 'technique',
      titleKey: 'skill_branch_technique',
      colorHex: 0xFFC9A84C,
      nodes: [
        SkillNodeDefinition(id: 'precision',       titleKey: 'skill_precision',       statBonuses: {'tec': 3}, depth: 1),
        SkillNodeDefinition(id: 'counter_tech',    titleKey: 'skill_counter_tech',    statBonuses: {'tec': 4, 'men': 2}, depth: 2),
        SkillNodeDefinition(id: 'technique_master',titleKey: 'skill_technique_master',statBonuses: {'tec': 8}, depth: 3, isElite: true),
      ],
    ),
    SkillBranchDefinition(
      id: 'guard',
      titleKey: 'skill_branch_guard',
      colorHex: 0xFF27AE60,
      nodes: [
        SkillNodeDefinition(id: 'basic_block',     titleKey: 'skill_basic_block',     statBonuses: {'def': 3}, depth: 1),
        SkillNodeDefinition(id: 'armor',           titleKey: 'skill_armor',           statBonuses: {'def': 5}, depth: 2),
        SkillNodeDefinition(id: 'bunker',          titleKey: 'skill_bunker',          statBonuses: {'def': 8}, depth: 3, isElite: true),
      ],
    ),
    SkillBranchDefinition(
      id: 'mind',
      titleKey: 'skill_branch_mind',
      colorHex: 0xFF8E44AD,
      nodes: [
        SkillNodeDefinition(id: 'anticipation',    titleKey: 'skill_anticipation',    statBonuses: {'men': 3}, depth: 1),
        SkillNodeDefinition(id: 'fight_reading',   titleKey: 'skill_fight_reading',   statBonuses: {'men': 4, 'tec': 2}, depth: 2),
        SkillNodeDefinition(id: 'grand_strategist',titleKey: 'skill_grand_strategist',statBonuses: {'men': 8}, depth: 3, isElite: true),
      ],
    ),
  ];

  // ─── MODIFICADORES POR ESTILO (factor sobre costo base) ──────────────────
  // 0.70 = -30% PH (más fácil), 1.30 = +30% PH (más difícil)
  static const Map<String, Map<String, double>> styleBranchModifiers = {
    'taekwondo':  {'agility': 0.70, 'power': 1.30},
    'judo':       {'guard': 0.70, 'agility': 1.30},
    'muay_thai':  {'power': 0.70, 'mind': 1.30},
    'kung_fu':    {'technique': 0.70, 'mind': 0.70, 'guard': 1.30},
    'bjj':        {'guard': 0.70, 'technique': 0.70, 'agility': 1.30},
    'karate':     {'technique': 0.70, 'power': 1.10},
    'boxing':     {'power': 0.70, 'agility': 0.80, 'guard': 1.20},
    'mma':        {},  // neutro — sin modificadores
  };
}

class SkillBranchDefinition {
  final String id;
  final String titleKey;
  final int colorHex;
  final List<SkillNodeDefinition> nodes;

  const SkillBranchDefinition({
    required this.id,
    required this.titleKey,
    required this.colorHex,
    required this.nodes,
  });
}

class SkillNodeDefinition {
  final String id;
  final String titleKey;
  final Map<String, int> statBonuses;
  final int depth;
  final bool isElite;

  const SkillNodeDefinition({
    required this.id,
    required this.titleKey,
    required this.statBonuses,
    required this.depth,
    this.isElite = false,
  });
}
