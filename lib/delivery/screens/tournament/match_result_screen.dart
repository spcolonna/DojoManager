import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../../../domain/entities/tournament/tournament_match.dart';
import '../../../domain/entities/tournament/tournament_team.dart';
import '../../widgets/animations/staggered_list.dart';

class MatchResultScreen extends StatefulWidget {
  final TournamentMatch match;
  final Tournament tournament;

  const MatchResultScreen({
    super.key,
    required this.match,
    required this.tournament,
  });

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.elasticOut),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc          = l10n(context);
    final playerTeamId = widget.tournament.playerTeam?.id ?? '';
    final isHome       = widget.match.homeTeamId == playerTeamId;
    final playerWon    =
        widget.match.result == MatchResult.homeWin && isHome ||
            widget.match.result == MatchResult.awayWin && !isHome;
    final isDraw       = widget.match.result == MatchResult.draw;

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

    final rivalTeamId = isHome
        ? widget.match.awayTeamId
        : widget.match.homeTeamId;
    final rivalTeam   = widget.tournament.teams.firstWhere(
          (t) => t.id == rivalTeamId,
      orElse: () => const TournamentTeam(
          id: '', name: 'Unknown', styleId: '', isPlayer: false),
    );

    final playerFightWins = widget.match.fights
        .where((f) => f.winnerId == playerTeamId)
        .length;
    final rivalFightWins  =
        widget.match.fights.length - playerFightWins;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ── Resultado principal ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    resultColor.withOpacity(0.2),
                    AppColors.bgDeep,
                  ],
                ),
              ),
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: resultColor.withOpacity(0.5), width: 2),
                      ),
                      child: Icon(
                        isDraw
                            ? Icons.handshake_rounded
                            : playerWon
                            ? Icons.emoji_events_rounded
                            : Icons.sports_mma_rounded,
                        color: resultColor, size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      resultLabel,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'vs ${rivalTeam.name}',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Score de combates
                    Text(
                      '$playerFightWins - $rivalFightWins',
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                    ),
                    Text(
                      'fights',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Detalle de los combates ─────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StaggeredList(
                  children: widget.match.fights.asMap().entries.map((e) {
                    final fight = e.value;
                    final won   = fight.winnerId == playerTeamId;
                    final color = won ? AppColors.success : AppColors.redAction;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                won
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                color: color, size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.tournamentFight(e.key + 1),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${fight.homeScore} - ${fight.awayScore}',
                              style: GoogleFonts.rajdhani(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Botón volver ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: resultColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}