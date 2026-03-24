import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── FONDOS ───────────────────────────────────────────────────────────────
  static const Color bgDeep     = Color(0xFF0A0C12);
  static const Color bgSurface  = Color(0xFF141824);
  static const Color bgElevated = Color(0xFF1C2235);
  static const Color bgInput    = Color(0xFF242B40);
  static const Color bgDivider  = Color(0xFF2A3048);

  // ─── ORO / HONOR ──────────────────────────────────────────────────────────
  static const Color goldPrimary = Color(0xFFC9A84C);
  static const Color goldLight   = Color(0xFFE8C97A);
  static const Color goldDark    = Color(0xFF8A6D2F);
  static const Color goldMuted   = Color(0xFF4A3B1A);
  static const Color goldBg      = Color(0xFF2C1F08);
  static const Color goldBgDeep  = Color(0xFF1A1508);

  // ─── ROJO / COMBATE ───────────────────────────────────────────────────────
  static const Color redAction  = Color(0xFFC0392B);
  static const Color redLight   = Color(0xFFE74C3C);
  static const Color redDark    = Color(0xFF7B241C);
  static const Color redBg      = Color(0xFF2C0A0A);
  static const Color redBgDeep  = Color(0xFF150505);

  // ─── VERDE / ÉXITO ────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF58D68D);
  static const Color successBg    = Color(0xFF1A3A2A);
  static const Color successBgDeep= Color(0xFF0D1A12);
  static const Color successBorder= Color(0xFF1E8449);

  // ─── AZUL / INFO ──────────────────────────────────────────────────────────
  static const Color info     = Color(0xFF2980B9);
  static const Color infoLight= Color(0xFF5DADE2);
  static const Color infoBg   = Color(0xFF0D1F2D);

  // ─── MORADO / MERCADO ─────────────────────────────────────────────────────
  static const Color purple      = Color(0xFF7D3C98);
  static const Color purpleLight = Color(0xFFBB8FCE);
  static const Color purpleBg    = Color(0xFF4A235A);
  static const Color purpleBgDeep= Color(0xFF1C0D22);

  // ─── NARANJA / ENTRENAMIENTO ──────────────────────────────────────────────
  static const Color orange     = Color(0xFFE87020);
  static const Color orangeLight= Color(0xFFF0A060);

  // ─── ESTADOS ──────────────────────────────────────────────────────────────
  static const Color warning  = Color(0xFFF39C12);
  static const Color disabled = Color(0xFF3A3F52);

  // ─── TEXTO ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF9099B0);
  static const Color textTertiary  = Color(0xFF5C6480);
  static const Color textDisabled  = Color(0xFF4A5068);
  static const Color textGold      = Color(0xFFE8C97A);

  // ─── FAJAS ────────────────────────────────────────────────────────────────
  static const Color beltWhite    = Color(0xFFF5F5F5);
  static const Color beltYellow   = Color(0xFFEDCC3A);
  static const Color beltOrange   = Color(0xFFE87020);
  static const Color beltGreen    = Color(0xFF27AE60);
  static const Color beltBlue     = Color(0xFF2980B9);
  static const Color beltPurple   = Color(0xFF8E44AD);
  static const Color beltBrown    = Color(0xFF7B4019);
  static const Color beltRed      = Color(0xFFC0392B);
  static const Color beltBlack    = Color(0xFF111111);

  static const Map<int, Color> beltColorByLevel = {
    1: beltWhite,  2: beltYellow, 3: beltOrange,
    4: beltGreen,  5: beltBlue,   6: beltPurple,
    7: beltBrown,  8: beltRed,    9: beltRed,
    10: beltBlack,
  };

  // ─── ESTILOS MARCIALES ────────────────────────────────────────────────────
  static const Color styleKungFu    = Color(0xFFD4AC0D);
  static const Color styleKarate    = Color(0xFFDDE1E7);
  static const Color styleTaekwondo = Color(0xFF2471A3);
  static const Color styleJudo      = Color(0xFF1A5276);
  static const Color styleMuayThai  = Color(0xFFC0392B);
  static const Color styleBjj       = Color(0xFF1F618D);
  static const Color styleBoxing    = Color(0xFFCA6F1E);
  static const Color styleMma       = Color(0xFF566573);

  static const Map<String, Color> colorByStyle = {
    'kung_fu':    styleKungFu,   'karate':    styleKarate,
    'taekwondo':  styleTaekwondo,'judo':      styleJudo,
    'muay_thai':  styleMuayThai, 'bjj':       styleBjj,
    'boxing':     styleBoxing,   'mma':       styleMma,
  };

  // ─── RAMAS DEL ÁRBOL ──────────────────────────────────────────────────────
  static const Color branchPower     = redAction;
  static const Color branchAgility   = info;
  static const Color branchTechnique = goldPrimary;
  static const Color branchGuard     = success;
  static const Color branchMind      = purple;

  // ─── GRADIENTES PREDEFINIDOS ──────────────────────────────────────────────
  static const LinearGradient gradientDojo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldBg, goldBgDeep, bgDeep],
  );

  static const LinearGradient gradientTournament = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [redBg, redBgDeep],
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
    colors: [bgElevated, bgSurface],
  );

  // ─── OVERLAYS ─────────────────────────────────────────────────────────────
  static const Color overlayDark = Color(0xCC000000);
  static const Color overlayGold = Color(0x33C9A84C);
}