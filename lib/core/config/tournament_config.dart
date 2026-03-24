/// Reglas y estructura de torneos, ligas y copa inter-estilos.
class TournamentConfig {
  TournamentConfig._();

  // ─── INSCRIPCIÓN ──────────────────────────────────────────────────────────
  static const int maxStudentsPerBeltPerTournament = 2;

  // ─── FORMATO DE ENCUENTRO ─────────────────────────────────────────────────
  static const int fightsPerMatch         = 3;  // best of 3
  static const int fightsNeededToWin      = 2;  // 2 de 3

  // ─── TEMPORADA ────────────────────────────────────────────────────────────
  static const int seasonWeeks            = 20;
  static const int leagueTeamsCount       = 8;
  static const int promotionSpots         = 2;  // ascienden
  static const int relegationSpots        = 2;  // descienden

  // ─── PUNTOS DE LIGA ───────────────────────────────────────────────────────
  static const int leaguePointsWin        = 3;
  static const int leaguePointsDraw       = 1;
  static const int leaguePointsLoss       = 0;

  // ─── COPA INTER-ESTILOS ───────────────────────────────────────────────────
  static const int interStyleCupStartWeek = 8;

  // ─── CAPACIDAD DE DOJO POR NIVEL PARA RECLUTAR ───────────────────────────
  // DojoLevel → máxima faja de candidatos disponibles sin bonus
  static const Map<int, int> maxRecruitBeltByDojoLevel = {
    1: 3,   // hasta naranja
    2: 4,   // hasta verde
    3: 5,   // hasta azul
    4: 6,   // hasta morada
    5: 7,   // hasta marrón
    6: 8,   // hasta roja
    7: 10,  // negra y Dan
  };
}
