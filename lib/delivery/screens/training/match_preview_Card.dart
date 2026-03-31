import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class MatchPreviewCard extends StatelessWidget {
  final dynamic tournament;
  final dynamic nextMatch;
  final dynamic loc;
  const MatchPreviewCard({
    required this.tournament,
    required this.nextMatch,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final playerTeamId = tournament.playerTeam?.id ?? '';
    final isHome       = nextMatch.homeTeamId == playerTeamId;
    final rivalTeamId  = isHome ? nextMatch.awayTeamId : nextMatch.homeTeamId;
    final rivalList = (tournament.teams as List)
        .where((t) => t.id == rivalTeamId)
        .toList();
    final rivalTeam = rivalList.isEmpty ? null : rivalList.first;
    final rivalStyleColor =
        AppColors.colorByStyle[rivalTeam?.styleId ?? ''] ?? AppColors.redLight;

    // Posición del jugador en la tabla
    final playerPos = tournament.teams
        .indexWhere((t) => t.id == playerTeamId) +
        1;
    final playerList = (tournament.teams as List)
        .where((t) => t.id == playerTeamId)
        .toList();
    final playerTeam = playerList.isEmpty ? null : playerList.first;

    return Column(
      children: [
        // Banner VS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rivalStyleColor.withValues(alpha: 0.12),
                AppColors.bgDeep,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: rivalStyleColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              // Tu equipo
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                      ),
                      child: const Icon(Icons.home_work_rounded,
                          color: AppColors.goldLight, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tournament.playerTeam?.name ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.goldLight),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // VS
              Text(
                loc.tournamentVs.toUpperCase(),
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.redAction),
              ),
              // Rival
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: rivalStyleColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: rivalStyleColor.withValues(alpha: 0.5)),
                      ),
                      child: Icon(Icons.sports_mma_rounded,
                          color: rivalStyleColor, size: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rivalTeam?.name ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: rivalStyleColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Stats del rival + posición en la tabla
        Row(
          children: [
            // Tu posición
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bgDivider),
                ),
                child: Column(
                  children: [
                    Text(
                      '#$playerPos',
                      style: GoogleFonts.cinzelDecorative(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: playerPos <= 4
                              ? AppColors.goldPrimary
                              : AppColors.textSecondary),
                    ),
                    Text('Tu posición',
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, color: AppColors.textTertiary,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    if (playerTeam != null)
                      Text(
                        '${playerTeam.points} pts · ${playerTeam.wins}G ${playerTeam.draws}E ${playerTeam.losses}P',
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Rival posición
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: rivalStyleColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '#${tournament.teams.indexWhere((t) => t.id == rivalTeamId) + 1}',
                      style: GoogleFonts.cinzelDecorative(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: rivalStyleColor),
                    ),
                    Text('Rival',
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, color: AppColors.textTertiary,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    if (rivalTeam != null)
                      Text(
                        '${rivalTeam.points} pts · ${rivalTeam.wins}G ${rivalTeam.draws}E ${rivalTeam.losses}P',
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Fecha del partido
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.bgDivider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppColors.textTertiary, size: 12),
              const SizedBox(width: 6),
              Text(
                loc.tournamentRound(nextMatch.round),
                style: GoogleFonts.rajdhani(
                    fontSize: 12, color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}