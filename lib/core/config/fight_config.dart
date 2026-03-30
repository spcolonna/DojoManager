class FightConfig {
  FightConfig._();

  // ─── ESTRUCTURA ───────────────────────────────────────────────────────────
  static const int roundsPerFight = 3;
  static const int ticksPerRound  = 15;
  static const double rngMin      = 0.75;
  static const double rngMax      = 1.25;

  // ─── MÁQUINA DE ESTADOS DE MOVIMIENTO ────────────────────────────────────
  // Duración en ticks de cada estado
  static const int ticksCircling    = 3;  // rotan sin acercarse
  static const int ticksApproaching = 2;  // se acercan
  static const int ticksClinch      = 2;  // muy cerca — aquí ocurren los ataques
  static const int ticksRetreating  = 2;  // se alejan tras el intercambio
  // Ciclo total: 3+2+2+2 = 9 ticks → ~1.6 intercambios por round de 15 ticks
  // → máximo 3-4 intentos de scoring por round → score final realista 2-8 pts

  // ─── THRESHOLDS DE SCORING (solo aplican en CLINCH) ──────────────────────
  // Normalizados para stats 8-20: ataque efectivo / defensa efectiva
  static const double cleanHitThreshold    = 1.15; // ratio atk/def para +1
  static const double dominantHitThreshold = 1.45; // ratio atk/def para +2
  static const double takedownThreshold    = 1.55; // ratio para derribo (Grappling)

  // ─── DEFENSA ──────────────────────────────────────────────────────────────
  // Si el ratio def/atk supera este umbral → bloqueo exitoso (escudo)
  static const double blockThreshold       = 0.92;
  // Probabilidad base de intento de bloqueo (se multiplica por DEF normalizada)
  static const double blockBaseProbability = 0.40;

  // ─── PENALIZACIONES DE FATIGA ─────────────────────────────────────────────
  static const double fatigueMediumThreshold  = 0.50;
  static const double fatigueHighThreshold    = 0.80;
  static const double fatigueMediumPenalty    = 0.08;
  static const double fatigueHighPenalty      = 0.18;
  static const double fatigueExhaustedPenalty = 0.35;
  static const double minEfficiencyAtZeroStamina = 0.40;

  // ─── STAMINA ──────────────────────────────────────────────────────────────
  static const double takedownStaminaPenalty = 18.0;
  static const Map<String, double> staminaCostPerTick = {
    'aggressive': 7.0,
    'defensive':  2.5,
    'technical':  4.5,
    'grappling':  6.0,
    'adaptive':   4.0,
  };

  // ─── MATCHUP POR ESTILO ───────────────────────────────────────────────────
  static const Map<String, Map<String, double>> styleMatchupModifiers = {
    'judo':      {'taekwondo': 1.15, 'bjj': 0.90, 'muay_thai': 0.95},
    'bjj':       {'muay_thai': 1.10, 'judo': 1.10, 'karate': 0.90},
    'karate':    {'bjj': 1.10, 'taekwondo': 1.05},
    'taekwondo': {'boxing': 1.00, 'judo': 0.85, 'muay_thai': 0.90},
    'muay_thai': {'bjj': 0.90, 'boxing': 1.10, 'karate': 1.05},
    'kung_fu':   {'karate': 1.05, 'boxing': 0.95},
    'boxing':    {'taekwondo': 1.00, 'muay_thai': 0.90, 'bjj': 1.05},
    'mma':       {},
  };
}

enum MovementState { circling, approaching, clinch, retreating }