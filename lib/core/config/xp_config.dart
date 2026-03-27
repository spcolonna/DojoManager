/// Toda la configuración relacionada con XP y progresión de nivel.
/// Para ajustar la curva de dificultad, editar solo este archivo.
/// No tocar lógica de negocio en use_cases para rebalancear el juego.
class XPConfig {
  XPConfig._();

  // ─── XP GANADO POR ACTIVIDAD ───────────────────────────────────────────────
  static const int xpPerTrainingDayCompleted  = 10;  
  static const int xpPerDailyMission          = 20;  
  static const int xpPerSparringSession       = 30;  
  static const int xpPerTournamentWin         = 120; 
  static const int xpPerTournamentLoss        = 40;  
  static const int xpPerCrossStyleWin         = 180; 
  static const int xpPerCrossStyleLoss        = 60;  
  static const int xpWinStreakBonus           = 80;  
  static const int xpPassMonthlyTournamentWin = 150; 

  // ─── XP REQUERIDO POR NIVEL ────────────────────────────────────────────────
  // El aumento es exponencial — los primeros niveles son accesibles,
  // los últimos requieren dedicación real.
  static const List<int> xpRequiredPerLevel = [
    300,    // 1  → 2  (Blanca → Amarilla)    ~2 semanas free
    650,    // 2  → 3  (Amarilla → Naranja)   ~3 semanas free
    1200,  // 3  → 4  (Naranja → Verde)      ~5 semanas free
    3200,  // 4  → 5  (Verde → Azul)         ~8 semanas free
    5000,  // 5  → 6  (Azul → Morada)        ~12 semanas free
    7500,  // 6  → 7  (Morada → Marrón)      ~18 semanas free
    10000, // 7  → 8  (Marrón → Roja)        ~26 semanas free
    13000, // 8  → 9  (Roja → Roja-Negra)    ~36 semanas free
    20000, // 9  → 10 (Roja-Negra → Negra)   ~48 semanas free
  ];

  /// XP total acumulado necesario para llegar a Faja Negra desde cero.
  static int get totalXPToBlackBelt =>
      xpRequiredPerLevel.reduce((a, b) => a + b);

  // ─── DAN (POST FAJA NEGRA) ─────────────────────────────────────────────────
  static const int    xpBaseForFirstDan  = 30000;
  static const double danXPMultiplier    = 2.0;

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
  static const double martialLibraryXPBonus = 0.05;

  // ─── BONIFICACIONES DEL PASE ──────────────────────────────────────────────
  static const int    passWeeklyXPBonus     = 200;
}
