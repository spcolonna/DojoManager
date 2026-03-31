import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/providers/tournament_provider.dart';
import 'match_preview_Card.dart';

class TournamentDayView extends ConsumerWidget {
  final String dayName;
  final dynamic loc;
  const TournamentDayView({required this.dayName, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournament = ref.watch(tournamentProvider);
    final nextMatch  = ref.read(tournamentProvider.notifier).nextPlayerMatch;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Header del día ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.redAction.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.redAction.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppColors.redLight, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayName,
                      style: GoogleFonts.cinzelDecorative(
                          fontSize: 18, fontWeight: FontWeight.bold,
                          color: AppColors.goldLight)),
                  Text(
                    loc.tournamentStyleLeague,
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (tournament == null || nextMatch == null) ...[
            // Sin torneo activo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bgDivider),
              ),
              child: Text(
                loc.trainingStopped,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
            ),
          ] else ...[
            // ── Partido del día ──────────────────────────────────
            MatchPreviewCard(
                tournament: tournament, nextMatch: nextMatch, loc: loc),
          ],

          const SizedBox(height: 16),

          // ── Botón ir al torneo ────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
              ref.read(navigationProvider.notifier).state = 2,
              icon: const Icon(Icons.emoji_events_rounded, size: 16),
              label: Text(
                loc.tournamentSimulateMatch,
                style: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redAction,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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