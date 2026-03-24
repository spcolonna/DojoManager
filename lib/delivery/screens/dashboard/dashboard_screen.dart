import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/core/utils/l10n_helper.dart';
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
  static const int _week            = 1;
  static const int _season          = 1;
  static const int _md              = 150;
  static const int _gm              = 0;
  static const int _unreadMessages  = 1;

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              week: _week,
              season: _season,
              md: _md,
              gm: _gm,
              unreadMessages: _unreadMessages,
              onMessagesTap: () => _navigate(context, const MessagesScreen()),
              onSettingsTap: () => _navigate(context, const SettingsScreen()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _NavGrid(
                  onTap: (screen) => _navigate(context, screen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int week, season, md, gm, unreadMessages;
  final VoidCallback onMessagesTap;
  final VoidCallback onSettingsTap;

  const _Header({
    required this.week,
    required this.season,
    required this.md,
    required this.gm,
    required this.unreadMessages,
    required this.onMessagesTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF141824),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A3048), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                loc.appName,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC9A84C),
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onMessagesTap,
                    icon: const Icon(
                      Icons.mail_outline,
                      color: Color(0xFF9099B0),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (unreadMessages > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC0392B),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(
                  Icons.tune,
                  color: Color(0xFF9099B0),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                loc.dashboardWeekLabel(week, season),
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: const Color(0xFF9099B0),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              _CurrencyChip(
                icon: Icons.monetization_on_outlined,
                value: md,
                color: const Color(0xFFC9A84C),
                label: loc.currencyMDShort,
              ),
              const SizedBox(width: 12),
              _CurrencyChip(
                icon: Icons.diamond_outlined,
                value: gm,
                color: const Color(0xFF2980B9),
                label: loc.currencyGMShort,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final String label;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2235),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3048)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
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

// ─── NAV GRID ────────────────────────────────────────────────────────────────

class _NavGrid extends StatelessWidget {
  final void Function(Widget screen) onTap;

  const _NavGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc   = l10n(context);
    final items = [
      _NavItem(
        label: loc.navDojo,
        icon: Icons.home_work_outlined,
        color: const Color(0xFFC9A84C),
        screen: const DojoScreen(),
      ),
      _NavItem(
        label: loc.navTraining,
        icon: Icons.fitness_center,
        color: const Color(0xFFE87020),
        screen: const TrainingScreen(),
      ),
      _NavItem(
        label: loc.navTournament,
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFC0392B),
        screen: const TournamentScreen(),
      ),
      _NavItem(
        label: loc.navStudents,
        icon: Icons.people_outline,
        color: const Color(0xFF27AE60),
        screen: const StudentsScreen(),
      ),
      _NavItem(
        label: loc.navMarket,
        icon: Icons.storefront_outlined,
        color: const Color(0xFF8E44AD),
        screen: const MarketScreen(),
      ),
      _NavItem(
        label: loc.navShop,
        icon: Icons.diamond_outlined,
        color: const Color(0xFF2980B9),
        screen: const ShopScreen(),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _NavCard(
        item: items[i],
        onTap: () => onTap(items[i].screen),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class _NavCard extends StatelessWidget {
  final _NavItem item;
  final VoidCallback onTap;

  const _NavCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141824),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3048)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              item.label,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF0F0F0),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}