import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../../../domain/entities/tournament/tournament_team.dart';

class ResultsTab extends StatelessWidget {
  final Tournament tournament;
  const ResultsTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    final loc       = l10n(context);
    final playerTeamId = tournament.playerTeam?.id ?? '';

    final playedMatches = tournament.matches
        .where((m) => m.isPlayed &&
        (m.homeTeamId == playerTeamId ||
            m.awayTeamId == playerTeamId))
        .toList()
      ..sort((a, b) => b.round.compareTo(a.round));

    if (playedMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded,
                color: AppColors.textTertiary, size: 40),
            const SizedBox(height: 12),
            Text(loc.tournamentNoResults,
                style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: playedMatches.length,
      itemBuilder: (_, i) {
        final match      = playedMatches[i];
        final isHome     = match.homeTeamId == playerTeamId;
        final playerWon  = match.result == MatchResult.homeWin && isHome ||
            match.result == MatchResult.awayWin && !isHome;
        final isDraw     = match.result == MatchResult.draw;

        final rivalTeam  = tournament.teams.firstWhere(
              (t) => t.id == (isHome ? match.awayTeamId : match.homeTeamId),
          orElse: () => const TournamentTeam(
              id: '', name: 'Unknown', styleId: '', isPlayer: false),
        );

        final playerScore = isHome ? match.homePoints : match.awayPoints;
        final rivalScore  = isHome ? match.awayPoints : match.homePoints;

        final resultColor = isDraw
            ? AppColors.info
            : playerWon
            ? AppColors.success
            : AppColors.redAction;
        final resultLabel = isDraw
            ? loc.tournamentDraw
            : playerWon
            ? loc.tournamentWin
            : loc.tournamentLoss;

        // Conteo de combates ganados
        final playerFightWins = match.fights
            .where((f) => f.winnerId == playerTeamId)
            .length;
        final rivalFightWins = match.fights.length - playerFightWins;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: resultColor.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Badge resultado
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resultLabel,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: resultColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    loc.tournamentRound(match.round),
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  // Score de combates
                  Text(
                    loc.tournamentFightsWon(
                        playerFightWins, rivalFightWins),
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Rival
              Row(
                children: [
                  const Icon(Icons.sports_mma_rounded,
                      color: AppColors.textTertiary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    rivalTeam.name,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$playerScore - $rivalScore pts',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              // Detalle de combates individuales
              if (match.fights.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.bgDivider),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: match.fights.asMap().entries.map((e) {
                    final fight  = e.value;
                    final won    = fight.winnerId == playerTeamId;
                    final color  = won ? AppColors.success : AppColors.redAction;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            loc.tournamentFight(e.key + 1),
                            style: GoogleFonts.rajdhani(
                              fontSize: 9,
                              color: AppColors.textTertiary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${fight.homeScore}-${fight.awayScore}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                          Icon(
                            won ? Icons.check_rounded : Icons.close_rounded,
                            color: color, size: 12,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}