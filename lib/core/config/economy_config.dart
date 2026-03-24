/// Ingresos y costos en las dos monedas blandas del juego.
/// MD = Monedas de Dojo (soft currency)
/// GM = Gemas del Maestro (premium currency, se compra con dinero real)
/// PH = Puntos de Habilidad (moneda de árbol, NO se compra)
class EconomyConfig {
  EconomyConfig._();

  // ─── SALDO INICIAL ─────────────────────────────────────────────────────────
  static const int startingMD           = 0;
  static const int startingGM           = 0;
  static const int onboardingGiftMD     = 150; // regalo forzado en tutorial

  // ─── INGRESOS MD ──────────────────────────────────────────────────────────
  static const int mdPerTrainingWeek    = 25;
  static const int mdPerTournamentWin   = 50;
  static const int mdPerTournamentLoss  = 10;
  static const int mdDailyMissionMin    = 10;
  static const int mdDailyMissionMax    = 30;

  // ─── RECLUTAMIENTO POR NIVEL DE FAJA (MD) ────────────────────────────────
  static const Map<int, int> recruitmentCostByBeltLevel = {
    1:  50,
    2:  150,
    3:  300,
    4:  500,
    5:  800,
    6:  1200,
    7:  2000,
    8:  3500,
    9:  5000,
    10: 8000,
  };

  // ─── EXPANSIÓN DE ESCUELAS ─────────────────────────────────────────────────
  static const int secondDojoMD       = 500;
  static const int secondDojoGM       = 150;
  static const int thirdDojoMD        = 1200;
  static const int thirdDojoGM        = 300;
  static const int fourthFifthDojoGM  = 500;  // solo GM
  static const int sixthPlusDojoGM    = 800;  // solo GM + Pase activo

  // ─── SCOUTS ───────────────────────────────────────────────────────────────
  static const int basicScoutCostMD   = 100;
  static const int premiumScoutCostGM = 3;

  // ─── PLAN DE ENTRENAMIENTO INTENSIVO PLUS ─────────────────────────────────
  static const int intensivePlusCostMD = 50;

  // ─── SESIÓN MAESTRA ────────────────────────────────────────────────────────
  static const int masterSessionCostGM = 5;

  // ─── ACELERACIÓN DE CONSTRUCCIÓN ──────────────────────────────────────────
  /// GM para saltar el tiempo de construcción de una mejora de dojo.
  static const int skipConstructionCostGM = 2;

  // ─── ÁRBOL DE HABILIDADES ─────────────────────────────────────────────────
  /// GM para saltear el requisito de faja en nodos Elite.
  static const int skipEliteRequirementCostGM = 3;

  // ─── PASE DE MAESTRO — beneficios en MD/GM ────────────────────────────────
  static const double passMonthlyMDBonusMultiplier = 1.30; // +30% MD en torneos
  static const int    passWeeklyGMBonus            = 10;   // solo Pase Anual
  static const int    passScoutsPerWeek            = 1;    // scout premium gratis/semana
}
