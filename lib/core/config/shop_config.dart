/// Configuración completa de la tienda (Shop).
/// Paquetes de GM, Pases de Maestro, paquetes especiales y ofertas de MD.
/// Los storeId deben coincidir exactamente con los configurados en
/// App Store Connect y Google Play Console.
/// Para cambiar precios o agregar productos: solo tocar este archivo.
class ShopConfig {
  ShopConfig._();

  // ──────────────────────────────────────────────────────────────────────────
  // PAQUETES DE GEMAS DEL MAESTRO (GM)
  // ──────────────────────────────────────────────────────────────────────────

  static const List<GemPackage> gemPackages = [
    GemPackage(
      id: 'gems_starter',
      storeIdIos: 'grand_dojo_gems_80',
      storeIdAndroid: 'grand_dojo_gems_80',
      gems: 80,
      priceUSD: 0.99,
      labelKey: 'shop_gems_starter_label',
      descKey: 'shop_gems_starter_desc',
      isBestValue: false,
      bonusPercent: 0,
    ),
    GemPackage(
      id: 'gems_advanced',
      storeIdIos: 'grand_dojo_gems_500',
      storeIdAndroid: 'grand_dojo_gems_500',
      gems: 500,
      priceUSD: 4.99,
      labelKey: 'shop_gems_advanced_label',
      descKey: 'shop_gems_advanced_desc',
      isBestValue: false,
      bonusPercent: 0,
    ),
    GemPackage(
      id: 'gems_grand_master',
      storeIdIos: 'grand_dojo_gems_1200',
      storeIdAndroid: 'grand_dojo_gems_1200',
      gems: 1200,
      priceUSD: 9.99,
      labelKey: 'shop_gems_grand_master_label',
      descKey: 'shop_gems_grand_master_desc',
      isBestValue: true,   // destacado en la UI
      bonusPercent: 20,    // +20% bonus respecto al ratio base
    ),
    GemPackage(
      id: 'gems_legendary',
      storeIdIos: 'grand_dojo_gems_3500',
      storeIdAndroid: 'grand_dojo_gems_3500',
      gems: 3500,
      priceUSD: 19.99,
      labelKey: 'shop_gems_legendary_label',
      descKey: 'shop_gems_legendary_desc',
      isBestValue: false,
      bonusPercent: 35,    // +35% bonus
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // PASES DE MAESTRO (SUSCRIPCIONES)
  // ──────────────────────────────────────────────────────────────────────────

  static const MasterPass monthlyPass = MasterPass(
    id: 'pass_monthly',
    storeIdIos: 'grand_dojo_pass_monthly',
    storeIdAndroid: 'grand_dojo_pass_monthly',
    priceUSD: 4.99,
    isAnnual: false,
    labelKey: 'shop_pass_monthly_label',
    descKey: 'shop_pass_monthly_desc',
    benefitsKeys: [
      'shop_pass_benefit_md_bonus',          // +30% MD en torneos
      'shop_pass_benefit_extra_student_slot', // slot extra de estudiante
      'shop_pass_benefit_weekly_scout',       // 1 scout premium/semana
      'shop_pass_benefit_special_tournament', // 1 torneo especial/semana
      'shop_pass_benefit_school_icon',        // ícono premium de escuela
    ],
  );

  static const MasterPass annualPass = MasterPass(
    id: 'pass_annual',
    storeIdIos: 'grand_dojo_pass_annual',
    storeIdAndroid: 'grand_dojo_pass_annual',
    priceUSD: 34.99,
    isAnnual: true,
    labelKey: 'shop_pass_annual_label',
    descKey: 'shop_pass_annual_desc',
    savingsLabelKey: 'shop_pass_annual_savings', // "Ahorrás 25%"
    benefitsKeys: [
      'shop_pass_benefit_md_bonus',
      'shop_pass_benefit_extra_student_slot',
      'shop_pass_benefit_weekly_scout',
      'shop_pass_benefit_special_tournament',
      'shop_pass_benefit_school_icon',
      'shop_pass_benefit_weekly_gems',        // +10 GM por semana (solo anual)
      'shop_pass_benefit_exclusive_training', // planes exclusivos de entrenamiento
      'shop_pass_benefit_invitation_tournament', // Torneos de Invitación fin de temporada
    ],
  );

  // ──────────────────────────────────────────────────────────────────────────
  // PAQUETES DE MD (MONEDAS DE DOJO)
  // Para jugadores que quieren saltear el grindeo de moneda blanda
  // ──────────────────────────────────────────────────────────────────────────

  static const List<MDPackage> mdPackages = [
    MDPackage(
      id: 'md_small',
      storeIdIos: 'grand_dojo_md_1000',
      storeIdAndroid: 'grand_dojo_md_1000',
      amount: 1000,
      priceUSD: 0.99,
      labelKey: 'shop_md_small_label',
    ),
    MDPackage(
      id: 'md_medium',
      storeIdIos: 'grand_dojo_md_5500',
      storeIdAndroid: 'grand_dojo_md_5500',
      amount: 5500,
      priceUSD: 4.99,
      labelKey: 'shop_md_medium_label',
      bonusPercent: 10,
    ),
    MDPackage(
      id: 'md_large',
      storeIdIos: 'grand_dojo_md_12000',
      storeIdAndroid: 'grand_dojo_md_12000',
      amount: 12000,
      priceUSD: 9.99,
      labelKey: 'shop_md_large_label',
      bonusPercent: 20,
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // PAQUETES ESPECIALES (tiempo limitado o bundles)
  // Activar/desactivar desde aquí sin cambiar lógica de UI
  // ──────────────────────────────────────────────────────────────────────────

  static const List<SpecialBundle> specialBundles = [
    SpecialBundle(
      id: 'bundle_starter',
      storeIdIos: 'grand_dojo_bundle_starter',
      storeIdAndroid: 'grand_dojo_bundle_starter',
      priceUSD: 2.99,
      gemsIncluded: 200,
      mdIncluded: 500,
      labelKey: 'shop_bundle_starter_label',
      descKey: 'shop_bundle_starter_desc',
      isTimeLimited: false,
      isActive: true,
    ),
    SpecialBundle(
      id: 'bundle_new_school',
      storeIdIos: 'grand_dojo_bundle_new_school',
      storeIdAndroid: 'grand_dojo_bundle_new_school',
      priceUSD: 4.99,
      gemsIncluded: 300,
      mdIncluded: 1200,
      unlocksSecondDojo: true,
      labelKey: 'shop_bundle_new_school_label',
      descKey: 'shop_bundle_new_school_desc',
      isTimeLimited: false,
      isActive: true,
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // COSTOS DE ACCIONES IN-GAME PAGAS (usando GM)
  // ──────────────────────────────────────────────────────────────────────────

  /// GM para acelerar entrenamiento (saltar tiempo de semana)
  static const int gmToSkipTrainingWeek = 10;

  /// GM para recuperar stamina de un estudiante inmediatamente
  static const int gmToRestoreStamina = 2;

  /// GM para curar una lesión instantáneamente
  static const int gmToHealInjury = 5;

  /// GM para añadir un slot temporal de torneo (pelear 3 estudiantes en lugar de 2)
  static const int gmForExtraTournamentSlot = 8;

  /// GM para ver las stats completas de un candidato en el mercado (sin scout)
  static const int gmToRevealMarketStudent = 1;
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA CLASSES
// ──────────────────────────────────────────────────────────────────────────────

class GemPackage {
  final String id;
  final String storeIdIos;
  final String storeIdAndroid;
  final int gems;
  final double priceUSD;
  final String labelKey;
  final String descKey;
  final bool isBestValue;
  final int bonusPercent;

  const GemPackage({
    required this.id,
    required this.storeIdIos,
    required this.storeIdAndroid,
    required this.gems,
    required this.priceUSD,
    required this.labelKey,
    required this.descKey,
    required this.isBestValue,
    required this.bonusPercent,
  });
}

class MasterPass {
  final String id;
  final String storeIdIos;
  final String storeIdAndroid;
  final double priceUSD;
  final bool isAnnual;
  final String labelKey;
  final String descKey;
  final String? savingsLabelKey;
  final List<String> benefitsKeys;

  const MasterPass({
    required this.id,
    required this.storeIdIos,
    required this.storeIdAndroid,
    required this.priceUSD,
    required this.isAnnual,
    required this.labelKey,
    required this.descKey,
    this.savingsLabelKey,
    required this.benefitsKeys,
  });
}

class MDPackage {
  final String id;
  final String storeIdIos;
  final String storeIdAndroid;
  final int amount;
  final double priceUSD;
  final String labelKey;
  final int bonusPercent;

  const MDPackage({
    required this.id,
    required this.storeIdIos,
    required this.storeIdAndroid,
    required this.amount,
    required this.priceUSD,
    required this.labelKey,
    this.bonusPercent = 0,
  });
}

class SpecialBundle {
  final String id;
  final String storeIdIos;
  final String storeIdAndroid;
  final double priceUSD;
  final int gemsIncluded;
  final int mdIncluded;
  final bool unlocksSecondDojo;
  final String labelKey;
  final String descKey;
  final bool isTimeLimited;
  final bool isActive;

  const SpecialBundle({
    required this.id,
    required this.storeIdIos,
    required this.storeIdAndroid,
    required this.priceUSD,
    required this.gemsIncluded,
    required this.mdIncluded,
    this.unlocksSecondDojo = false,
    required this.labelKey,
    required this.descKey,
    required this.isTimeLimited,
    required this.isActive,
  });
}
