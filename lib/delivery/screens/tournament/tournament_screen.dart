import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../domain/day_plan.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../widgets/no_tournament_view.dart';
import '../training/training_view_model.dart';
import 'next_match_tab.dart';
import 'not_match_day_view.dart';
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
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final tournament = ref.watch(tournamentProvider);
    final trainingState = ref.watch(trainingViewModelProvider);

    final tournamentDay = trainingState.plan.tournamentDay;
    final tournamentDayPlan =
        tournamentDay != null ? trainingState.plan.days[tournamentDay] : null;

    // Es día de combate si:
    // 1. Existe un día de torneo en el plan
    // 2. Ese día no fue simulado (el combate no se jugó aún)
    // 3. Los días de entrenamiento previos al torneo están todos simulados
    //    (no podés jugar el sábado si el lunes todavía no entrenaste)
    final daysBeforeTournament = tournamentDay != null
        ? trainingState.plan.days.entries.where((e) =>
            e.key != tournamentDay &&
            e.value.type == DayType.training &&
            DayOfWeek.values.indexOf(e.key) <
                DayOfWeek.values.indexOf(tournamentDay))
        : <MapEntry<DayOfWeek, DayPlan>>[].cast<MapEntry<DayOfWeek, DayPlan>>();

    final allPriorDone = daysBeforeTournament.every((e) => e.value.isSimulated);

    final isMatchDay = tournamentDay != null &&
        tournamentDayPlan != null &&
        !tournamentDayPlan.isSimulated &&
        allPriorDone;

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
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
                  letterSpacing: 0.5),
              unselectedLabelStyle: GoogleFonts.rajdhani(
                  fontSize: 12, fontWeight: FontWeight.w500),
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
          ? const NoTournamentView()
          : TabBarView(
              controller: _tabs,
              children: [
                isMatchDay
                    ? NextMatchTab(tournament: tournament)
                    : tournamentDay == null
                        ? const NoTournamentView()
                        : NotMatchDayView(
                            tournament: tournament,
                            tournamentDay: tournamentDay,
                            trainingState: trainingState,
                          ),
                StandingsTab(tournament: tournament),
                ResultsTab(tournament: tournament),
              ],
            ),
    );
  }
}
