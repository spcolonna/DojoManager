import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/tournament_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/belt_helper.dart';
import '../../../../domain/entities/ai/ai_opponent.dart';
import '../../../../domain/entities/fight.dart';
import '../../../../domain/entities/student.dart';
import 'strategy_selector.dart';


class EnrollmentSection extends StatefulWidget {
  final List<Student> students;
  final AIOpponent rival;
  final Map<int, List<String>> enrolledByBelt;
  final Map<int, List<FightStrategy>> strategiesByBelt;
  final Map<int, List<int>> fightOrderByBelt;
  final void Function(
      Map<int, List<String>> enrolled,
      Map<int, List<FightStrategy>> strategies,
      Map<int, List<int>> fightOrder,
      ) onChanged;
  final dynamic loc;


  const EnrollmentSection({
    super.key,
    required this.students,
    required this.rival,
    required this.enrolledByBelt,
    required this.strategiesByBelt,
    required this.fightOrderByBelt,
    required this.onChanged,
    required this.loc,
  });

  @override
  State<EnrollmentSection> createState() => _EnrollmentSectionState();
}

class _EnrollmentSectionState extends State<EnrollmentSection> {
  late Map<int, List<String>> _enrolled;
  late Map<int, List<FightStrategy>> _strategies;
  late Map<int, List<int>> _fightOrder;

  @override
  void initState() {
    super.initState();
    _enrolled   = Map.from(widget.enrolledByBelt);
    _strategies = Map.from(widget.strategiesByBelt);
    _fightOrder = Map.from(widget.fightOrderByBelt);
  }

  // Estudiantes del jugador agrupados por faja
  Map<int, List<Student>> get _studentsByBelt {
    final map = <int, List<Student>>{};
    for (final s in widget.students) {
      map.putIfAbsent(s.belt.level, () => []).add(s);
    }
    return map;
  }

  // Fajas donde el jugador tiene estudiantes
  List<int> get _playerBelts =>
      _studentsByBelt.keys.toList()..sort();

  void _toggle(int beltLevel, String studentId) {
    setState(() {
      final current = List<String>.from(_enrolled[beltLevel] ?? []);
      if (current.contains(studentId)) {
        current.remove(studentId);
        final strats = List<FightStrategy>.from(_strategies[beltLevel] ?? []);
        if (strats.length > current.length) strats.removeLast();
        _strategies[beltLevel] = strats;
        _fightOrder[beltLevel] = List.generate(current.length, (i) => i);
      } else if (current.length < TournamentConfig.maxStudentsPerBeltPerTournament) {
        current.add(studentId);
        final strats = List<FightStrategy>.from(_strategies[beltLevel] ?? []);
        strats.add(FightStrategy.technical);
        _strategies[beltLevel] = strats;
        _fightOrder[beltLevel] = List.generate(current.length, (i) => i);
      }
      _enrolled[beltLevel] = current;
    });
    widget.onChanged(_enrolled, _strategies, _fightOrder);
  }

  void _swapOrder(int beltLevel) {
    setState(() {
      final order = List<int>.from(_fightOrder[beltLevel] ?? [0, 1]);
      if (order.length >= 2) {
        final tmp = order[0];
        order[0] = order[1];
        order[1] = tmp;
        _fightOrder[beltLevel] = order;
      }
    });
    widget.onChanged(_enrolled, _strategies, _fightOrder);
  }

  void _setStrategy(int beltLevel, int index, FightStrategy strategy) {
    setState(() {
      final strats = List<FightStrategy>.from(_strategies[beltLevel] ?? []);
      if (index < strats.length) strats[index] = strategy;
      _strategies[beltLevel] = strats;
    });
    widget.onChanged(_enrolled, _strategies, _fightOrder);
  }

  @override
  Widget build(BuildContext context) {
    final loc          = widget.loc;
    final playerBelts  = _playerBelts;
    final studentsByBelt = _studentsByBelt;

    if (playerBelts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bgDivider),
        ),
        child: Text(
          loc.tournamentNoStudents,
          style: GoogleFonts.rajdhani(
              fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: playerBelts.map((belt) {
        final beltStudents = studentsByBelt[belt] ?? [];
        final enrolledInBelt = _enrolled[belt] ?? [];
        final rivalFighters = widget.rival.fightersForBelt(belt);
        final beltColor = AppColors.beltColorByLevel[belt] ?? AppColors.beltWhite;
        final points = TournamentConfig.pointsByBelt[belt] ?? 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: beltColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // ── Header de categoría ──────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: beltColor.withValues(alpha: 0.08),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: beltColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      beltDisplayName('belt_${_beltKey(belt)}', loc)
                          .toUpperCase(),
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, fontWeight: FontWeight.w800,
                          color: beltColor, letterSpacing: 1.5),
                    ),
                    const Spacer(),
                    // Puntos en juego
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+$points pts',
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: AppColors.goldPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Inscriptos / max
                    Text(
                      '${enrolledInBelt.length}/${TournamentConfig.maxStudentsPerBeltPerTournament}',
                      style: GoogleFonts.rajdhani(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: enrolledInBelt.length >=
                              TournamentConfig.maxStudentsPerBeltPerTournament
                              ? AppColors.redLight
                              : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Info del rival en esta categoría
              if (rivalFighters.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.sports_mma_rounded,
                          color: AppColors.textTertiary, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.tournamentRivalPreview}: '
                            '${rivalFighters.length} fighter${rivalFighters.length > 1 ? 's' : ''}',
                        style: GoogleFonts.rajdhani(
                            fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),

              // ── Lista de estudiantes de esta faja ────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: beltStudents.map((student) {
                    final isSelected =
                    enrolledInBelt.contains(student.id);
                    final idx = enrolledInBelt.indexOf(student.id);
                    final styleColor =
                        AppColors.colorByStyle[student.styleId] ??
                            AppColors.goldPrimary;
                    final canSelect = !isSelected &&
                        enrolledInBelt.length >=
                            TournamentConfig.maxStudentsPerBeltPerTournament;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: canSelect || !student.canFight
                                ? null
                                : () => _toggle(belt, student.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? styleColor.withValues(alpha: 0.08)
                                    : AppColors.bgElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? styleColor
                                      : canSelect || !student.canFight
                                      ? AppColors.bgDivider
                                      .withValues(alpha: 0.3)
                                      : AppColors.bgDivider,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Checkbox
                                  Container(
                                    width: 20, height: 20,
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
                                        color: Colors.white, size: 12)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  // Avatar
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: styleColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person_rounded,
                                        color: styleColor, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.nameKey,
                                          style: GoogleFonts.rajdhani(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: canSelect ||
                                                !student.canFight
                                                ? AppColors.textDisabled
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        if (student.isInjured)
                                          Text(
                                            '⚠ ${loc.studentInjured}',
                                            style: GoogleFonts.rajdhani(
                                                fontSize: 10,
                                                color: AppColors.redLight),
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
                                          fontSize: 12,
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
                                            color: AppColors.textTertiary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Selector de estrategia
                          if (isSelected && idx >= 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 6, left: 28),
                              child: StrategySelector(
                                selected: idx < (_strategies[belt]?.length ?? 0)
                                    ? _strategies[belt]![idx]
                                    : FightStrategy.technical,
                                color: styleColor,
                                onChanged: (s) =>
                                    _setStrategy(belt, idx, s),
                                loc: loc,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (enrolledInBelt.length == 2) ...[
                const Divider(height: 1, color: AppColors.bgDivider),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: _FightOrderWidget(
                    students: beltStudents
                        .where((s) => enrolledInBelt.contains(s.id))
                        .toList(),
                    order: _fightOrder[belt] ?? [0, 1],
                    beltColor: beltColor,
                    onSwap: () => _swapOrder(belt),
                    loc: loc,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  String _beltKey(int level) => switch (level) {
    1 => 'white',   2 => 'yellow',    3 => 'orange',
    4 => 'green',   5 => 'blue',      6 => 'purple',
    7 => 'brown',   8 => 'red',       9 => 'red_black',
    10 => 'black',  _ => 'white',
  };
}

class _FightOrderWidget extends StatelessWidget {
  final List<Student> students;
  final List<int> order;
  final Color beltColor;
  final VoidCallback onSwap;
  final dynamic loc;

  const _FightOrderWidget({
    required this.students,
    required this.order,
    required this.beltColor,
    required this.onSwap,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    if (students.length < 2 || order.length < 2) return const SizedBox.shrink();
    final first  = order[0] < students.length ? students[order[0]] : students[0];
    final second = order[1] < students.length ? students[order[1]] : students[1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_list_numbered_rounded,
                color: beltColor, size: 12),
            const SizedBox(width: 6),
            Text(
              loc.tournamentFightOrder.toUpperCase(),
              style: GoogleFonts.rajdhani(
                  fontSize: 9, fontWeight: FontWeight.w800,
                  color: beltColor, letterSpacing: 1.5),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // 1er combate
            Expanded(
              child: _OrderSlot(
                  number: 1, name: first.nameKey, color: beltColor),
            ),
            // Botón swap
            GestureDetector(
              onTap: onSwap,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: beltColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: beltColor.withValues(alpha: 0.3)),
                ),
                child: Icon(Icons.swap_horiz_rounded,
                    color: beltColor, size: 16),
              ),
            ),
            // 2do combate
            Expanded(
              child: _OrderSlot(
                  number: 2, name: second.nameKey, color: beltColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 3er combate siempre es el ganador
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.bgDivider),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: AppColors.goldMuted, size: 12),
              const SizedBox(width: 6),
              Text(
                loc.tournamentFightOrderThird,
                style: GoogleFonts.rajdhani(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderSlot extends StatelessWidget {
  final int number;
  final String name;
  final Color color;

  const _OrderSlot({
    required this.number,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${number}º',
            style: GoogleFonts.cinzelDecorative(
                fontSize: 12, fontWeight: FontWeight.bold,
                color: color),
          ),
          Text(
            name,
            style: GoogleFonts.rajdhani(
                fontSize: 11, color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}