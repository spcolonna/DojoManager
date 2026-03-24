/// Motor de simulación de peleas.
/// Modifica estas constantes para rebalancear el combate sin tocar lógica.
class FightConfig {
  FightConfig._();

  // ─── ESTRUCTURA ────────────────────────────────────────────────────────────
  static const int roundsPerFight  = 3;
  static const int ticksPerRound   = 15;
  static const double rngMin       = 0.80;
  static const double rngMax       = 1.20;

  // ─── THRESHOLDS DE SCORING ────────────────────────────────────────────────
  static const double cleanHitThreshold    = 0.65; // +1 punto
  static const double dominantHitThreshold = 0.85; // +2 puntos
  static const double takedownThreshold    = 0.90; // +2 pts + stamina penalty (solo Grappling)
  static const double counterThreshold     = 0.35; // rival contraataca

  // ─── PESOS DE STATS POR ESTRATEGIA [STR, SPD, TEC] ───────────────────────
  static const Map<String, List<double>> strategyWeights = {
    'aggressive': [0.40, 0.35, 0.25],
    'defensive':  [0.20, 0.20, 0.60],
    'technical':  [0.25, 0.25, 0.50],
    'grappling':  [0.45, 0.20, 0.35],
    'adaptive':   [0.33, 0.33, 0.34], // se recalcula dinámicamente
  };

  // ─── COSTO DE STAMINA POR TICK (sobre 100) ────────────────────────────────
  static const Map<String, double> staminaCostPerTick = {
    'aggressive': 7.0,
    'defensive':  2.5,
    'technical':  4.5,
    'grappling':  6.0,
    'adaptive':   4.0,
  };

  // ─── PENALIZACIONES DE FATIGA ────────────────────────────────────────────
  static const double fatigueMediumThreshold = 0.50;
  static const double fatigueHighThreshold   = 0.80;
  static const double fatigueMediumPenalty   = 0.05;
  static const double fatigueHighPenalty     = 0.15;
  static const double fatigueExhaustedPenalty = 0.30;
  static const double minEfficiencyAtZeroStamina = 0.40;

  // ─── PENALIZACIÓN POR DERRIBO ─────────────────────────────────────────────
  static const double takedownStaminaPenalty = 15.0;

  // ─── MODIFICADORES DE MATCHUP POR ESTILO ─────────────────────────────────
  // key = [attacker][defender] → valor > 1.0 es ventaja para el atacante
  static const Map<String, Map<String, double>> styleMatchupModifiers = {
    'judo':       {'taekwondo': 1.15, 'bjj': 0.90, 'muay_thai': 0.95},
    'bjj':        {'muay_thai': 1.10, 'judo': 1.10, 'karate': 0.90},
    'karate':     {'bjj': 1.10, 'taekwondo': 1.05},
    'taekwondo':  {'boxing': 1.00, 'judo': 0.85, 'muay_thai': 0.90},
    'muay_thai':  {'bjj': 0.90, 'boxing': 1.10, 'karate': 1.05},
    'kung_fu':    {'karate': 1.05, 'boxing': 0.95},
    'boxing':     {'taekwondo': 1.00, 'muay_thai': 0.90, 'bjj': 1.05},
    'mma':        {}, // neutro
  };
}
