class TournamentConfig {
  TournamentConfig._();

  // ─── INSCRIPCIÓN ──────────────────────────────────────────────────────────
  static const int maxStudentsPerBeltPerTournament = 2;

  // ─── FORMATO DE ENCUENTRO ─────────────────────────────────────────────────
  static const int fightsPerMatch            = 3;
  static const int fightsNeededToWin         = 2;
  static const int fightsNeededToWinMatch    = 2;

  // ─── LIGA DE ESTILO (Liga Local) ──────────────────────────────────────────
  static const int leagueTeamsCount          = 20;  // era 8
  static const int leaguePromotionSpots      = 4;   // era 2 — top 4 clasifican
  static const int leagueRelegationSpots     = 4;
  static const int leagueMatchDay            = 6;   // sábado (0=lunes, 6=domingo)

  // ─── COPA INTER-ESTILOS ───────────────────────────────────────────────────
  static const int interStyleCupStartWeek    = 8;
  static const int interStyleCupMatchDay     = 3;   // jueves (rotamos con miércoles)
  static const int interStyleCupMatchDayAlt  = 2;   // miércoles (semanas alternas)
  static const int interStyleCupTeamsCount   = 32;  // 8 estilos × 4 clasificados
  static const int interStyleGroupSize       = 4;   // grupos de 4 equipos

  // ─── TEMPORADA ────────────────────────────────────────────────────────────
  static const int seasonWeeks               = 20;

  // ─── PUNTOS DE LIGA ───────────────────────────────────────────────────────
  static const int leaguePointsWin           = 3;
  static const int leaguePointsDraw          = 1;
  static const int leaguePointsLoss          = 0;

  // ─── MATCHUP ENTRE ESTILOS ────────────────────────────────────────────────
  static const Map<String, Map<String, double>> styleMatchupModifiers = {
    'kung_fu':    {'karate': 1.05, 'taekwondo': 1.10, 'boxing': 1.05},
    'karate':     {'taekwondo': 1.05, 'mma': 1.05},
    'taekwondo':  {'boxing': 1.10, 'bjj': 0.85},
    'judo':       {'taekwondo': 1.15, 'muay_thai': 0.90},
    'muay_thai':  {'bjj': 1.10, 'judo': 1.10},
    'bjj':        {'muay_thai': 0.90, 'judo': 1.15, 'boxing': 1.20},
    'boxing':     {'taekwondo': 0.90, 'kung_fu': 1.05},
    'mma':        {},
  };

  // ─── CALENDARIO SEMANAL ───────────────────────────────────────────────────
  /// Devuelve si una semana dada tiene Copa Inter-Estilos.
  static bool hasInterStyleCup(int week) =>
      week >= interStyleCupStartWeek;

  /// Día de la Copa según la semana (alterna miércoles/jueves).
  static int interStyleDayForWeek(int week) =>
      week % 2 == 0 ? interStyleCupMatchDay : interStyleCupMatchDayAlt;

  // ─── RECLUTAMIENTO ────────────────────────────────────────────────────────
  static const Map<int, int> maxRecruitBeltByDojoLevel = {
    1: 3, 2: 4, 3: 5, 4: 6, 5: 7, 6: 8, 7: 10,
  };
}