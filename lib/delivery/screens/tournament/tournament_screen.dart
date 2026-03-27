import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../core/providers/dojo_provider.dart';
import 'next_match_tab.dart';
import 'standings_tab.dart';
import 'results_tab.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    // Inicializar liga al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tournamentProvider.notifier).initLeague();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc        = l10n(context);
    final tournament = ref.watch(tournamentProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 44,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.tournamentTitle,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 14,
                color: AppColors.goldLight,
                letterSpacing: 1.2,
              ),
            ),
            if (tournament != null)
              Text(
                loc.tournamentRound(tournament.week),
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.bgDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: AppColors.redAction,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textTertiary,
              labelStyle: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: GoogleFonts.rajdhani(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: loc.tournamentNextMatch),
                Tab(text: loc.tournamentStandings),
                Tab(text: loc.tournamentResults),
              ],
            ),
          ),
        ),
      ),
      body: tournament == null
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.redAction),
      )
          : TabBarView(
        controller: _tabs,
        children: [
          NextMatchTab(tournament: tournament),
          StandingsTab(tournament: tournament),
          ResultsTab(tournament: tournament),
        ],
      ),
    );
  }
}