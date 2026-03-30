import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/shop_config.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/providers/shop_provider.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import 'content_chip.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {

  @override
  Widget build(BuildContext context) {
    final loc       = l10n(context);
    final shopState = ref.watch(shopProvider);

    // Mostrar snackbar de resultado
    ref.listen<ShopState>(shopProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!,
              style: GoogleFonts.rajdhani(color: Colors.white,
                  fontWeight: FontWeight.w700)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        ref.read(shopProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!,
              style: GoogleFonts.rajdhani(color: Colors.white)),
          backgroundColor: AppColors.redAction,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        ref.read(shopProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 44,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          loc.shopTitle,
          style: GoogleFonts.cinzelDecorative(
              fontSize: 14, color: AppColors.goldLight, letterSpacing: 1.2),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.bgDivider),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner de simulación ─────────────────────────
                if (ShopConfig.simulationMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 7, horizontal: 16),
                    color: AppColors.warning.withOpacity(0.15),
                    child: Text(
                      loc.shopSimulationBanner,
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, color: AppColors.warning,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ),

                // ── Oferta diaria gratuita ───────────────────────
                _DailyOfferSection(shopState: shopState, loc: loc),

                // ── Estudiantes destacados ───────────────────────
                _FeaturedStudentsSection(shopState: shopState, loc: loc),

                // ── Pase de Maestro ──────────────────────────────
                _MasterPassSection(loc: loc),

                // ── Combos ───────────────────────────────────────
                _CombosSection(loc: loc),

                // ── Gemas ────────────────────────────────────────
                _SectionHeader(
                  title: loc.shopGems,
                  icon: AppIcons.currencyGM,
                  color: AppColors.infoLight,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ShopConfig.gemPackages.map((pkg) =>
                        _GemCard(package: pkg, loc: loc),
                    ).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Monedas de Dojo ──────────────────────────────
                _SectionHeader(
                  title: loc.shopDojoCoins,
                  icon: AppIcons.currencyMD,
                  color: AppColors.goldPrimary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: ShopConfig.mdPackages.map((pkg) =>
                        _MDCard(package: pkg, loc: loc),
                    ).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Items especiales ─────────────────────────────
                _SectionHeader(title: loc.shopSpecialItems,
                    icon: Icons.auto_awesome_rounded,
                    color: AppColors.purple),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 10, runSpacing: 10,
                    children: ShopConfig.specialItems.map((item) =>
                        _SpecialItemCard(item: item, loc: loc),
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Loading overlay
          if (shopState.isPurchasing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.goldPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── SECCIÓN HEADER ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.rajdhani(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: color, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── OFERTA DIARIA ────────────────────────────────────────────────────────────

class _DailyOfferSection extends ConsumerWidget {
  final ShopState shopState;
  final dynamic loc;
  const _DailyOfferSection({required this.shopState, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canClaim = shopState.canClaimDaily;
    final remaining = shopState.timeUntilNextDaily;
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.15),
            AppColors.bgSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: canClaim
              ? AppColors.success.withOpacity(0.5)
              : AppColors.bgDivider,
          width: canClaim ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.success.withOpacity(0.4)),
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                color: AppColors.success, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.shopDailyOffer,
                  style: GoogleFonts.rajdhani(
                      fontSize: 10, fontWeight: FontWeight.w800,
                      color: AppColors.textTertiary, letterSpacing: 1.5),
                ),
                Text(
                  '+${ShopConfig.dailyOffer.rewardMD} MD',
                  style: GoogleFonts.cinzelDecorative(
                      fontSize: 20, fontWeight: FontWeight.bold,
                      color: AppColors.success),
                ),
                Text(
                  canClaim
                      ? 'Disponible ahora'
                      : loc.shopDailyOfferRefresh(h, m),
                  style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: canClaim
                          ? AppColors.success
                          : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canClaim
                ? () => ref.read(shopProvider.notifier).claimDailyOffer()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canClaim
                  ? AppColors.success
                  : AppColors.bgElevated,
              foregroundColor: canClaim
                  ? Colors.white : AppColors.textDisabled,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              canClaim ? loc.shopDailyOfferClaim : loc.shopDailyOfferClaimed,
              style: GoogleFonts.rajdhani(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ESTUDIANTES DESTACADOS ───────────────────────────────────────────────────

class _FeaturedStudentsSection extends ConsumerWidget {
  final ShopState shopState;
  final dynamic loc;
  const _FeaturedStudentsSection({required this.shopState, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seed     = ShopConfig.featuredStudentSeed();
    final nextChange = DateTime(
        DateTime.now().year, DateTime.now().month,
        (DateTime.now().day ~/ 2) * 2 + 2);
    final hoursLeft = nextChange.difference(DateTime.now()).inHours.clamp(0, 48);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.goldPrimary, size: 16),
              const SizedBox(width: 8),
              Text(
                loc.shopFeaturedStudents,
                style: GoogleFonts.rajdhani(
                    fontSize: 11, fontWeight: FontWeight.w800,
                    color: AppColors.goldPrimary, letterSpacing: 1.5),
              ),
              const Spacer(),
              Text(
                loc.shopFeaturedRotates(hoursLeft),
                style: GoogleFonts.rajdhani(
                    fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shopState.featuredStudents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _FeaturedStudentCard(
              offer: shopState.featuredStudents[i],
              loc: loc,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedStudentCard extends ConsumerWidget {
  final FeaturedStudentOffer offer;
  final dynamic loc;
  const _FeaturedStudentCard({required this.offer, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styleColor =
        AppColors.colorByStyle[offer.styleId] ?? AppColors.goldPrimary;
    final beltColor =
        AppColors.beltColorByLevel[offer.beltLevel] ?? AppColors.beltWhite;
    final tierColor = switch (offer.tier) {
      'Platinum' => const Color(0xFF5DADE2),
      'Gold'     => AppColors.goldPrimary,
      _          => const Color(0xFFC0C0C0),
    };

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styleColor.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [styleColor.withOpacity(0.08), AppColors.bgSurface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + tier
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: styleColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: styleColor.withOpacity(0.4)),
                ),
                child: Icon(Icons.person_rounded,
                    color: styleColor, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: tierColor.withOpacity(0.4)),
                ),
                child: Text(
                  offer.tier,
                  style: GoogleFonts.rajdhani(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      color: tierColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            offer.name,
            style: GoogleFonts.rajdhani(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                    color: beltColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                beltDisplayName('belt_${_beltKey(offer.beltLevel)}', loc),
                style: GoogleFonts.rajdhani(
                    fontSize: 11, color: beltColor,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Mini stats
          _MiniStatRow('STR', offer.stats.str, AppColors.branchPower),
          _MiniStatRow('TEC', offer.stats.tec, AppColors.branchTechnique),
          _MiniStatRow('SPD', offer.stats.spd, AppColors.branchAgility),
          const Spacer(),
          // Precio
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmPurchase(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: styleColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    offer.costGems > 0 ? AppIcons.currencyGM : AppIcons.currencyMD,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offer.costGems > 0
                        ? '${offer.costGems}'
                        : '${offer.costMD}',
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPurchase(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Fichar a ${offer.name}',
            style: GoogleFonts.cinzelDecorative(
                fontSize: 14, color: AppColors.textPrimary)),
        content: Text(
            offer.costGems > 0
                ? '¿Gastás ${offer.costGems} Gemas?'
                : '¿Gastás ${offer.costMD} MD?',
            style: GoogleFonts.rajdhani(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(shopProvider.notifier)
                  .purchaseFeaturedStudent(offer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.black,
            ),
            child: Text('FICHAR',
                style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  String _beltKey(int level) => switch (level) {
    1 => 'white', 2 => 'yellow', 3 => 'orange', 4 => 'green',
    5 => 'blue', 6 => 'purple', 7 => 'brown', 8 => 'red',
    9 => 'red_black', 10 => 'black', _ => 'white',
  };
}

class _MiniStatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(label,
                style: GoogleFonts.rajdhani(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 30.0,
                minHeight: 4,
                backgroundColor: AppColors.bgDivider,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text('$value',
              style: GoogleFonts.rajdhani(
                  fontSize: 9, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ─── PASE DE MAESTRO ──────────────────────────────────────────────────────────

class _MasterPassSection extends ConsumerWidget {
  final dynamic loc;
  const _MasterPassSection({required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A2E), Color(0xFF0A0A1A)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purple.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.goldPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                loc.shopMasterPass,
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 14, fontWeight: FontWeight.bold,
                    color: AppColors.goldLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Beneficios
          ...[
            '+${ShopConfig.monthlyPass.bonusMDPercent}% MD en torneos',
            '+1 slot de estudiante',
            '1 scout gratis por semana',
            'Torneo exclusivo semanal',
          ].map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.goldPrimary, size: 13),
                const SizedBox(width: 6),
                Text(b, style: GoogleFonts.rajdhani(
                    fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          )),
          const SizedBox(height: 14),
          // Botones mensual / anual
          Row(
            children: [
              Expanded(
                child: _PassButton(
                  pass: ShopConfig.monthlyPass,
                  label: loc.shopPassMonthly,
                  loc: loc,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PassButton(
                  pass: ShopConfig.annualPass,
                  label: loc.shopPassAnnual,
                  loc: loc,
                  savingsLabel: loc.shopPassSave(
                      ShopConfig.annualPass.savingsPercent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassButton extends ConsumerWidget {
  final MasterPass pass;
  final String label;
  final dynamic loc;
  final String? savingsLabel;

  const _PassButton({
    required this.pass, required this.label,
    required this.loc, this.savingsLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (savingsLabel != null)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(savingsLabel!,
                style: GoogleFonts.rajdhani(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ElevatedButton(
          onPressed: () => ref.read(shopProvider.notifier).purchasePass(pass),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple.withOpacity(0.8),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 42),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Column(
            children: [
              Text(label, style: GoogleFonts.rajdhani(
                  fontSize: 12, fontWeight: FontWeight.w700)),
              Text('\$${pass.priceUSD.toStringAsFixed(2)}',
                  style: GoogleFonts.rajdhani(
                      fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── COMBOS ───────────────────────────────────────────────────────────────────

class _CombosSection extends ConsumerWidget {
  final dynamic loc;
  const _CombosSection({required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: loc.shopCombos,
            icon: Icons.local_fire_department_rounded,
            color: AppColors.orange),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: ShopConfig.combos.map((combo) =>
                _ComboCard(combo: combo, loc: loc),
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class _ComboCard extends ConsumerWidget {
  final ComboPackage combo;
  final dynamic loc;
  const _ComboCard({required this.combo, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(combo.highlightColor);
    final bonusItem = combo.bonusItemId != null
        ? ShopConfig.specialItems
        .where((i) => i.id == combo.bonusItemId)
        .firstOrNull
        : null;
    final extraItem = combo.extraBonusItemId != null
        ? ShopConfig.specialItems
        .where((i) => i.id == combo.extraBonusItemId)
        .firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.15), AppColors.bgSurface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (combo.tag != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(combo.tag!,
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: 1)),
                  ),
                Text(
                  _titleFor(combo.id, loc),
                  style: GoogleFonts.cinzelDecorative(
                      fontSize: 13, fontWeight: FontWeight.bold,
                      color: color),
                ),
                const SizedBox(height: 6),
                // Contenido
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ContentChipIcon(AppIcons.currencyGM, '${combo.gems}', AppColors.infoLight),
                    ContentChipIcon(AppIcons.currencyMD, '${combo.md}', AppColors.goldPrimary),
                    if (bonusItem != null)
                      _ContentChip('+ ${_itemShortName(bonusItem.id)}', AppColors.success),
                    if (extraItem != null)
                      _ContentChip('+ ${_itemShortName(extraItem.id)}', AppColors.success),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _confirm(context, ref, combo),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              '\$${combo.priceUSD.toStringAsFixed(2)}',
              style: GoogleFonts.cinzelDecorative(
                  fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _confirm(BuildContext ctx, WidgetRef ref, ComboPackage c) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(_titleFor(c.id, loc),
            style: GoogleFonts.cinzelDecorative(
                fontSize: 14, color: AppColors.textPrimary)),
        content: Text(
            '¿Confirmás la compra por \$${c.priceUSD.toStringAsFixed(2)}?',
            style: GoogleFonts.rajdhani(
                fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar',
                  style: GoogleFonts.rajdhani(
                      color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(shopProvider.notifier).purchaseCombo(c);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color(c.highlightColor),
                foregroundColor: Colors.white),
            child: Text('COMPRAR',
                style: GoogleFonts.rajdhani(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  String _titleFor(String id, dynamic loc) => switch (id) {
    'combo_starter'  => loc.shopComboStarterTitle,
    'combo_champion' => loc.shopComboChampionTitle,
    'combo_legend'   => loc.shopComboLegendTitle,
    _                => id,
  };

  String _itemShortName(String id) => switch (id) {
    'item_xp_booster'    => 'XP Boost',
    'item_scout_premium' => 'Scout',
    'item_master_session'=> 'Sesión',
    'item_injury_shield' => 'Escudo',
    _                    => id,
  };
}

class _ContentChip extends StatelessWidget {
  final String text;
  final Color color;
  const _ContentChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: GoogleFonts.rajdhani(
          fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ─── GEMAS ────────────────────────────────────────────────────────────────────

class _GemCard extends ConsumerWidget {
  final GemPackage package;
  final dynamic loc;
  const _GemCard({required this.package, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: package.tag != null
                ? AppColors.infoLight.withOpacity(0.4)
                : AppColors.bgDivider),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.currencyGM, color: AppColors.infoLight, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${package.gems} Gemas',
                        style: GoogleFonts.rajdhani(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (package.bonusGems > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                            '+${package.bonusGems}',
                            style: GoogleFonts.rajdhani(
                                fontSize: 9, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                if (package.tag != null)
                  Text(package.tag!,
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, color: AppColors.goldPrimary,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(shopProvider.notifier).purchaseGems(package),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              '\$${package.priceUSD.toStringAsFixed(2)}',
              style: GoogleFonts.rajdhani(
                  fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MD ───────────────────────────────────────────────────────────────────────

class _MDCard extends ConsumerWidget {
  final MDPackage package;
  final dynamic loc;
  const _MDCard({required this.package, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: package.tag != null
                ? AppColors.goldPrimary.withOpacity(0.4)
                : AppColors.bgDivider),
      ),
      child: Row(
        children: [
          const Icon(AppIcons.currencyMD, color: AppColors.goldPrimary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${package.md} MD',
                        style: GoogleFonts.rajdhani(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (package.bonusMD > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                            '+${package.bonusMD}',
                            style: GoogleFonts.rajdhani(
                                fontSize: 9, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ],
                ),
                if (package.tag != null)
                  Text(package.tag!,
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, color: AppColors.goldPrimary,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(shopProvider.notifier).purchaseMD(package),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              '\$${package.priceUSD.toStringAsFixed(2)}',
              style: GoogleFonts.rajdhani(
                  fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ITEMS ESPECIALES ─────────────────────────────────────────────────────────

class _SpecialItemCard extends ConsumerWidget {
  final SpecialItem item;
  final dynamic loc;
  const _SpecialItemCard({required this.item, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costColor = item.costGems > 0
        ? AppColors.infoLight
        : AppColors.goldPrimary;
    final costLabel = item.costGems > 0
        ? '💎 ${item.costGems}'
        : '🏅 ${item.costMD}';

    return Container(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.purple, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            _titleFor(item.id, loc),
            style: GoogleFonts.rajdhani(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _descFor(item.id, loc),
            style: GoogleFonts.rajdhani(
                fontSize: 10, color: AppColors.textTertiary, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref
                  .read(shopProvider.notifier)
                  .purchaseItem(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: costColor.withOpacity(0.15),
                foregroundColor: costColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: costColor.withOpacity(0.4))),
              ),
              child: Text(costLabel,
                  style: GoogleFonts.rajdhani(
                      fontSize: 13, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(String id, dynamic loc) => switch (id) {
    'item_recovery_potion' => loc.shopItemRecoveryTitle,
    'item_xp_booster'      => loc.shopItemXPBoosterTitle,
    'item_injury_shield'   => loc.shopItemInjuryShieldTitle,
    'item_master_session'  => loc.shopItemMasterSessionTitle,
    'item_scout_premium'   => loc.shopItemScoutPremiumTitle,
    'item_md_scout'        => loc.shopItemMDScoutTitle,
    _                      => id,
  };

  String _descFor(String id, dynamic loc) => switch (id) {
    'item_recovery_potion' => loc.shopItemRecoveryDesc,
    'item_xp_booster'      => loc.shopItemXPBoosterDesc,
    'item_injury_shield'   => loc.shopItemInjuryShieldDesc,
    'item_master_session'  => loc.shopItemMasterSessionDesc,
    'item_scout_premium'   => loc.shopItemScoutPremiumDesc,
    'item_md_scout'        => loc.shopItemMDScoutDesc,
    _                      => id,
  };
}