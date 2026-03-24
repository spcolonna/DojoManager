import 'package:flutter/material.dart';

/// Paleta de colores completa de Grand Dojo.
/// Uso: AppColors.goldPrimary, AppColors.bgDeep, etc.
/// Nunca hardcodear colores en widgets — siempre referenciar desde aquí.
class AppColors {
  AppColors._();

  // ─── FONDOS ────────────────────────────────────────────────────────────────
  /// Fondo principal de la app. Casi negro con tinte azul-pizarra.
  static const Color bgDeep     = Color(0xFF0A0C12);
  /// Superficie de cards y panels.
  static const Color bgSurface  = Color(0xFF141824);
  /// Cards elevadas, modales, bottom sheets.
  static const Color bgElevated = Color(0xFF1C2235);
  /// Campos de texto, sliders, inputs.
  static const Color bgInput    = Color(0xFF242B40);
  /// Separadores y bordes sutiles.
  static const Color bgDivider  = Color(0xFF2A3048);

  // ─── ACENTO PRIMARIO: ORO / HONOR ──────────────────────────────────────────
  /// Oro principal. CTAs, highlights, títulos importantes.
  static const Color goldPrimary = Color(0xFFC9A84C);
  /// Oro claro. Texto de valor, íconos activos.
  static const Color goldLight   = Color(0xFFE8C97A);
  /// Oro oscuro. Bordes sutiles, sombras de oro.
  static const Color goldDark    = Color(0xFF8A6D2F);
  /// Oro muy apagado. Fondos de oro, watermarks.
  static const Color goldMuted   = Color(0xFF4A3B1A);

  // ─── ACENTO SECUNDARIO: ROJO / COMBATE ────────────────────────────────────
  /// Rojo de acción. Botones de combate, daño, alertas críticas.
  static const Color redAction  = Color(0xFFC0392B);
  /// Rojo claro. Highlights de combate.
  static const Color redLight   = Color(0xFFE74C3C);
  /// Rojo oscuro. Bordes de peligro.
  static const Color redDark    = Color(0xFF7B241C);

  // ─── ESTADOS FUNCIONALES ───────────────────────────────────────────────────
  /// Verde éxito. XP ganado, nivel subido, victoria.
  static const Color success    = Color(0xFF27AE60);
  /// Verde claro. Highlight de éxito.
  static const Color successLight = Color(0xFF2ECC71);
  /// Naranja advertencia. Fatiga alta, tiempo bajo.
  static const Color warning    = Color(0xFFF39C12);
  /// Azul info. Mensajes neutrales, tooltips.
  static const Color info       = Color(0xFF2E86C1);
  /// Gris deshabilitado. Elementos inactivos, bloqueados.
  static const Color disabled   = Color(0xFF3A3F52);

  // ─── TEXTO ─────────────────────────────────────────────────────────────────
  /// Texto principal. Alto contraste.
  static const Color textPrimary   = Color(0xFFF0F0F0);
  /// Texto secundario. Labels, subtítulos.
  static const Color textSecondary = Color(0xFF9099B0);
  /// Texto terciario. Descripciones largas, hints.
  static const Color textTertiary  = Color(0xFF5C6480);
  /// Texto deshabilitado.
  static const Color textDisabled  = Color(0xFF4A5068);
  /// Texto en oro. Valores de moneda, nombres de importancia.
  static const Color textGold      = Color(0xFFC9A84C);

  // ─── COLORES DE FAJA ───────────────────────────────────────────────────────
  static const Color beltWhite    = Color(0xFFF5F5F5);
  static const Color beltYellow   = Color(0xFFEDCC3A);
  static const Color beltOrange   = Color(0xFFE87020);
  static const Color beltGreen    = Color(0xFF27AE60);
  static const Color beltBlue     = Color(0xFF2980B9);
  static const Color beltPurple   = Color(0xFF8E44AD);
  static const Color beltBrown    = Color(0xFF7B4019);
  static const Color beltRed      = Color(0xFFC0392B);
  // Red-Black: usar un LinearGradient con beltRed y beltBlack
  static const Color beltBlack    = Color(0xFF111111); // con borde goldPrimary en UI

  // ─── COLORES POR ESTILO MARCIAL ────────────────────────────────────────────
  static const Color styleKungFu    = Color(0xFFD4AC0D); // dorado imperial
  static const Color styleKarate    = Color(0xFFDDE1E7); // blanco pureza
  static const Color styleTaekwondo = Color(0xFF2471A3); // azul coreano
  static const Color styleJudo      = Color(0xFF1A5276); // azul marino
  static const Color styleMuayThai  = Color(0xFFC0392B); // rojo tailandés
  static const Color styleBjj       = Color(0xFF1F618D); // azul BJJ
  static const Color styleBoxing    = Color(0xFFCA6F1E); // cuero/naranja
  static const Color styleMma       = Color(0xFF566573); // gris acero

  // ─── COLORES DE RAMA DEL ÁRBOL ─────────────────────────────────────────────
  static const Color branchPower     = Color(0xFFC0392B); // rojo
  static const Color branchAgility   = Color(0xFF2980B9); // azul
  static const Color branchTechnique = Color(0xFFC9A84C); // dorado
  static const Color branchGuard     = Color(0xFF27AE60); // verde
  static const Color branchMind      = Color(0xFF8E44AD); // morado

  // ─── OVERLAYS Y GRADIENTES ────────────────────────────────────────────────
  /// Overlay oscuro semi-transparente para modales y dialogs.
  static const Color overlayDark    = Color(0xCC000000);
  /// Overlay dorado para highlights de selección.
  static const Color overlayGold    = Color(0x33C9A84C);

  // ─── HELPER: mapa de colores de faja por nivel ────────────────────────────
  static const Map<int, Color> beltColorByLevel = {
    1: beltWhite,
    2: beltYellow,
    3: beltOrange,
    4: beltGreen,
    5: beltBlue,
    6: beltPurple,
    7: beltBrown,
    8: beltRed,
    9: beltRed,   // rojo-negro (gradient en UI)
    10: beltBlack,
  };

  // ─── HELPER: color representativo por estilo ──────────────────────────────
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
}
