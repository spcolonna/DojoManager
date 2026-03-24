import 'package:equatable/equatable.dart';

/// Representa un estilo de arte marcial con sus stats base.
class MartialStyle extends Equatable {
  final String id;
  final String titleKey;
  final String descKey;
  final String dojoImageAsset;
  final String iconAsset;
  final int colorHex;

  // Stats base (suman 100)
  final int baseStr; // Fuerza
  final int baseSpd; // Velocidad
  final int baseTec; // Técnica
  final int baseDef; // Defensa
  final int baseMen; // Mentalidad

  const MartialStyle({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.dojoImageAsset,
    required this.iconAsset,
    required this.colorHex,
    required this.baseStr,
    required this.baseSpd,
    required this.baseTec,
    required this.baseDef,
    required this.baseMen,
  }) : assert(baseStr + baseSpd + baseTec + baseDef + baseMen == 100,
              'Stats base deben sumar 100');

  @override
  List<Object?> get props => [id];

  static const List<MartialStyle> all = [
    MartialStyle(
      id: 'kung_fu',
      titleKey: 'style_kung_fu',
      descKey: 'style_kung_fu_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_kung_fu.png',
      iconAsset: 'assets/icons/styles/icon_style_kung_fu.png',
      colorHex: 0xFFD4AC0D,
      baseStr: 18, baseSpd: 20, baseTec: 22, baseDef: 18, baseMen: 22,
    ),
    MartialStyle(
      id: 'karate',
      titleKey: 'style_karate',
      descKey: 'style_karate_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_karate.png',
      iconAsset: 'assets/icons/styles/icon_style_karate.png',
      colorHex: 0xFFDDE1E7,
      baseStr: 22, baseSpd: 18, baseTec: 22, baseDef: 20, baseMen: 18,
    ),
    MartialStyle(
      id: 'taekwondo',
      titleKey: 'style_taekwondo',
      descKey: 'style_taekwondo_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_taekwondo.png',
      iconAsset: 'assets/icons/styles/icon_style_taekwondo.png',
      colorHex: 0xFF2471A3,
      baseStr: 16, baseSpd: 28, baseTec: 20, baseDef: 16, baseMen: 20,
    ),
    MartialStyle(
      id: 'judo',
      titleKey: 'style_judo',
      descKey: 'style_judo_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_judo.png',
      iconAsset: 'assets/icons/styles/icon_style_judo.png',
      colorHex: 0xFF1A5276,
      baseStr: 20, baseSpd: 14, baseTec: 18, baseDef: 28, baseMen: 20,
    ),
    MartialStyle(
      id: 'muay_thai',
      titleKey: 'style_muay_thai',
      descKey: 'style_muay_thai_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_muay_thai.png',
      iconAsset: 'assets/icons/styles/icon_style_muay_thai.png',
      colorHex: 0xFFC0392B,
      baseStr: 26, baseSpd: 20, baseTec: 18, baseDef: 22, baseMen: 14,
    ),
    MartialStyle(
      id: 'bjj',
      titleKey: 'style_bjj',
      descKey: 'style_bjj_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_bjj.png',
      iconAsset: 'assets/icons/styles/icon_style_bjj.png',
      colorHex: 0xFF1F618D,
      baseStr: 18, baseSpd: 14, baseTec: 22, baseDef: 24, baseMen: 22,
    ),
    MartialStyle(
      id: 'boxing',
      titleKey: 'style_boxing',
      descKey: 'style_boxing_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_boxing.png',
      iconAsset: 'assets/icons/styles/icon_style_boxing.png',
      colorHex: 0xFFCA6F1E,
      baseStr: 24, baseSpd: 22, baseTec: 18, baseDef: 20, baseMen: 16,
    ),
    MartialStyle(
      id: 'mma',
      titleKey: 'style_mma',
      descKey: 'style_mma_desc',
      dojoImageAsset: 'assets/images/dojos/dojo_mma.png',
      iconAsset: 'assets/icons/styles/icon_style_mma.png',
      colorHex: 0xFF566573,
      baseStr: 20, baseSpd: 20, baseTec: 20, baseDef: 20, baseMen: 20,
    ),
  ];

  static MartialStyle? fromId(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
