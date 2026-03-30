import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../core/config/tournament_config.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/fight_fighter.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/fight.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../fight/fight_arena_screen.dart';
import '../training/training_view_model.dart';
import 'match_result_screen.dart';

class NextMatchTab extends ConsumerStatefulWidget {
  final Tournament tournament;
  const NextMatchTab({super.key, required this.tournament});

  @override
  ConsumerState<NextMatchTab> createState() => _NextMatchTabState();
}

class _NextMatchTabState extends ConsumerState<NextMatchTab> {
  List<String> _enrolledIds = [];
  List<FightStrategy> _strategies = [];
  final bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    final loc        = l10n(context);
    final tournament = widget.tournament;
    final nextMatch  = ref.read(tournamentProvider.notifier).nextPlayerMatch;
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

    final playerTeamId = tournament.playerTeam?.id ?? '';
    final isHome       = nextMatch.homeTeamId == playerTeamId;
    final rivalTeamId  = isHome ? nextMatch.awayTeamId : nextMatch.homeTeamId;
    final rivalTeam    = tournament.teams
        .where((t) => t.id == rivalTeamId)
        .firstOrNull;
    final rival = ref.read(tournamentProvider.notifier).rivalFor(rivalTeamId);
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
                                color: AppColors.goldPrimary.withValues(alpha: 0.15),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.goldLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // VS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          loc.tournamentVs.toUpperCase(),
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                                border: Border.all(color: rivalStyleColor.withValues(alpha: 0.5)),
                              ),
                              child: Icon(Icons.sports_mma_rounded,
                                  color: rivalStyleColor, size: 26),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rivalTeam?.name ?? '',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
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
              _RivalScout(rival: rival, loc: loc),

            const SizedBox(height: 16),

            // ── Inscripción de estudiantes ───────────────────────────
            _EnrollmentSection(
              students: students,
              enrolledIds: _enrolledIds,
              strategies: _strategies,
              onChanged: (ids, strats) => setState(() {
                _enrolledIds = ids;
                _strategies  = strats;
              }),
              loc: loc,
            ),

            const SizedBox(height: 20),

            // ── Botón simular ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _enrolledIds.isEmpty || _isSimulating
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
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
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

  Future<void> _simulate(BuildContext context, List<Student> students) async {
    final enrolled = students
        .where((s) => _enrolledIds.contains(s.id))
        .toList();

    if (enrolled.isEmpty) return;

    final tournament   = ref.read(tournamentProvider)!;
    final playerTeamId = tournament.playerTeam?.id ?? '';
    final nextMatch    = ref.read(tournamentProvider.notifier).nextPlayerMatch;
    if (nextMatch == null) return;

    final isHome     = nextMatch.homeTeamId == playerTeamId;
    final rivalTeamId = isHome ? nextMatch.awayTeamId : nextMatch.homeTeamId;
    final rival      = ref.read(tournamentProvider.notifier).rivalFor(rivalTeamId);
    if (rival == null || rival.fighters.isEmpty) return;

    final blueFighter  = FightFighter.fromStudent(enrolled.first);
    final redFighter   = FightFighter.fromAI(rival.fighters.first);
    final rivalColor   = AppColors.colorByStyle[rival.styleId] ?? AppColors.redLight;

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => FightArenaScreen(
        blueFighter: blueFighter,
        redFighter: redFighter,
        blueTeamId: playerTeamId,
        redTeamId: rivalTeamId,
        blueColor: AppColors.goldPrimary,
        redColor: rivalColor,
        blueName: enrolled.first.nameKey,
        redName: rival.teamName,
        initialStrategy: _strategies.isNotEmpty
            ? _strategies.first
            : FightStrategy.technical,
        onComplete: (blueWins, redWins) async {
          Navigator.of(context).pop();
          final result = await ref
              .read(tournamentProvider.notifier)
              .simulateNextMatch(
            playerFighters: enrolled,
            playerStrategies: _strategies,
          );

          ref.read(trainingViewModelProvider.notifier).markTournamentDayComplete();
          
          if (result != null && context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MatchResultScreen(
                match: result,
                tournament: ref.read(tournamentProvider)!,
              ),
            ));
          }
        },
      ),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }
}

// ─── SCOUT DEL RIVAL ─────────────────────────────────────────────────────────

class _RivalScout extends StatelessWidget {
  final dynamic rival;
  final dynamic loc;
  const _RivalScout({required this.rival, required this.loc});

  @override
  Widget build(BuildContext context) {
    final styleColor =
        AppColors.colorByStyle[rival.styleId] ?? AppColors.redLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.manage_search_rounded,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                loc.tournamentRivalPreview.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: styleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border:
                  Border.all(color: styleColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  styleDisplayName(rival.styleId, loc),
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: styleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${rival.fighters.length} fighters',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats promedio del rival
          if (rival.fighters.isNotEmpty) ...[
            Text(
              loc.tournamentRivalStrength.toUpperCase(),
              style: GoogleFonts.rajdhani(
                fontSize: 9,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            _AvgStatBar('STR', rival.fighters, 'str', AppColors.branchPower),
            _AvgStatBar('SPD', rival.fighters, 'spd', AppColors.branchAgility),
            _AvgStatBar('TEC', rival.fighters, 'tec', AppColors.branchTechnique),
            _AvgStatBar('DEF', rival.fighters, 'def', AppColors.branchGuard),
            _AvgStatBar('MEN', rival.fighters, 'men', AppColors.branchMind),
          ],
        ],
      ),
    );
  }
}

class _AvgStatBar extends StatelessWidget {
  final String label;
  final List fighters;
  final String statKey;
  final Color color;

  const _AvgStatBar(this.label, this.fighters, this.statKey, this.color);

  @override
  Widget build(BuildContext context) {
    final avg = fighters.isEmpty
        ? 0.0
        : fighters
        .map((f) => (f.stats.toMap()[statKey] ?? 0) as int)
        .reduce((a, b) => a + b) /
        fighters.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(label,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                )),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (avg / 40).clamp(0, 1),
                minHeight: 5,
                backgroundColor: AppColors.bgDivider,
                valueColor: AlwaysStoppedAnimation<Color>(
                    color.withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            avg.toStringAsFixed(0),
            style: GoogleFonts.rajdhani(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INSCRIPCIÓN ──────────────────────────────────────────────────────────────

class _EnrollmentSection extends StatefulWidget {
  final List<Student> students;
  final List<String> enrolledIds;
  final List<FightStrategy> strategies;
  final void Function(List<String>, List<FightStrategy>) onChanged;
  final dynamic loc;

  const _EnrollmentSection({
    required this.students,
    required this.enrolledIds,
    required this.strategies,
    required this.onChanged,
    required this.loc,
  });

  @override
  State<_EnrollmentSection> createState() => _EnrollmentSectionState();
}

class _EnrollmentSectionState extends State<_EnrollmentSection> {
  late List<String> _selected;
  late List<FightStrategy> _strats;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.enrolledIds);
    _strats   = List.from(widget.strategies);
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        _strats = _strats.take(_selected.length).toList();
      } else if (_selected.length < TournamentConfig.maxStudentsPerBeltPerTournament) {
        _selected.add(id);
        _strats.add(FightStrategy.technical); // estrategia por defecto
      }
    });
    widget.onChanged(_selected, _strats);
  }

  void _setStrategy(int index, FightStrategy strategy) {
    setState(() {
      if (index < _strats.length) {
        _strats[index] = strategy;
      }
    });
    widget.onChanged(_selected, _strats);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                loc.tournamentEnrollTitle.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                '${_selected.length}/${TournamentConfig.maxStudentsPerBeltPerTournament}',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _selected.length >=
                      TournamentConfig.maxStudentsPerBeltPerTournament
                      ? AppColors.redLight
                      : AppColors.goldPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...widget.students.map((student) {
            final isSelected = _selected.contains(student.id);
            final idx        = _selected.indexOf(student.id);
            final styleColor = AppColors.colorByStyle[student.styleId] ??
                AppColors.goldPrimary;
            final beltColor  =
                AppColors.beltColorByLevel[student.belt.level] ??
                    AppColors.beltWhite;
            final canSelect = !isSelected &&
                _selected.length >=
                    TournamentConfig.maxStudentsPerBeltPerTournament;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  // Card del estudiante
                  GestureDetector(
                    onTap: canSelect || !student.canFight
                        ? null
                        : () => _toggle(student.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? styleColor.withValues(alpha: 0.08)
                            : AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? styleColor
                              : canSelect || !student.canFight
                              ? AppColors.bgDivider.withValues(alpha: 0.4)
                              : AppColors.bgDivider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Checkbox visual
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? styleColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? styleColor
                                    : AppColors.bgDivider,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 14)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          // Avatar
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: styleColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_rounded,
                                color: styleColor, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.nameKey,
                                    style: GoogleFonts.rajdhani(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: canSelect || !student.canFight
                                          ? AppColors.textDisabled
                                          : AppColors.textPrimary,
                                    )),
                                Row(
                                  children: [
                                    Container(
                                      width: 7, height: 7,
                                      decoration: BoxDecoration(
                                          color: beltColor,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      beltDisplayName(
                                          student.belt.titleKey, loc),
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 11,
                                        color: beltColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (student.isInjured) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '⚠ ${loc.studentInjured}',
                                        style: GoogleFonts.rajdhani(
                                          fontSize: 10,
                                          color: AppColors.redLight,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Fatiga
                          Column(
                            children: [
                              Text(
                                '${student.fatiguePercent}%',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: student.fatiguePercent > 60
                                      ? AppColors.warning
                                      : AppColors.textTertiary,
                                ),
                              ),
                              Text(
                                'fatigue',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 9,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selector de estrategia (solo si está inscripto)
                  if (isSelected && idx >= 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 32),
                      child: _StrategySelector(
                        selected: idx < _strats.length
                            ? _strats[idx]
                            : FightStrategy.technical,
                        color: styleColor,
                        onChanged: (s) => _setStrategy(idx, s),
                        loc: loc,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StrategySelector extends StatelessWidget {
  final FightStrategy selected;
  final Color color;
  final void Function(FightStrategy) onChanged;
  final dynamic loc;

  const _StrategySelector({
    required this.selected,
    required this.color,
    required this.onChanged,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FightStrategy.values.map((s) {
          final isSelected = s == selected;
          final label = switch (s) {
            FightStrategy.aggressive => loc.strategyAggressive,
            FightStrategy.defensive  => loc.strategyDefensive,
            FightStrategy.technical  => loc.strategyTechnical,
            FightStrategy.grappling  => loc.strategyGrappling,
            FightStrategy.adaptive   => loc.strategyAdaptive,
          };
          final sColor = switch (s) {
            FightStrategy.aggressive => AppColors.redLight,
            FightStrategy.defensive  => AppColors.info,
            FightStrategy.technical  => AppColors.goldPrimary,
            FightStrategy.grappling  => AppColors.orange,
            FightStrategy.adaptive   => AppColors.success,
          };

          return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? sColor.withValues(alpha: 0.15)
                    : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? sColor : AppColors.bgDivider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? sColor : AppColors.textTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}