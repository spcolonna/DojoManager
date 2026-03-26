import 'package:flutter/material.dart';

/// Todas las duraciones, curvas y constantes de animación de la app.
/// Referenciar desde aquí en lugar de hardcodear en widgets.
class AppAnimations {
  AppAnimations._();

  // ─── DURACIONES ───────────────────────────────────────────────────────────
  static const Duration instant      = Duration(milliseconds: 100);
  static const Duration fast         = Duration(milliseconds: 200);
  static const Duration normal       = Duration(milliseconds: 350);
  static const Duration slow         = Duration(milliseconds: 600);
  static const Duration verySlow     = Duration(milliseconds: 1000);

  // Específicas por contexto
  static const Duration skillUnlock  = Duration(milliseconds: 800);
  static const Duration statBarFill  = Duration(milliseconds: 600);
  static const Duration floatFade    = Duration(milliseconds: 1200);
  static const Duration weekReveal   = Duration(milliseconds: 400);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // ─── CURVAS ───────────────────────────────────────────────────────────────
  static const Curve defaultCurve    = Curves.easeInOut;
  static const Curve popIn           = Curves.elasticOut;
  static const Curve slideIn         = Curves.easeOutCubic;
  static const Curve fadeIn          = Curves.easeIn;
  static const Curve bounceIn        = Curves.bounceOut;
  static const Curve sharpOut        = Curves.easeOutExpo;

  // ─── STAGGER DELAY por ítem en lista ─────────────────────────────────────
  static Duration stagger(int index, {int msPerItem = 80}) =>
      Duration(milliseconds: index * msPerItem);
}