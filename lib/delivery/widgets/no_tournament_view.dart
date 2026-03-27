import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/l10n_helper.dart';
import '../../core/utils/belt_helper.dart';
import '../../core/providers/dojo_provider.dart';
import '../../core/providers/tournament_provider.dart';

class NoTournamentView extends ConsumerWidget {
  const NoTournamentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc       = l10n(context);
    final dojoAsync = ref.watch(dojoProvider);

    return dojoAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (dojo) {
        if (dojo == null) return const SizedBox.shrink();

        final hasPendingInvite = dojo.currentWeek == 1;
        final styleColor =
            AppColors.colorByStyle[dojo.styleId] ?? AppColors.goldPrimary;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.redAction.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.redAction.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.redLight, size: 40),
                ),
                const SizedBox(height: 20),

                Text(
                  loc.tournamentNoActive,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.tournamentInviteMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Semana actual
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bgDivider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textTertiary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        loc.tournamentSeasonWeek(
                            dojo.currentSeason, dojo.currentWeek),
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Si es semana 1 → mostrar invitación pendiente
                if (hasPendingInvite) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: styleColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: styleColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mail_rounded,
                                color: styleColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              loc.tournamentInvitePending,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: styleColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.tournamentInviteLeagueBody(
                            styleDisplayName(dojo.styleId, loc),
                            dojo.currentSeason,
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(tournamentProvider.notifier)
                                .initLeague(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: styleColor,
                              foregroundColor: Colors.black,
                              padding:
                              const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              loc.tournamentInviteAccept,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}