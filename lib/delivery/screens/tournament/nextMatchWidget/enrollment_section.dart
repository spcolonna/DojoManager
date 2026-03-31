import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/tournament/nextMatchWidget/strategy_selector.dart';

import '../../../../core/config/tournament_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/belt_helper.dart';
import '../../../../domain/entities/fight.dart';
import '../../../../domain/entities/student.dart';

class EnrollmentSection extends StatefulWidget {
  final List<Student> students;
  final List<String> enrolledIds;
  final List<FightStrategy> strategies;
  final void Function(List<String>, List<FightStrategy>) onChanged;
  final dynamic loc;

  const EnrollmentSection({super.key, 
    required this.students,
    required this.enrolledIds,
    required this.strategies,
    required this.onChanged,
    required this.loc,
  });

  @override
  State<EnrollmentSection> createState() => _EnrollmentSectionState();
}

class _EnrollmentSectionState extends State<EnrollmentSection> {
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
                      child: StrategySelector(
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