import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/core/constants/app_colors.dart';
import 'package:grand_dojo/core/utils/l10n_helper.dart';
import '../../../core/providers/dojo_provider.dart';
import '../dojo/dojo_screen.dart';
import '../settings/settings_screen.dart';
import '../training/training_screen.dart';
import '../tournament/tournament_screen.dart';
import '../students/students_screen.dart';
import '../market/market_screen.dart';
import '../shop/shop_screen.dart';
import '../messages/messages_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  static const int _week           = 1;
  static const int _season         = 1;
  static const int _md             = 150;
  static const int _gm             = 0;
  static const int _unreadMessages = 1;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    final screens = [
      const _DojoHome(),
      const TrainingScreen(),
      const TournamentScreen(),
      const StudentsScreen(),
      const ShopScreen(),
    ];

    final navItems = [
      _NavItem(label: loc.navDojo,       icon: Icons.home_work_rounded),
      _NavItem(label: loc.navTraining,   icon: Icons.fitness_center_rounded),
      _NavItem(label: loc.navTournament, icon: Icons.emoji_events_rounded),
      _NavItem(label: loc.navStudents,   icon: Icons.people_rounded),
      _NavItem(label: loc.navShop,       icon: Icons.diamond_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Column(
        children: [
          // ── TOP BAR ─────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.gradientHeader,
              border: Border(
                bottom: BorderSide(color: AppColors.bgDivider, width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.appName,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldLight,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.dashboardWeekLabel(_week, _season),
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _CurrencyChip(
                      icon: Icons.monetization_on_rounded,
                      value: _md,
                      color: AppColors.goldLight,
                      bgColor: AppColors.goldMuted,
                      label: loc.currencyMDShort,
                    ),
                    const SizedBox(width: 8),
                    _CurrencyChip(
                      icon: Icons.diamond_rounded,
                      value: _gm,
                      color: AppColors.infoLight,
                      bgColor: AppColors.infoBg,
                      label: loc.currencyGMShort,
                    ),
                    const SizedBox(width: 4),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const MessagesScreen()),
                          ),
                          icon: const Icon(Icons.notifications_rounded,
                              color: AppColors.textSecondary, size: 24),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        if (_unreadMessages > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.redLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.textSecondary, size: 24),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────
          Expanded(child: screens[_selectedIndex]),
        ],
      ),

      // ── BOTTOM NAV ──────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: const Border(
            top: BorderSide(color: AppColors.bgDivider, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(navItems.length, (i) {
                final item       = navItems[i];
                final isSelected = i == _selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.goldPrimary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.goldLight
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.goldLight
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DOJO HOME ───────────────────────────────────────────────────────────────

class _DojoHome extends ConsumerWidget {
  const _DojoHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc          = l10n(context);
    final dojoAsync    = ref.watch(dojoProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // ── Banner del dojo ──────────────────────────────────────────
          dojoAsync.when(
            loading: () => _DojoBannerSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (dojo) {
              if (dojo == null) return const SizedBox.shrink();

              final styleName  = _styleDisplayName(dojo.styleId, loc);
              final styleColor = AppColors.colorByStyle[dojo.styleId] ??
                  AppColors.goldPrimary;
              final slotsUsed  = studentsAsync.valueOrNull?.length ?? 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientDojo,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldDark, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: styleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: styleColor.withOpacity(0.5)),
                      ),
                      child: Icon(Icons.home_work_rounded,
                          color: styleColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dojo.name,
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level ${dojo.level} · $styleName',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: slotsUsed / dojo.maxStudentSlots,
                              minHeight: 6,
                              backgroundColor: AppColors.bgDivider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  styleColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$slotsUsed / ${dojo.maxStudentSlots} students',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Quick access ─────────────────────────────────────────────
          Text(
            'QUICK ACCESS',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  title: loc.navMarket,
                  icon: Icons.storefront_rounded,
                  gradient: AppColors.gradientMarket,
                  iconColor: AppColors.purpleLight,
                  borderColor: AppColors.purple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MarketScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  title: loc.navDojo,
                  icon: Icons.construction_rounded,
                  gradient: AppColors.gradientUpgrades,
                  iconColor: AppColors.successLight,
                  borderColor: AppColors.successBorder,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DojoScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Estudiantes ──────────────────────────────────────────────
          Text(
            'MY STUDENTS',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          studentsAsync.when(
            loading: () => Column(
              children: [
                _StudentCardSkeleton(),
                const SizedBox(height: 10),
                _StudentCardSkeleton(),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No students yet',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return Column(
                children: students.map((s) {
                  final beltColor = AppColors.beltColorByLevel[s.belt.level]
                      ?? AppColors.beltWhite;
                  final xpRequired = s.belt.xpRequiredForNextLevel;
                  final xpPercent  = xpRequired > 0
                      ? s.currentXP / xpRequired
                      : 0.0;
                  final styleColor = AppColors.colorByStyle[s.styleId]
                      ?? AppColors.goldPrimary;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StudentPreviewCard(
                      name: s.nameKey,
                      styleId: s.styleId,
                      styleColor: styleColor,
                      belt: s.belt.titleKey,
                      beltColor: beltColor,
                      xpPercent: xpPercent.clamp(0.0, 1.0),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Próximo torneo ───────────────────────────────────────────
          Text(
            'NEXT TOURNAMENT',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientTournament,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.redAction.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.redAction.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.redLight, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly League',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Saturday · White Belt division',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.redAction,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ENROLL',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _styleDisplayName(String id, dynamic loc) => switch (id) {
    'kung_fu'   => loc.styleKungFu,
    'karate'    => loc.styleKarate,
    'taekwondo' => loc.styleTaekwondo,
    'judo'      => loc.styleJudo,
    'muay_thai' => loc.styleMuayThai,
    'bjj'       => loc.styleBjj,
    'boxing'    => loc.styleBoxing,
    'mma'       => loc.styleMma,
    _           => id,
  };
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem({required this.label, required this.icon});
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final Color bgColor;
  final String label;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 3),
          Text(
            '$value',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final LinearGradient gradient;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentPreviewCard extends StatelessWidget {
  final String name;
  final String styleId;
  final Color styleColor;
  final String belt;
  final Color beltColor;
  final double xpPercent;

  const _StudentPreviewCard({
    required this.name,
    required this.styleId,
    required this.styleColor,
    required this.belt,
    required this.beltColor,
    required this.xpPercent,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    final styleDisplay = switch (styleId) {
      'kung_fu'   => loc.styleKungFu,
      'karate'    => loc.styleKarate,
      'taekwondo' => loc.styleTaekwondo,
      'judo'      => loc.styleJudo,
      'muay_thai' => loc.styleMuayThai,
      'bjj'       => loc.styleBjj,
      'boxing'    => loc.styleBoxing,
      'mma'       => loc.styleMma,
      _           => styleId,
    };

    final beltDisplay = switch (belt) {
      'belt_white'     => loc.beltWhite,
      'belt_yellow'    => loc.beltYellow,
      'belt_orange'    => loc.beltOrange,
      'belt_green'     => loc.beltGreen,
      'belt_blue'      => loc.beltBlue,
      'belt_purple'    => loc.beltPurple,
      'belt_brown'     => loc.beltBrown,
      'belt_red'       => loc.beltRed,
      'belt_red_black' => loc.beltRedBlack,
      'belt_black'     => loc.beltBlack,
      _                => belt,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: styleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: styleColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.person_rounded,
                color: styleColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: beltColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      beltDisplay,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: beltColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  styleDisplay,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: xpPercent,
                    minHeight: 4,
                    backgroundColor: AppColors.bgDivider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.disabled, size: 20),
        ],
      ),
    );
  }
}

class _DojoBannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.goldPrimary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _StudentCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
    );
  }
}