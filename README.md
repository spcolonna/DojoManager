# Grand Dojo

Martial Arts Manager — Free-to-Play Mobile Game
Flutter · Firebase · Riverpod · RevenueCat

## Arquitectura

lib/
  core/config/     <- Toda la configuración del juego
  core/constants/  <- Colores, tipografías, tema
  core/l10n/       <- Archivos ARB (EN + ES)
  domain/          <- Lógica de negocio pura
  infrastructure/  <- Firebase, RevenueCat, simulación
  delivery/        <- Pantallas y widgets Flutter

## Configuración del juego

xp_config.dart       - Curva de XP y niveles
economy_config.dart  - Ingresos y costos MD/GM
shop_config.dart     - Tienda, precios reales, store IDs
skill_tree_config.dart - Árbol de habilidades
dojo_upgrade_config.dart - Mejoras del dojo
fight_config.dart    - Motor de simulación de peleas
training_config.dart - Planes de entrenamiento
tournament_config.dart - Reglas de torneo

## Setup

flutter pub get
flutter gen-l10n
flutter run

Ver ASSETS_AND_BALANCE.md para lista de assets y análisis F2P.
