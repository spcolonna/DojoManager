/// Toda la configuración relacionada con XP y progresión de nivel.
/// Para ajustar la curva de dificultad, editar solo este archivo.
/// No tocar lógica de negocio en use_cases para rebalancear el juego.
class XPConfig {
  XPConfig._();

  // ─── XP GANADO POR ACTIVIDAD ───────────────────────────────────────────────
  static const int xpPerTrainingDayCompleted  = 20;
  static const int xpPerDailyMission          = 25;
  static const int xpPerSparringSession       = 60;
  static const int xpPerTournamentWin         = 80;
  static const int xpPerTournamentLoss        = 20;
  static const int xpPerCrossStyleWin         = 120;
  static const int xpPerCrossStyleLoss        = 30;
  static const int xpWinStreakBonus           = 50;  // 3 victorias seguidas
  static const int xpPassMonthlyTournamentWin = 100; // torneo exclusivo del pase

  // ─── XP REQUERIDO POR NIVEL ────────────────────────────────────────────────
  // Índice 0 = nivel 1→2 (Blanca→Amarilla), índice 8 = nivel 9→10 (Roja-Negra→Negra)
  static const List<int> xpRequiredPerLevel = [
    50,    // 1  → 2  (Blanca → Amarilla)
    100,   // 2  → 3  (Amarilla → Naranja)
    200,   // 3  → 4  (Naranja → Verde)
    350,   // 4  → 5  (Verde → Azul)
    550,   // 5  → 6  (Azul → Morada)
    800,   // 6  → 7  (Morada → Marrón)
    1200,  // 7  → 8  (Marrón → Roja)
    1800,  // 8  → 9  (Roja → Roja-Negra)
    2500,  // 9  → 10 (Roja-Negra → Negra)
  ];

  /// XP total acumulado necesario para llegar a Faja Negra desde cero.
  static int get totalXPToBlackBelt =>
      xpRequiredPerLevel.reduce((a, b) => a + b); // 7,550 XP

  // ─── DAN (POST FAJA NEGRA) ─────────────────────────────────────────────────
  static const int    xpBaseForFirstDan  = 5000;
  static const double danXPMultiplier    = 2.0; // cada Dan cuesta el doble

  static int xpRequiredForDan(int danNumber) {
    if (danNumber < 1) return 0;
    return (xpBaseForFirstDan * _pow(danXPMultiplier, danNumber - 1)).toInt();
  }

  static double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) result *= base;
    return result;
  }

  // ─── BONIFICACIONES DE INSTALACIONES (DojoUpgrade) ────────────────────────
  /// +5% XP cuando martial_library está desbloqueada.
  static const double martialLibraryXPBonus = 0.05;

  // ─── BONIFICACIONES DEL PASE ──────────────────────────────────────────────
  /// Extra XP por semana cuando el jugador tiene el Pase de Maestro activo.
  static const int passWeeklyXPBonus = 150;
}
