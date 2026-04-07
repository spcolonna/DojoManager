import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/tournament_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../domain/entities/fight.dart';
import '../../../domain/entities/fight_fighter.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/ai/aI_student.dart';
import 'fight_arena_screen.dart';

class CategoryFightResult {
  final int beltLevel;
  final bool playerWon;
  final int playerFights;
  final int rivalFights;
  final int pointsEarned;

  const CategoryFightResult({
    required this.beltLevel,
    required this.playerWon,
    required this.playerFights,
    required this.rivalFights,
    required this.pointsEarned,
  });
}

class CategoryFightScreen extends StatefulWidget {
  final int beltLevel;
  final List<Student> playerStudents;
  final List<AIStudent> rivalFighters;
  final Color playerColor;
  final Color rivalColor;
  final String playerTeamName;
  final String rivalTeamName;
  final List<FightStrategy> playerStrategies;
  final void Function(CategoryFightResult result) onComplete;

  const CategoryFightScreen({
    super.key,
    required this.beltLevel,
    required this.playerStudents,
    required this.rivalFighters,
    required this.playerColor,
    required this.rivalColor,
    required this.playerTeamName,
    required this.rivalTeamName,
    required this.playerStrategies,
    required this.onComplete,
  });

  @override
  State<CategoryFightScreen> createState() => _CategoryFightScreenState();
}

class _CategoryFightScreenState extends State<CategoryFightScreen> {
  int _fightNumber = 1;
  int _playerWins  = 0;
  int _rivalWins   = 0;
  bool _showingBetween = false;
  bool _finished = false;
  bool _resultClaimed = false;
  int? _previousWinnerIdx;

  Student get _currentPlayer {
    if (_fightNumber == 1) return widget.playerStudents[0];
    if (_fightNumber == 2) return widget.playerStudents.length > 1
        ? widget.playerStudents[1]
        : widget.playerStudents[0];
    if (_previousWinnerIdx != null &&
        _previousWinnerIdx! < widget.playerStudents.length) {
      return widget.playerStudents[_previousWinnerIdx!];
    }
    return widget.playerStudents[0];
  }

  AIStudent get _currentRival {
    final idx = (_fightNumber - 1).clamp(0, widget.rivalFighters.length - 1);
    return widget.rivalFighters[idx];
  }

  FightStrategy get _currentStrategy {
    final idx = (_fightNumber - 1).clamp(0, widget.playerStrategies.length - 1);
    return widget.playerStrategies.isNotEmpty
        ? widget.playerStrategies[idx]
        : FightStrategy.technical;
  }

  void _onFightComplete(int blueWins, int redWins) {
    final playerWonThis = blueWins > redWins;
    if (playerWonThis) {
      _previousWinnerIdx = _fightNumber == 1 ? 0 : 1;
      _playerWins++;
    } else {
      _rivalWins++;
    }

    final isDone = _playerWins >= 2 || _rivalWins >= 2 || _fightNumber >= 3;

    setState(() {
      _showingBetween = !isDone;
      _finished = isDone;
    });
  }

  void _startNextFight() {
    setState(() {
      _fightNumber++;
      _showingBetween = false;
    });
  }

  void _claimAndContinue() {
    if (_resultClaimed) return;
    setState(() => _resultClaimed = true);
    final points = _playerWins > _rivalWins
        ? TournamentConfig.pointsByBelt[widget.beltLevel] ?? 3
        : 0;
    widget.onComplete(CategoryFightResult(
      beltLevel: widget.beltLevel,
      playerWon: _playerWins > _rivalWins,
      playerFights: _playerWins,
      rivalFights: _rivalWins,
      pointsEarned: points,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    if (_showingBetween) {
      return _BetweenFightsScreen(
        fightNumber: _fightNumber,
        playerWins: _playerWins,
        rivalWins: _rivalWins,
        playerTeamName: widget.playerTeamName,
        rivalTeamName: widget.rivalTeamName,
        playerColor: widget.playerColor,
        rivalColor: widget.rivalColor,
        nextPlayerName: _fightNumber < 3
            ? _currentPlayer.nameKey
            : loc.tournamentNextFighter,
        onContinue: _startNextFight,
        loc: loc,
      );
    }

    if (_finished) {
      return _CategoryResultScreen(
        playerWon: _playerWins > _rivalWins,
        playerWins: _playerWins,
        rivalWins: _rivalWins,
        beltLevel: widget.beltLevel,
        playerColor: widget.playerColor,
        rivalColor: widget.rivalColor,
        playerTeamName: widget.playerTeamName,
        rivalTeamName: widget.rivalTeamName,
        onClaim: _claimAndContinue,
        loc: loc,
      );
    }

    return FightArenaScreen(
      blueFighter: FightFighter.fromStudent(_currentPlayer),
      redFighter: FightFighter.fromAI(_currentRival),
      blueTeamId: widget.playerTeamName,
      redTeamId: widget.rivalTeamName,
      blueColor: widget.playerColor,
      redColor: widget.rivalColor,
      blueName: _currentPlayer.nameKey,
      redName: _currentRival.name,
      initialStrategy: _currentStrategy,
      fightNumber: _fightNumber,
      totalFights: 3,
      playerWinsSoFar: _playerWins,
      rivalWinsSoFar: _rivalWins,
      onComplete: _onFightComplete,
    );
  }
}

// ─── ENTRE COMBATES ───────────────────────────────────────────────────────────

class _BetweenFightsScreen extends StatelessWidget {
  final int fightNumber;
  final int playerWins, rivalWins;
  final String playerTeamName, rivalTeamName, nextPlayerName;
  final Color playerColor, rivalColor;
  final VoidCallback onContinue;
  final dynamic loc;

  const _BetweenFightsScreen({
    required this.fightNumber,
    required this.playerWins, required this.rivalWins,
    required this.playerTeamName, required this.rivalTeamName,
    required this.nextPlayerName,
    required this.playerColor, required this.rivalColor,
    required this.onContinue, required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.tournamentFightNumber(fightNumber),
                  style: GoogleFonts.rajdhani(
                      fontSize: 12, color: AppColors.textTertiary,
                      letterSpacing: 2, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                // Marcador visual
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        _WinDot(wins: playerWins, color: playerColor),
                        const SizedBox(height: 6),
                        Text(playerTeamName,
                          style: GoogleFonts.rajdhani(
                              fontSize: 11, color: playerColor,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$playerWins - $rivalWins',
                        style: GoogleFonts.cinzelDecorative(
                            fontSize: 32, fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Column(
                      children: [
                        _WinDot(wins: rivalWins, color: rivalColor),
                        const SizedBox(height: 6),
                        Text(rivalTeamName,
                          style: GoogleFonts.rajdhani(
                              fontSize: 11, color: rivalColor,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                      const Icon(Icons.person_rounded,
                          color: AppColors.textTertiary, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        '${loc.tournamentNextFighter}: $nextPlayerName',
                        style: GoogleFonts.rajdhani(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redAction,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    loc.tournamentNextFighter,
                    style: GoogleFonts.rajdhani(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WinDot extends StatelessWidget {
  final int wins;
  final Color color;
  const _WinDot({required this.wins, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 16, height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i < wins ? color : Colors.transparent,
          border: Border.all(color: color, width: 2),
          boxShadow: i < wins ? [BoxShadow(color: color, blurRadius: 8)] : null,
        ),
      )),
    );
  }
}

// ─── RESULTADO FINAL DE CATEGORÍA ─────────────────────────────────────────────

class _CategoryResultScreen extends StatelessWidget {
  final bool playerWon;
  final int playerWins, rivalWins, beltLevel;
  final Color playerColor, rivalColor;
  final String playerTeamName, rivalTeamName;
  final VoidCallback onClaim;
  final dynamic loc;

  const _CategoryResultScreen({
    required this.playerWon,
    required this.playerWins, required this.rivalWins,
    required this.beltLevel,
    required this.playerColor, required this.rivalColor,
    required this.playerTeamName, required this.rivalTeamName,
    required this.onClaim,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor  = playerWon ? AppColors.goldPrimary : rivalColor;
    final points       = playerWon
        ? TournamentConfig.pointsByBelt[beltLevel] ?? 3
        : 0;
    final beltName     = beltDisplayName('belt_${_beltKey(beltLevel)}', loc);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Categoría
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: resultColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    beltName.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: resultColor, letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Resultado
                Text(
                  playerWon ? 'VICTORIA' : 'DERROTA',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 44, fontWeight: FontWeight.bold,
                    color: resultColor,
                    shadows: [Shadow(color: resultColor, blurRadius: 30)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$playerWins - $rivalWins',
                  style: GoogleFonts.cinzelDecorative(
                      fontSize: 36, color: Colors.white),
                ),
                Text(
                  'combates',
                  style: GoogleFonts.rajdhani(
                      fontSize: 11, color: AppColors.textTertiary,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 32),

                // Recompensa
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: playerWon
                        ? AppColors.goldPrimary.withValues(alpha: 0.08)
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: playerWon
                          ? AppColors.goldPrimary.withValues(alpha: 0.4)
                          : AppColors.bgDivider,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        playerWon ? 'RECOMPENSA' : 'SIN PUNTOS',
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: playerWon
                                ? AppColors.goldPrimary
                                : AppColors.textTertiary,
                            letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 8),
                      if (playerWon) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                color: AppColors.goldPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '+$points pts en $beltName',
                              style: GoogleFonts.cinzelDecorative(
                                  fontSize: 16, fontWeight: FontWeight.bold,
                                  color: AppColors.goldPrimary),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Seguí entrenando para la próxima fecha',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                              fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón reclamar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: resultColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      playerWon ? 'RECLAMAR PUNTOS' : 'CONTINUAR',
                      style: GoogleFonts.cinzelDecorative(
                          fontSize: 13, fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _beltKey(int level) => switch (level) {
    1 => 'white',   2 => 'yellow', 3 => 'orange',
    4 => 'green',   5 => 'blue',   6 => 'purple',
    7 => 'brown',   8 => 'red',    9 => 'red_black',
    10 => 'black',  _ => 'white',
  };
}