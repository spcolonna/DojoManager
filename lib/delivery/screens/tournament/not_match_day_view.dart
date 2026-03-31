import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../training/training_screen.dart';
import '../training/training_view_model.dart';

class NotMatchDayView extends ConsumerWidget {
  final Tournament tournament;
  final DayOfWeek tournamentDay;
  final TrainingState trainingState;

  const NotMatchDayView({super.key, 
    required this.tournament,
    required this.tournamentDay,
    required this.trainingState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = l10n(context);

    final notifier     = ref.read(tournamentProvider.notifier);
    final nextMatch    = notifier.nextPlayerMatch;
    final playerTeamId = tournament.playerTeam?.id ?? '';
    final isHome       = nextMatch?.homeTeamId == playerTeamId;
    final rivalTeamId  = isHome
        ? (nextMatch?.awayTeamId ?? '')
        : (nextMatch?.homeTeamId ?? '');
    final rivalList    = tournament.teams
        .where((t) => t.id == rivalTeamId)
        .toList();
    final rival        = rivalList.isEmpty ? null : rivalList.first;
    final rivalColor   =
        AppColors.colorByStyle[rival?.styleId ?? ''] ?? AppColors.redLight;

    final currentIdx    = DayOfWeek.values.indexOf(
        trainingState.currentDay ?? DayOfWeek.monday);
    final tournamentIdx = DayOfWeek.values.indexOf(tournamentDay);
    final daysLeft      = (tournamentIdx - currentIdx).clamp(0, 7);

    final dayName = switch (tournamentDay) {
      DayOfWeek.monday    => loc.dayMonday,
      DayOfWeek.tuesday   => loc.dayTuesday,
      DayOfWeek.wednesday => loc.dayWednesday,
      DayOfWeek.thursday  => loc.dayThursday,
      DayOfWeek.friday    => loc.dayFriday,
      DayOfWeek.saturday  => loc.daySaturday,
      DayOfWeek.sunday    => loc.daySunday,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Banner del próximo combate ──────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  rivalColor.withValues(alpha: 0.10),
                  AppColors.bgDeep,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: rivalColor.withValues(alpha: 0.35), width: 1.5),
            ),
            child: Column(
              children: [
                // Etiqueta tipo
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: rivalColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: rivalColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    loc.tournamentNextFight,
                    style: GoogleFonts.rajdhani(
                        fontSize: 9, fontWeight: FontWeight.w800,
                        color: rivalColor, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 16),

                // VS
                Row(
                  children: [
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
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.goldLight),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            loc.tournamentVs.toUpperCase(),
                            style: GoogleFonts.cinzelDecorative(
                                fontSize: 22, fontWeight: FontWeight.bold,
                                color: AppColors.redAction),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayName.toUpperCase(),
                            style: GoogleFonts.rajdhani(
                                fontSize: 10, fontWeight: FontWeight.w700,
                                color: AppColors.textTertiary,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: rivalColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: rivalColor.withValues(alpha: 0.5)),
                            ),
                            child: Icon(Icons.sports_mma_rounded,
                                color: rivalColor, size: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rival?.name ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: rivalColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Días que faltan
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.bgDivider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_bottom_rounded,
                          color: AppColors.textTertiary, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        daysLeft == 1
                            ? loc.tournamentTomorrow
                            : loc.tournamentDaysLeft(daysLeft),
                        style: GoogleFonts.rajdhani(
                            fontSize: 12, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Aviso de entrenamiento ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bgDivider),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textTertiary, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.tournamentAdvanceWarning,
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, color: AppColors.textTertiary,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Botón avanzar ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: trainingState.isSimulating
                  ? null
                  : () => ref
                  .read(trainingViewModelProvider.notifier)
                  .simulateWeek(context),
              icon: trainingState.isSimulating
                  ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.fast_forward_rounded, size: 18),
              label: Text(
                trainingState.isSimulating
                    ? loc.tournamentAdvancing
                    : loc.tournamentAdvanceButton,
                style: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: rivalColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}