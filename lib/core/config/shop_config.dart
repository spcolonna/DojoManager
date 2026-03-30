/// Toda la configuración de la tienda en un solo lugar.
/// Para agregar un producto nuevo: agregar una entrada aquí.
class ShopConfig {
  ShopConfig._();

  // ─── FLAG DE SIMULACIÓN ───────────────────────────────────────────────────
  /// true  → todas las compras se efectúan sin pasar por RevenueCat
  /// false → flujo real de RevenueCat / App Store
  static const bool simulationMode = true;

  // ─── OFERTA DIARIA GRATUITA ───────────────────────────────────────────────
  static const DailyOffer dailyOffer = DailyOffer(
    rewardMD: 50,
    rewardGems: 0,
    rewardItemId: null,
    refreshHours: 24,
  );

  // ─── PAQUETES DE GEMAS ────────────────────────────────────────────────────
  static const List<GemPackage> gemPackages = [
    GemPackage(
      id: 'gems_starter',
      storeId: 'grand_dojo_gems_starter',
      gems: 80,
      priceUSD: 0.99,
      tag: null,
    ),
    GemPackage(
      id: 'gems_advanced',
      storeId: 'grand_dojo_gems_advanced',
      gems: 500,
      priceUSD: 4.99,
      tag: null,
    ),
    GemPackage(
      id: 'gems_grand_master',
      storeId: 'grand_dojo_gems_grand_master',
      gems: 1200,
      bonusGems: 240,
      priceUSD: 9.99,
      tag: 'BEST VALUE',
    ),
    GemPackage(
      id: 'gems_legendary',
      storeId: 'grand_dojo_gems_legendary',
      gems: 3500,
      bonusGems: 1225,
      priceUSD: 19.99,
      tag: '35% BONUS',
    ),
  ];

  // ─── PAQUETES DE MD ───────────────────────────────────────────────────────
  static const List<MDPackage> mdPackages = [
    MDPackage(
      id: 'md_small',
      storeId: 'grand_dojo_md_small',
      md: 500,
      priceUSD: 0.99,
    ),
    MDPackage(
      id: 'md_medium',
      storeId: 'grand_dojo_md_medium',
      md: 2000,
      bonusMD: 200,
      priceUSD: 2.99,
    ),
    MDPackage(
      id: 'md_large',
      storeId: 'grand_dojo_md_large',
      md: 6000,
      bonusMD: 1200,
      priceUSD: 4.99,
      tag: 'POPULAR',
    ),
  ];

  // ─── COMBOS ───────────────────────────────────────────────────────────────
  static const List<ComboPackage> combos = [
    ComboPackage(
      id: 'combo_starter',
      storeId: 'grand_dojo_combo_starter',
      titleKey: 'shopComboStarterTitle',
      descKey: 'shopComboStarterDesc',
      gems: 200,
      md: 1000,
      bonusItemId: 'item_xp_booster',
      priceUSD: 3.99,
      tag: 'NEW MASTER',
      highlightColor: 0xFFD4780A,
    ),
    ComboPackage(
      id: 'combo_champion',
      storeId: 'grand_dojo_combo_champion',
      titleKey: 'shopComboChampionTitle',
      descKey: 'shopComboChampionDesc',
      gems: 600,
      md: 3000,
      bonusItemId: 'item_scout_premium',
      priceUSD: 8.99,
      tag: 'CHAMPION',
      highlightColor: 0xFFFFD700,
    ),
    ComboPackage(
      id: 'combo_legend',
      storeId: 'grand_dojo_combo_legend',
      titleKey: 'shopComboLegendTitle',
      descKey: 'shopComboLegendDesc',
      gems: 1500,
      md: 8000,
      bonusItemId: 'item_master_session',
      extraBonusItemId: 'item_injury_shield',
      priceUSD: 17.99,
      tag: '🔥 LEGEND',
      highlightColor: 0xFF7B2D8B,
    ),
  ];

  // ─── PASE DE MAESTRO ──────────────────────────────────────────────────────
  static const MasterPass monthlyPass = MasterPass(
    id: 'pass_monthly',
    storeId: 'grand_dojo_pass_monthly',
    priceUSD: 4.99,
    durationDays: 30,
    bonusMDPercent: 30,
    extraStudentSlot: true,
    weeklyFreeScout: true,
    exclusiveTournament: true,
    weeklyGems: 0,
  );

  static const MasterPass annualPass = MasterPass(
    id: 'pass_annual',
    storeId: 'grand_dojo_pass_annual',
    priceUSD: 34.99,
    durationDays: 365,
    bonusMDPercent: 30,
    extraStudentSlot: true,
    weeklyFreeScout: true,
    exclusiveTournament: true,
    weeklyGems: 10,
    savingsPercent: 41,
  );

  // ─── ITEMS ESPECIALES ─────────────────────────────────────────────────────
  static const List<SpecialItem> specialItems = [
    SpecialItem(
      id: 'item_recovery_potion',
      titleKey: 'shopItemRecoveryTitle',
      descKey: 'shopItemRecoveryDesc',
      icon: 'heartbeat',
      effectType: ItemEffectType.recoveryAll,
      costGems: 5,
      costMD: 0,
    ),
    SpecialItem(
      id: 'item_xp_booster',
      titleKey: 'shopItemXPBoosterTitle',
      descKey: 'shopItemXPBoosterDesc',
      icon: 'star',
      effectType: ItemEffectType.xpBoost,
      effectValue: 50,
      costGems: 8,
      costMD: 0,
    ),
    SpecialItem(
      id: 'item_injury_shield',
      titleKey: 'shopItemInjuryShieldTitle',
      descKey: 'shopItemInjuryShieldDesc',
      icon: 'shield',
      effectType: ItemEffectType.injuryShield,
      costGems: 6,
      costMD: 0,
    ),
    SpecialItem(
      id: 'item_master_session',
      titleKey: 'shopItemMasterSessionTitle',
      descKey: 'shopItemMasterSessionDesc',
      icon: 'brain',
      effectType: ItemEffectType.masterSession,
      effectValue: 20,
      costGems: 5,
      costMD: 0,
    ),
    SpecialItem(
      id: 'item_scout_premium',
      titleKey: 'shopItemScoutPremiumTitle',
      descKey: 'shopItemScoutPremiumDesc',
      icon: 'magnifying_glass',
      effectType: ItemEffectType.premiumScout,
      costGems: 3,
      costMD: 0,
    ),
    SpecialItem(
      id: 'item_md_scout',
      titleKey: 'shopItemMDScoutTitle',
      descKey: 'shopItemMDScoutDesc',
      icon: 'magnifying_glass',
      effectType: ItemEffectType.basicScout,
      costGems: 0,
      costMD: 100,
    ),
  ];

  // ─── ESTUDIANTES DESTACADOS (rotación 48hs) ───────────────────────────────
  // Se generan proceduralmente con seed basado en la fecha
  static int featuredStudentSeed() {
    final now = DateTime.now();
    // Cambia cada 48 horas
    return now.year * 10000 + now.month * 100 + (now.day ~/ 2);
  }

  static const int featuredStudentCount = 3;
  static const int featuredStudentBeltMin = 4; // mínimo verde
  static const int featuredStudentBeltMax = 7; // máximo marrón

  static const List<FeaturedStudentPrice> featuredStudentPrices = [
    FeaturedStudentPrice(beltLevel: 4, costMD: 800,   costGems: 0),
    FeaturedStudentPrice(beltLevel: 5, costMD: 1500,  costGems: 0),
    FeaturedStudentPrice(beltLevel: 6, costMD: 0,     costGems: 30),
    FeaturedStudentPrice(beltLevel: 7, costMD: 0,     costGems: 60),
  ];
}

// ─── DATA CLASSES ─────────────────────────────────────────────────────────────

class DailyOffer {
  final int rewardMD;
  final int rewardGems;
  final String? rewardItemId;
  final int refreshHours;
  const DailyOffer({
    required this.rewardMD, required this.rewardGems,
    required this.rewardItemId, required this.refreshHours,
  });
}

class GemPackage {
  final String id;
  final String storeId;
  final int gems;
  final int bonusGems;
  final double priceUSD;
  final String? tag;
  const GemPackage({
    required this.id, required this.storeId, required this.gems,
    this.bonusGems = 0, required this.priceUSD, this.tag,
  });
  int get totalGems => gems + bonusGems;
}

class MDPackage {
  final String id;
  final String storeId;
  final int md;
  final int bonusMD;
  final double priceUSD;
  final String? tag;
  const MDPackage({
    required this.id, required this.storeId, required this.md,
    this.bonusMD = 0, required this.priceUSD, this.tag,
  });
  int get totalMD => md + bonusMD;
}

class ComboPackage {
  final String id;
  final String storeId;
  final String titleKey;
  final String descKey;
  final int gems;
  final int md;
  final String? bonusItemId;
  final String? extraBonusItemId;
  final double priceUSD;
  final String? tag;
  final int highlightColor;
  const ComboPackage({
    required this.id, required this.storeId,
    required this.titleKey, required this.descKey,
    required this.gems, required this.md,
    this.bonusItemId, this.extraBonusItemId,
    required this.priceUSD, this.tag,
    required this.highlightColor,
  });
}

class MasterPass {
  final String id;
  final String storeId;
  final double priceUSD;
  final int durationDays;
  final int bonusMDPercent;
  final bool extraStudentSlot;
  final bool weeklyFreeScout;
  final bool exclusiveTournament;
  final int weeklyGems;
  final int savingsPercent;
  const MasterPass({
    required this.id, required this.storeId,
    required this.priceUSD, required this.durationDays,
    required this.bonusMDPercent, required this.extraStudentSlot,
    required this.weeklyFreeScout, required this.exclusiveTournament,
    required this.weeklyGems, this.savingsPercent = 0,
  });
}

enum ItemEffectType {
  recoveryAll,
  xpBoost,
  injuryShield,
  masterSession,
  premiumScout,
  basicScout,
}

class SpecialItem {
  final String id;
  final String titleKey;
  final String descKey;
  final String icon;
  final ItemEffectType effectType;
  final int effectValue;
  final int costGems;
  final int costMD;
  const SpecialItem({
    required this.id, required this.titleKey, required this.descKey,
    required this.icon, required this.effectType,
    this.effectValue = 0, required this.costGems, required this.costMD,
  });
}

class FeaturedStudentPrice {
  final int beltLevel;
  final int costMD;
  final int costGems;
  const FeaturedStudentPrice({
    required this.beltLevel, required this.costMD, required this.costGems,
  });
}