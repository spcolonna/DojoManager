import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/tournament/tournament.dart';

class StandingsTab extends StatelessWidget {
  final Tournament tournament;
  const StandingsTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final loc   = l10n(context);
    final teams = tournament.teams; // ya vienen ordenados

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header de columnas
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Text('TEAM',
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 1,
                      )),
                ),
                ...[
                  loc.tournamentPlayed,
                  loc.tournamentWins,
                  loc.tournamentDraws,
                  loc.tournamentLosses,
                  loc.tournamentGoalDiff,
                  loc.tournamentPoints,
                ].map((h) => SizedBox(
                  width: 28,
                  child: Text(h,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.5,
                      )),
                )),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Filas
          ...List.generate(teams.length, (i) {
            final team      = teams[i];
            final isPlayer  = team.isPlayer;
            final pos       = i + 1;
            final posColor  = pos == 1
                ? AppColors.goldPrimary
                : pos == 2
                ? AppColors.textSecondary
                : AppColors.textTertiary;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isPlayer
                    ? AppColors.goldPrimary.withValues(alpha: 0.07)
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isPlayer
                      ? AppColors.goldPrimary.withValues(alpha: 0.3)
                      : AppColors.bgDivider,
                  width: isPlayer ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Posición
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$pos',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: posColor,
                      ),
                    ),
                  ),
                  // Nombre
                  Expanded(
                    child: Row(
                      children: [
                        if (isPlayer)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.star_rounded,
                                color: AppColors.goldPrimary, size: 12),
                          ),
                        Flexible(
                          child: Text(
                            team.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: isPlayer
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isPlayer
                                  ? AppColors.goldLight
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats
                  ...[
                    team.matchesPlayed,
                    team.wins,
                    team.draws,
                    team.losses,
                    team.goalDifference,
                    team.points,
                  ].asMap().entries.map((e) {
                    final isLast    = e.key == 5;
                    final val       = e.value;
                    final textColor = isLast
                        ? (isPlayer
                        ? AppColors.goldPrimary
                        : AppColors.textPrimary)
                        : AppColors.textSecondary;

                    return SizedBox(
                      width: 28,
                      child: Text(
                        val >= 0 ? '$val' : '$val',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight:
                          isLast ? FontWeight.w800 : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),

          const SizedBox(height: 16),

          // Leyenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.goldPrimary, size: 12),
              const SizedBox(width: 4),
              Text(
                'Your team',
                style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}