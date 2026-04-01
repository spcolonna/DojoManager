import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/fight_fighter.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/fight.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../fight/category_fight_screen.dart';
import '../fight/fight_arena_screen.dart';
import '../training/training_view_model.dart';
import 'match_result_screen.dart';
import 'nextMatchWidget/enrollment_section.dart';
import 'nextMatchWidget/rival_scout.dart';

class NextMatchTab extends ConsumerStatefulWidget {
  final Tournament tournament;
  const NextMatchTab({super.key, required this.tournament});

  @override
  ConsumerState<NextMatchTab> createState() => _NextMatchTabState();
}

class _NextMatchTabState extends ConsumerState<NextMatchTab> {
  Map<int, List<String>> _enrolledByBelt = {};
  Map<int, List<FightStrategy>> _strategiesByBelt = {};
  Map<int, List<int>> _fightOrderByBelt = {};
  bool _isSimulating = false;

  bool get _hasEnrolled =>
      _enrolledByBelt.values.any((ids) => ids.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final loc           = l10n(context);
    final tournament    = widget.tournament;
    final nextMatch     = ref.read(tournamentProvider.notifier).nextPlayerMatch;
    final studentsAsync = ref.watch(studentsProvider);

    if (nextMatch == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 12),
            Text(loc.tournamentNoMatch,
                style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    final playerTeamId  = tournament.playerTeam?.id ?? '';
    final isHome        = nextMatch.homeTeamId == playerTeamId;
    final rivalTeamId   = isHome ? nextMatch.awayTeamId : nextMatch.homeTeamId;
    final rivalTeamList = tournament.teams
        .where((t) => t.id == rivalTeamId)
        .toList();
    final rivalTeam     = rivalTeamList.isEmpty ? null : rivalTeamList.first;
    final rival         =
    ref.read(tournamentProvider.notifier).rivalFor(rivalTeamId);
    final rivalStyleColor =
        AppColors.colorByStyle[rivalTeam?.styleId ?? ''] ?? AppColors.redLight;

    return studentsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.redAction)),
      error: (_, __) => const SizedBox.shrink(),
      data: (students) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Banner del partido ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    rivalStyleColor.withValues(alpha: 0.12),
                    AppColors.bgDeep,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.redAction.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    loc.tournamentStyleLeague.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tu equipo
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.goldPrimary
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.goldPrimary
                                        .withValues(alpha: 0.5)),
                              ),
                              child: const Icon(Icons.home_work_rounded,
                                  color: AppColors.goldLight, size: 26),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tournament.playerTeam?.name ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // VS
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          loc.tournamentVs.toUpperCase(),
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 22, fontWeight: FontWeight.bold,
                            color: AppColors.redAction,
                          ),
                        ),
                      ),
                      // Rival
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                color: rivalStyleColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: rivalStyleColor
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Icon(Icons.sports_mma_rounded,
                                  color: rivalStyleColor, size: 26),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rivalTeam?.name ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: rivalStyleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Scout del rival ──────────────────────────────────────
            if (rival != null)
              RivalScout(rival: rival, loc: loc),

            const SizedBox(height: 16),

            // ── Inscripción por categoría de faja ───────────────────
            if (rival != null)
              EnrollmentSection(
                students: students,
                rival: rival,
                enrolledByBelt: _enrolledByBelt,
                strategiesByBelt: _strategiesByBelt,
                fightOrderByBelt: _fightOrderByBelt,
                onChanged: (enrolled, strategies, fightOrder) => setState(() {
                  _enrolledByBelt    = enrolled;
                  _strategiesByBelt  = strategies;
                  _fightOrderByBelt  = fightOrder;
                }),
                loc: loc,
              ),

            const SizedBox(height: 20),

            // ── Botón simular ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_hasEnrolled || _isSimulating
                    ? null
                    : () => _simulate(context, students),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAction,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSimulating
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : Text(
                  loc.tournamentSimulateMatch,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _simulate(
      BuildContext context, List<Student> students) async {
    if (!_hasEnrolled) return;

    final tournament   = ref.read(tournamentProvider)!;
    final playerTeamId = tournament.playerTeam?.id ?? '';
    final nextMatch =
        ref.read(tournamentProvider.notifier).nextPlayerMatch;
    if (nextMatch == null) return;

    final isHome      = nextMatch.homeTeamId == playerTeamId;
    final rivalTeamId =
    isHome ? nextMatch.awayTeamId : nextMatch.homeTeamId;
    final rival =
    ref.read(tournamentProvider.notifier).rivalFor(rivalTeamId);
    if (rival == null) return;

    final rivalColor =
        AppColors.colorByStyle[rival.styleId] ?? AppColors.redLight;

    // Ordenar las categorías inscritas por faja ascendente
    final enrolledBelts = _enrolledByBelt.keys
        .where((b) => _enrolledByBelt[b]!.isNotEmpty)
        .toList()
      ..sort();

    if (enrolledBelts.isEmpty) return;

    setState(() => _isSimulating = true);

    // Simular categoría por categoría secuencialmente
    for (final belt in enrolledBelts) {
      final enrolledIds   = _enrolledByBelt[belt] ?? [];
      final enrolled      = students.where((s) => enrolledIds.contains(s.id)).toList();
      if (enrolled.isEmpty) continue;

      final rivalFighters = rival.fightersForBelt(belt);
      if (rivalFighters.isEmpty) continue;

      final strategies = _strategiesByBelt[belt] ?? [];
      final fightOrder = _fightOrderByBelt[belt] ?? [0, 1];

      // Ordenar estudiantes según el orden elegido
      final orderedStudents = fightOrder
          .where((idx) => idx < enrolled.length)
          .map((idx) => enrolled[idx])
          .toList();
      if (orderedStudents.isEmpty) continue;

      if (!context.mounted) break;

      // ← Usamos un Completer para esperar que el usuario toque "RECLAMAR"
      final completer = Completer<void>();

      await Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => CategoryFightScreen(
          beltLevel: belt,
          playerStudents: orderedStudents,
          rivalFighters: rivalFighters,
          playerColor: AppColors.goldPrimary,
          rivalColor: rivalColor,
          playerTeamName: tournament.playerTeam?.name ?? '',
          rivalTeamName: rival.teamName,
          playerStrategies: strategies,
          onComplete: (result) {
            // Solo cuando el usuario toca "RECLAMAR" → cerramos
            Navigator.of(context).pop();
            completer.complete();
          },
        ),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ));

      // Esperar a que el usuario haya reclamado antes de pasar a la siguiente categoría
      await completer.future;
    }

    // Después de todos los combates del jugador → simular resultado completo
    if (!context.mounted) return;

    final result = await ref
        .read(tournamentProvider.notifier)
        .simulateNextMatch(
      playerFighters: _enrolledByBelt.values
          .expand((ids) => students.where((s) => ids.contains(s.id)))
          .toList(),
      playerStrategies: _strategiesByBelt.values
          .expand((s) => s)
          .toList(),
      enrolledByBelt: _enrolledByBelt,
    );

    ref
        .read(trainingViewModelProvider.notifier)
        .markTournamentDayComplete();

    setState(() => _isSimulating = false);

    if (result != null && context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MatchResultScreen(
          match: result,
          tournament: ref.read(tournamentProvider)!,
        ),
      ));
    }
  }
}