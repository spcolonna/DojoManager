/// Sistema de estrategias de combate.
/// Cada estrategia aplica modificadores sobre los stats efectivos
/// y define vulnerabilidades contra otras estrategias.
///
/// Para rebalancear el combate: solo tocar este archivo.
class FightStrategyConfig {
  FightStrategyConfig._();

  static const Map<String, FightStrategyDefinition> strategies = {

    // ── AGRESIVO ──────────────────────────────────────────────────────────────
    // Va para adelante. Alta presión, muchos intentos de punto.
    // Gasta más stamina. Si el rival tiene alta MEN, le lee fácil y contraataca.
    'aggressive': FightStrategyDefinition(
      id: 'aggressive',
      titleKey: 'strategy_aggressive',
      descKey: 'strategy_aggressive_desc',

      // Multiplica los stats efectivos al calcular el ataque
      attackMultipliers: FightStatMultipliers(
        str: 1.35,   // +35% fuerza efectiva — golpes más pesados
        spd: 1.20,   // +20% velocidad — más intentos por tick
        tec: 0.80,   // −20% técnica — sacrifica precisión por potencia
        def: 0.65,   // −35% defensa — se expone al contraatacar
        men: 0.70,   // −30% mentalidad — predecible, fácil de leer
      ),

      // Costo de stamina por tick (más alto = se cansa más rápido)
      staminaCostPerTick: 8.0,

      // Si el rival tiene MEN ≥ este umbral, recibe un bonus de contraataque
      // (simula que un luchador inteligente lee la agresividad)
      vulnerableTo: StrategyVulnerability(
        triggerStat: 'men',
        triggerThreshold: 18,
        counterBonus: 0.30,   // +30% de probabilidad de contraataque del rival
        counterKey: 'technical',  // el estilo técnico/calmo explota esto mejor
      ),

      // Bonus especial: si el rival tiene DEF baja, el agresivo hace más daño
      bonusAgainst: StrategyBonus(
        triggerStat: 'def',
        triggerBelow: 12,
        damageBonus: 0.25,
      ),
    ),

    // ── DEFENSIVO ─────────────────────────────────────────────────────────────
    // Espera, bloquea, contraataca. Difícil de puntuar en su contra.
    // Puntúa poco pero de forma segura. Pierde contra grappling.
    'defensive': FightStrategyDefinition(
      id: 'defensive',
      titleKey: 'strategy_defensive',
      descKey: 'strategy_defensive_desc',

      attackMultipliers: FightStatMultipliers(
        str: 0.70,   // −30% fuerza — no busca el KO
        spd: 0.85,   // −15% velocidad — movimientos más calculados
        tec: 1.20,   // +20% técnica — aprovecha cada oportunidad
        def: 1.50,   // +50% defensa — muy difícil de puntuar
        men: 1.30,   // +30% mentalidad — lee bien al rival
      ),

      staminaCostPerTick: 2.5,   // muy bajo — aguanta muchos rounds

      // Vulnerable al grappling: llevar la pelea al suelo nulifica la guardia
      vulnerableTo: StrategyVulnerability(
        triggerStat: 'str',
        triggerThreshold: 20,
        counterBonus: 0.35,
        counterKey: 'grappling',
      ),

      bonusAgainst: StrategyBonus(
        triggerStat: 'men',
        triggerBelow: 10,
        damageBonus: 0.20,   // los impulsivos no pueden con un buen guardista
      ),
    ),

    // ── TÉCNICO ───────────────────────────────────────────────────────────────
    // Calmo, preciso. Lee la pelea. Explota los errores del agresivo.
    // Pierde si el rival es muy rápido y no le da tiempo a pensar.
    'technical': FightStrategyDefinition(
      id: 'technical',
      titleKey: 'strategy_technical',
      descKey: 'strategy_technical_desc',

      attackMultipliers: FightStatMultipliers(
        str: 0.85,   // −15% fuerza — no depende de la potencia
        spd: 0.90,   // −10% velocidad — prioriza timing sobre velocidad
        tec: 1.45,   // +45% técnica — el núcleo de esta estrategia
        def: 1.10,   // +10% defensa — calmo = difícil de sorprender
        men: 1.40,   // +40% mentalidad — máxima lectura del rival
      ),

      staminaCostPerTick: 4.0,

      // Vulnerable a velocidad muy alta: si el rival es muy rápido,
      // no tiene tiempo de analizar y reaccionar
      vulnerableTo: StrategyVulnerability(
        triggerStat: 'spd',
        triggerThreshold: 22,
        counterBonus: 0.25,
        counterKey: 'aggressive',
      ),

      // Bonus explosivo contra el agresivo: lo lee y lo explota
      bonusAgainst: StrategyBonus(
        triggerStat: 'men',   // el técnico tiene mucha MEN
        triggerBelow: 14,     // si el rival tiene MEN baja (ej: agresivo)
        damageBonus: 0.35,
      ),
    ),

    // ── GRAPPLING ─────────────────────────────────────────────────────────────
    // Lleva la pelea al suelo. Desgasta al rival físicamente.
    // Un derribo exitoso destruye el ritmo del defensivo.
    // Pierde contra el técnico que sabe leer y evitar el clinch.
    'grappling': FightStrategyDefinition(
      id: 'grappling',
      titleKey: 'strategy_grappling',
      descKey: 'strategy_grappling_desc',

      attackMultipliers: FightStatMultipliers(
        str: 1.50,   // +50% fuerza — el derribo depende de la fuerza
        spd: 0.75,   // −25% velocidad — movimientos deliberados
        tec: 1.10,   // +10% técnica — la técnica de agarre importa
        def: 0.80,   // −20% defensa — en pie queda expuesto
        men: 0.85,   // −15% mentalidad — plan de juego simple y físico
      ),

      staminaCostPerTick: 6.5,   // alto — el agarre consume mucha energía

      // Vulnerable al técnico: lee el intento de derribo y lo evita
      vulnerableTo: StrategyVulnerability(
        triggerStat: 'tec',
        triggerThreshold: 20,
        counterBonus: 0.30,
        counterKey: 'technical',
      ),

      bonusAgainst: StrategyBonus(
        triggerStat: 'def',     // destruye la guardia del defensivo
        triggerBelow: 999,      // siempre aplica contra defensive
        damageBonus: 0.40,
      ),

      // Bonus especial: si logra un derribo, penaliza la stamina del rival
      hasTakedownMechanic: true,
      takedownStaminaPenalty: 20.0,
      takedownThreshold: 0.82,   // umbral para intentar derribo (más fácil que el default)
    ),
  };

  // ── TABLA DE VENTAJAS / PIEDRA PAPEL TIJERA ────────────────────────────────
  //
  //   AGGRESSIVE  → golpea fuerte a DEFENSIVE
  //   DEFENSIVE   → aguanta a AGGRESSIVE, explota su impulsividad
  //   TECHNICAL   → lee a AGGRESSIVE, lo contraataca
  //   GRAPPLING   → destruye a DEFENSIVE en el suelo
  //   TECHNICAL   → lee y evita el GRAPPLING
  //   GRAPPLING   → supera la guardia del DEFENSIVE
  //
  //   Ciclo principal: AGGRESSIVE → DEFENSIVE → GRAPPLING → TECHNICAL → AGGRESSIVE
  //
  static const String cycleDescription = '''
  AGGRESSIVE beats DEFENSIVE (overwhelms the guard with volume)
  DEFENSIVE beats AGGRESSIVE (reads and counters impulsive attacks)
  TECHNICAL beats AGGRESSIVE (reads patterns, precise counters)
  GRAPPLING beats DEFENSIVE (takes the fight to the ground)
  TECHNICAL beats GRAPPLING (reads and avoids the clinch)
  GRAPPLING beats AGGRESSIVE (ties them up before they can attack)
  ''';

  // Multiplicador de daño entre estrategias [atacante][defensor]
  // >1.0 = ventaja para el atacante
  static const Map<String, Map<String, double>> strategyMatchupModifiers = {
    'aggressive': {
      'defensive':  1.20,   // agresivo presiona al defensivo
      'technical':  0.80,   // técnico lo lee y lo contraataca
      'grappling':  0.85,   // el grappler lo clinchea antes de que ataque
    },
    'defensive': {
      'aggressive': 1.25,   // el defensivo aguanta y contraataca
      'grappling':  0.70,   // el grappling lo lleva al suelo
      'technical':  0.90,   // el técnico encuentra los huecos
    },
    'technical': {
      'aggressive': 1.30,   // lee y explota la agresividad
      'grappling':  1.20,   // evita el clinch con anticipación
      'defensive':  1.05,   // leve ventaja por encontrar huecos
    },
    'grappling': {
      'defensive':  1.35,   // destruye la guardia en el suelo
      'aggressive': 1.15,   // lo clinchea antes del ataque
      'technical':  0.75,   // el técnico lo evita
    },
  };

  // ── ESTRATEGIA POR DEFECTO (auto-selección por stats) ─────────────────────
  static String autoSelectStrategy(Map<String, int> stats) {
    final sorted = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominant = sorted.first.key;

    return switch (dominant) {
      'str' => 'grappling',
      'spd' => 'aggressive',
      'tec' => 'technical',
      'def' => 'defensive',
      'men' => 'technical',
      _     => 'balanced',
    };
  }
}

// ─── DATA CLASSES ─────────────────────────────────────────────────────────────

class FightStrategyDefinition {
  final String id;
  final String titleKey;
  final String descKey;
  final FightStatMultipliers attackMultipliers;
  final double staminaCostPerTick;
  final StrategyVulnerability? vulnerableTo;
  final StrategyBonus? bonusAgainst;
  final bool hasTakedownMechanic;
  final double takedownStaminaPenalty;
  final double takedownThreshold;

  const FightStrategyDefinition({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.attackMultipliers,
    required this.staminaCostPerTick,
    this.vulnerableTo,
    this.bonusAgainst,
    this.hasTakedownMechanic = false,
    this.takedownStaminaPenalty = 15.0,
    this.takedownThreshold = 0.90,
  });
}

class FightStatMultipliers {
  final double str;
  final double spd;
  final double tec;
  final double def;
  final double men;

  const FightStatMultipliers({
    required this.str,
    required this.spd,
    required this.tec,
    required this.def,
    required this.men,
  });

  /// Aplica los multiplicadores sobre los stats reales y devuelve los efectivos.
  Map<String, double> apply(Map<String, int> stats) => {
    'str': stats['str']! * str,
    'spd': stats['spd']! * spd,
    'tec': stats['tec']! * tec,
    'def': stats['def']! * def,
    'men': stats['men']! * men,
  };
}

/// Define contra qué tipo de rival/estrategia esta estrategia es vulnerable.
class StrategyVulnerability {
  /// Stat del rival que activa la vulnerabilidad.
  final String triggerStat;

  /// Si el stat del rival supera este umbral, se activa.
  final int triggerThreshold;

  /// Bonus de probabilidad de contraataque para el rival.
  final double counterBonus;

  /// Clave de estrategia rival que explota mejor esta vulnerabilidad.
  final String counterKey;

  const StrategyVulnerability({
    required this.triggerStat,
    required this.triggerThreshold,
    required this.counterBonus,
    required this.counterKey,
  });
}

/// Bonus de daño cuando el rival tiene un stat por debajo de un umbral.
class StrategyBonus {
  final String triggerStat;
  final int triggerBelow;      // se activa si stat rival < triggerBelow
  final double damageBonus;    // multiplicador adicional de daño

  const StrategyBonus({
    required this.triggerStat,
    required this.triggerBelow,
    required this.damageBonus,
  });
}