import 'package:flutter/material.dart';

/// Paleta de colores de Grand Dojo — Tema Oscuro Combate.
/// Para cambiar el tema visual de toda la app, solo tocar este archivo.
/// NUNCA hardcodear Color(0xFF...) en ningún widget.
class AppColors {
  AppColors._();

  // ─── FONDOS ───────────────────────────────────────────────────────────────
  static const Color bgDeep     = Color(0xFF1A1A1A); 
  static const Color bgSurface  = Color(0xFF242424); 
  static const Color bgElevated = Color(0xFF2C2C2C); 
  static const Color bgInput    = Color(0xFF383838);
  static const Color bgDivider  = Color(0xFF444444);

  // ─── PRIMARIO — ROJO COMBATE ──────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF3B3B);
  static const Color primaryLight = Color(0xFFFF6B6B);
  static const Color primaryDark  = Color(0xFFB71C1C);
  static const Color primaryBg    = Color(0xFF2A0A0A);
  static const Color primaryBgDeep= Color(0xFF1A0505);

  // ─── SECUNDARIO — NARANJA ENERGÍA ─────────────────────────────────────────
  static const Color secondary      = Color(0xFFFF8C42);
  static const Color secondaryLight = Color(0xFFFFB074);

  // ─── ACENTO — ORO LOOT ────────────────────────────────────────────────────
  static const Color accent      = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE14D);
  static const Color accentDark  = Color(0xFFC9A200);
  static const Color accentBg    = Color(0xFF2A2400);
  static const Color accentBgDeep= Color(0xFF1A1600);

  /// Alias "gold" → apunta al acento dorado para no romper referencias
  static const Color goldPrimary = accent;
  static const Color goldLight   = accentLight;
  static const Color goldDark    = accentDark;
  static const Color goldMuted   = accentBg;
  static const Color goldBg      = accentBg;
  static const Color goldBgDeep  = accentBgDeep;
  static const Color textGold    = accent;

  /// Alias "red" → apunta al primario rojo
  static const Color redAction = primary;
  static const Color redLight  = primaryLight;
  static const Color redDark   = primaryDark;
  static const Color redBg     = primaryBg;
  static const Color redBgDeep = primaryBgDeep;

  // ─── AZUL / INFO ──────────────────────────────────────────────────────────
  static const Color info      = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFF42A5F5);
  static const Color infoBg    = Color(0xFF0A1A2A);

  // ─── MORADO / MERCADO ─────────────────────────────────────────────────────
  static const Color purple      = Color(0xFFAB47BC);
  static const Color purpleLight = Color(0xFFCE7DD6);
  static const Color purpleBg    = Color(0xFF1A0A1E);
  static const Color purpleBgDeep= Color(0xFF110614);

  // ─── VERDE / ÉXITO ────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF80C783);
  static const Color successBg    = Color(0xFF102A12);
  static const Color successBgDeep= Color(0xFF0A1A0C);
  static const Color successBorder= Color(0xFF2E7D32);

  // ─── NARANJA / ENTRENAMIENTO ──────────────────────────────────────────────
  static const Color orange      = secondary;
  static const Color orangeLight = secondaryLight;

  // ─── ESTADOS ──────────────────────────────────────────────────────────────
  static const Color warning  = Color(0xFFFFA726);
  static const Color disabled = Color(0xFF555555);

  // ─── TEXTO ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFBBBBBB);
  static const Color textTertiary  = Color(0xFF777777);
  static const Color textDisabled  = Color(0xFF555555);

  // ─── FAJAS ────────────────────────────────────────────────────────────────
  static const Color beltWhite  = Color(0xFFE0E0E0);
  static const Color beltYellow = Color(0xFFFFD700);
  static const Color beltOrange = secondary;
  static const Color beltGreen  = Color(0xFF4CAF50);
  static const Color beltBlue   = Color(0xFF42A5F5);
  static const Color beltPurple = Color(0xFFAB47BC);
  static const Color beltBrown  = Color(0xFF6D4C41);
  static const Color beltRed    = primary;
  static const Color beltBlack  = Color(0xFF000000);

  static const Map<int, Color> beltColorByLevel = {
    1: beltWhite,  2: beltYellow, 3: beltOrange,
    4: beltGreen,  5: beltBlue,   6: beltPurple,
    7: beltBrown,  8: beltRed,    9: beltRed,
    10: beltBlack,
  };

  // ─── ESTILOS MARCIALES ────────────────────────────────────────────────────
  static const Color styleKungFu    = accent;
  static const Color styleKarate    = Color(0xFFE0E0E0);
  static const Color styleTaekwondo = Color(0xFF42A5F5);
  static const Color styleJudo      = Color(0xFF90A4AE);
  static const Color styleMuayThai  = primary;
  static const Color styleBjj       = Color(0xFF1E88E5);
  static const Color styleBoxing    = secondary;
  static const Color styleMma       = Color(0xFF9E9E9E);

  static const Map<String, Color> colorByStyle = {
    'kung_fu':    styleKungFu,
    'karate':     styleKarate,
    'taekwondo':  styleTaekwondo,
    'judo':       styleJudo,
    'muay_thai':  styleMuayThai,
    'bjj':        styleBjj,
    'boxing':     styleBoxing,
    'mma':        styleMma,
  };

  // ─── RAMAS DEL ÁRBOL ──────────────────────────────────────────────────────
  static const Color branchPower     = primary;
  static const Color branchAgility   = infoLight;
  static const Color branchTechnique = accent;
  static const Color branchGuard     = success;
  static const Color branchMind      = purple;

  // ─── GRADIENTES ───────────────────────────────────────────────────────────
  static const LinearGradient gradientDojo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBg, primaryBgDeep, bgDeep],
  );

  static const LinearGradient gradientTournament = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A0A0A), bgDeep],
  );

  static const LinearGradient gradientMarket = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleBg, purpleBgDeep],
  );

  static const LinearGradient gradientUpgrades = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [successBg, successBgDeep],
  );

  static const LinearGradient gradientHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgElevated, bgDeep],
  );

  // ─── OVERLAYS ─────────────────────────────────────────────────────────────
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayGold = Color(0x33FFD700);
}