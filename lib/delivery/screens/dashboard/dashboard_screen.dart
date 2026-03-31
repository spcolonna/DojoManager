import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/core/constants/app_colors.dart';
import 'package:grand_dojo/core/utils/l10n_helper.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/providers/messages_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../settings/settings_screen.dart';
import '../training/training_screen.dart';
import '../tournament/tournament_screen.dart';
import '../students/students_screen.dart';
import '../shop/shop_screen.dart';
import '../messages/messages_screen.dart';
import 'widgets/widgets.dart';


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
  
  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    ref.listen<int>(navigationProvider, (_, index) {
      setState(() => _selectedIndex = index);
    });

    final unread = ref.watch(unreadMessagesProvider);

    final screens = [
      const DojoHome(),
      const TrainingScreen(),
      const TournamentScreen(),
      const StudentsScreen(),
      const ShopScreen(),
    ];

    final navItems = [
      NavItem(label: loc.navDojo,       icon: PhosphorIconsFill.house),
      NavItem(label: loc.navTraining,   icon: PhosphorIconsFill.barbell),
      NavItem(label: loc.navTournament, icon: PhosphorIconsFill.trophy),
      NavItem(label: loc.navStudents,   icon: PhosphorIconsFill.users),
      NavItem(label: loc.navShop,       icon: PhosphorIconsFill.storefront),
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
                    CurrencyChip(
                      icon: AppIcons.currencyMD,
                      value: _md,
                      color: AppColors.goldLight,
                      bgColor: AppColors.goldMuted,
                      label: loc.currencyMDShort,
                    ),
                    const SizedBox(width: 8),
                    CurrencyChip(
                      icon: AppIcons.currencyGM,
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
                          icon: const Icon(AppIcons.navMessages,
                              color: AppColors.textSecondary, size: 24),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        if (unread > 0)
                          Positioned(
                            top: 2, right: 2,
                            child: Container(
                              width: 8, height: 8,
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
                      icon: const Icon(AppIcons.navSettings,
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
              color: Colors.black.withValues(alpha: 0.4),
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
                                ? AppColors.goldPrimary.withValues(alpha: 0.15)
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