import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/xp_config.dart';

/// Representa el nivel y color de faja de un estudiante.
class Belt {
  final int level; // 1–10, luego Dan 1, Dan 2...
  final int danLevel; // 0 = no es Dan, >0 = grado de cinta negra

  const Belt({required this.level, this.danLevel = 0});

  bool get isBlackBelt => level == 10;
  bool get isDan => danLevel > 0;

  String get titleKey {
    if (isDan) return 'belt_black_dan_$danLevel';
    const keys = [
      '', // placeholder índice 0
      'belt_white',
      'belt_yellow',
      'belt_orange',
      'belt_green',
      'belt_blue',
      'belt_purple',
      'belt_brown',
      'belt_red',
      'belt_red_black',
      'belt_black',
    ];
    return keys[level.clamp(1, 10)];
  }

  Color get color => AppColors.beltColorByLevel[level.clamp(1, 10)] ?? AppColors.beltWhite;

  String get assetPath {
    if (level == 9) return 'assets/images/belts/belt_red_black.png';
    const paths = {
      1: 'assets/images/belts/belt_white.png',
      2: 'assets/images/belts/belt_yellow.png',
      3: 'assets/images/belts/belt_orange.png',
      4: 'assets/images/belts/belt_green.png',
      5: 'assets/images/belts/belt_blue.png',
      6: 'assets/images/belts/belt_purple.png',
      7: 'assets/images/belts/belt_brown.png',
      8: 'assets/images/belts/belt_red.png',
      10: 'assets/images/belts/belt_black.png',
    };
    return paths[level] ?? 'assets/images/belts/belt_white.png';
  }

  int get xpRequiredForNextLevel {
    if (level < 10) return XPConfig.xpRequiredPerLevel[level - 1];
    if (isDan) return XPConfig.xpRequiredForDan(danLevel + 1);
    return XPConfig.xpBaseForFirstDan;
  }

  Belt get next {
    if (level < 10) return Belt(level: level + 1);
    return Belt(level: 10, danLevel: danLevel + 1);
  }
}
