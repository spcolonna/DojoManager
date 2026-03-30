import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/shop_config.dart';
import '../../domain/entities/ai/ai_opponent.dart';
import '../../domain/value_objects/belt.dart';
import '../../domain/value_objects/student_stats.dart';
import '../../infrastructure/services/purchase_service.dart';
import '../providers/dojo_provider.dart';
import '../../infrastructure/repositories/firebase_dojo_repository.dart';

class ShopState {
  final bool isDailyOfferClaimed;
  final DateTime? dailyOfferClaimedAt;
  final bool isPurchasing;
  final String? successMessage;
  final String? errorMessage;
  final List<FeaturedStudentOffer> featuredStudents;

  const ShopState({
    this.isDailyOfferClaimed = false,
    this.dailyOfferClaimedAt,
    this.isPurchasing = false,
    this.successMessage,
    this.errorMessage,
    this.featuredStudents = const [],
  });

  ShopState copyWith({
    bool? isDailyOfferClaimed,
    DateTime? dailyOfferClaimedAt,
    bool? isPurchasing,
    String? successMessage,
    String? errorMessage,
    List<FeaturedStudentOffer>? featuredStudents,
    bool clearMessages = false,
  }) => ShopState(
    isDailyOfferClaimed: isDailyOfferClaimed ?? this.isDailyOfferClaimed,
    dailyOfferClaimedAt: dailyOfferClaimedAt ?? this.dailyOfferClaimedAt,
    isPurchasing: isPurchasing ?? this.isPurchasing,
    successMessage: clearMessages ? null : successMessage ?? this.successMessage,
    errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    featuredStudents: featuredStudents ?? this.featuredStudents,
  );

  bool get canClaimDaily {
    if (!isDailyOfferClaimed) return true;
    if (dailyOfferClaimedAt == null) return true;
    final diff = DateTime.now().difference(dailyOfferClaimedAt!);
    return diff.inHours >= ShopConfig.dailyOffer.refreshHours;
  }

  Duration get timeUntilNextDaily {
    if (dailyOfferClaimedAt == null) return Duration.zero;
    final next = dailyOfferClaimedAt!
        .add(Duration(hours: ShopConfig.dailyOffer.refreshHours));
    final remaining = next.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class FeaturedStudentOffer {
  final String id;
  final String name;
  final String styleId;
  final int beltLevel;
  final StudentStats stats;
  final int costMD;
  final int costGems;
  final String tier;

  const FeaturedStudentOffer({
    required this.id, required this.name, required this.styleId,
    required this.beltLevel, required this.stats,
    required this.costMD, required this.costGems, required this.tier,
  });
}

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref _ref;
  final _repo = FirebaseDojoRepository();
  final _purchase = PurchaseService.instance;

  ShopNotifier(this._ref) : super(const ShopState()) {
    _generateFeaturedStudents();
  }

  void _generateFeaturedStudents() {
    final seed = ShopConfig.featuredStudentSeed();
    final rng  = Random(seed);
    final styles = ['kung_fu', 'karate', 'taekwondo', 'judo',
      'muay_thai', 'bjj', 'boxing', 'mma'];
    final names = ['Ryu Tanaka', 'Jin Lee', 'Marco Silva',
      'Kenji Mori', 'Ana Cruz', 'Lars Berg'];
    final tiers = ['Silver', 'Gold', 'Platinum'];

    final students = List.generate(ShopConfig.featuredStudentCount, (i) {
      final belt  = ShopConfig.featuredStudentBeltMin +
          rng.nextInt(ShopConfig.featuredStudentBeltMax -
              ShopConfig.featuredStudentBeltMin + 1);
      final style = styles[rng.nextInt(styles.length)];
      final base  = 10 + belt * 2;
      final price = ShopConfig.featuredStudentPrices
          .firstWhere((p) => p.beltLevel == belt,
          orElse: () => ShopConfig.featuredStudentPrices.last);

      return FeaturedStudentOffer(
        id: 'featured_${seed}_$i',
        name: names[rng.nextInt(names.length)],
        styleId: style,
        beltLevel: belt,
        stats: StudentStats(
          str: base + rng.nextInt(6),
          spd: base + rng.nextInt(6),
          tec: base + rng.nextInt(6),
          def: base + rng.nextInt(6),
          men: base + rng.nextInt(6),
          res: 50 + belt * 5,
        ),
        costMD: price.costMD,
        costGems: price.costGems,
        tier: tiers[rng.nextInt(tiers.length)],
      );
    });

    state = state.copyWith(featuredStudents: students);
  }

  // ── OFERTA DIARIA ─────────────────────────────────────────────────────────

  Future<void> claimDailyOffer() async {
    if (!state.canClaimDaily) return;
    state = state.copyWith(isPurchasing: true, clearMessages: true);

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) {
      state = state.copyWith(isPurchasing: false);
      return;
    }

    await _repo.addMD(dojo.id, ShopConfig.dailyOffer.rewardMD);
    if (ShopConfig.dailyOffer.rewardGems > 0) {
      await _repo.addGems(dojo.id, ShopConfig.dailyOffer.rewardGems);
    }
    _ref.invalidate(dojoProvider);

    state = state.copyWith(
      isPurchasing: false,
      isDailyOfferClaimed: true,
      dailyOfferClaimedAt: DateTime.now(),
      successMessage: '+${ShopConfig.dailyOffer.rewardMD} MD recibidos',
    );
  }

  // ── COMPRAS CON DINERO REAL ────────────────────────────────────────────────

  Future<bool> purchaseGems(GemPackage pkg) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final result = await _purchase.purchaseProduct(pkg.storeId);
    if (!result.success) {
      state = state.copyWith(isPurchasing: false, errorMessage: result.error);
      return false;
    }

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo != null) {
      await _repo.addGems(dojo.id, pkg.totalGems);
      _ref.invalidate(dojoProvider);
    }

    state = state.copyWith(
      isPurchasing: false,
      successMessage: '+${pkg.totalGems} Gemas',
    );
    return true;
  }

  Future<bool> purchaseMD(MDPackage pkg) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final result = await _purchase.purchaseProduct(pkg.storeId);
    if (!result.success) {
      state = state.copyWith(isPurchasing: false, errorMessage: result.error);
      return false;
    }

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo != null) {
      await _repo.addMD(dojo.id, pkg.totalMD);
      _ref.invalidate(dojoProvider);
    }

    state = state.copyWith(
      isPurchasing: false,
      successMessage: '+${pkg.totalMD} MD',
    );
    return true;
  }

  Future<bool> purchaseCombo(ComboPackage pkg) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final result = await _purchase.purchaseProduct(pkg.storeId);
    if (!result.success) {
      state = state.copyWith(isPurchasing: false, errorMessage: result.error);
      return false;
    }

    final dojo = await _ref.read(dojoProvider.future);
    if (dojo != null) {
      if (pkg.gems > 0) await _repo.addGems(dojo.id, pkg.gems);
      if (pkg.md > 0) await _repo.addMD(dojo.id, pkg.md);
      // Items bonus se agregan al inventario del jugador
      // TODO: implementar inventario
      _ref.invalidate(dojoProvider);
    }

    state = state.copyWith(
      isPurchasing: false,
      successMessage: '+${pkg.gems} Gemas + ${pkg.md} MD',
    );
    return true;
  }

  Future<bool> purchasePass(MasterPass pass) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final result = await _purchase.purchaseProduct(pass.storeId);
    if (!result.success) {
      state = state.copyWith(isPurchasing: false, errorMessage: result.error);
      return false;
    }
    // TODO: marcar pase activo en Firestore
    state = state.copyWith(
      isPurchasing: false,
      successMessage: '¡Pase de Maestro activado!',
    );
    return true;
  }

  Future<bool> purchaseItem(SpecialItem item) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) {
      state = state.copyWith(isPurchasing: false);
      return false;
    }

    // Verificar saldo
    if (item.costGems > 0 && dojo.gm < item.costGems) {
      state = state.copyWith(
          isPurchasing: false, errorMessage: 'Gemas insuficientes');
      return false;
    }
    if (item.costMD > 0 && dojo.md < item.costMD) {
      state = state.copyWith(
          isPurchasing: false, errorMessage: 'MD insuficientes');
      return false;
    }

    // Descontar
    if (item.costGems > 0) await _repo.spendGems(dojo.id, item.costGems);
    if (item.costMD > 0)   await _repo.spendMD(dojo.id, item.costMD);

    // Aplicar efecto (simulado — en producción iría al inventario)
    // TODO: sistema de inventario de items

    _ref.invalidate(dojoProvider);
    state = state.copyWith(
      isPurchasing: false,
      successMessage: 'Item adquirido',
    );
    return true;
  }

  Future<bool> purchaseFeaturedStudent(FeaturedStudentOffer offer) async {
    state = state.copyWith(isPurchasing: true, clearMessages: true);
    final dojo = await _ref.read(dojoProvider.future);
    if (dojo == null) { state = state.copyWith(isPurchasing: false); return false; }

    if (offer.costGems > 0 && dojo.gm < offer.costGems) {
      state = state.copyWith(isPurchasing: false, errorMessage: 'Gemas insuficientes');
      return false;
    }
    if (offer.costMD > 0 && dojo.md < offer.costMD) {
      state = state.copyWith(isPurchasing: false, errorMessage: 'MD insuficientes');
      return false;
    }

    if (offer.costGems > 0) await _repo.spendGems(dojo.id, offer.costGems);
    if (offer.costMD > 0)   await _repo.spendMD(dojo.id, offer.costMD);

    await _repo.createStudentFromOffer(
      dojoId: dojo.id,
      name: offer.name,
      styleId: offer.styleId,
      beltLevel: offer.beltLevel,
      stats: offer.stats,
    );

    _ref.invalidate(dojoProvider);
    _ref.invalidate(studentsProvider);
    state = state.copyWith(
      isPurchasing: false,
      successMessage: '${offer.name} se unió a tu dojo',
    );
    return true;
  }

  void clearMessages() => state = state.copyWith(clearMessages: true);
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});