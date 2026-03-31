import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/weekly_plan.dart';

class WeekCalendar extends StatelessWidget {
  final WeeklyPlan plan;
  final DayOfWeek? selectedDay;
  final DayOfWeek? currentDay;
  final void Function(DayOfWeek) onDayTap;

  const WeekCalendar({
    required this.plan,
    required this.selectedDay,
    required this.currentDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return Container(
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: DayOfWeek.values.map((day) {
          final dayPlan      = plan.days[day]!;
          final isSelected   = day == selectedDay;
          final isSimulated  = dayPlan.isSimulated;
          final isCurrentDay = day == currentDay;

          final color = switch (dayPlan.type) {
            DayType.training   => dayPlan.hasActivities
                ? AppColors.success
                : AppColors.textTertiary,
            DayType.rest       => AppColors.info,
            DayType.tournament => AppColors.redAction,
          };

          final shortLabel = switch (day) {
            DayOfWeek.monday    => loc.dayMon,
            DayOfWeek.tuesday   => loc.dayTue,
            DayOfWeek.wednesday => loc.dayWed,
            DayOfWeek.thursday  => loc.dayThu,
            DayOfWeek.friday    => loc.dayFri,
            DayOfWeek.saturday  => loc.daySat,
            DayOfWeek.sunday    => loc.daySun,
          };

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(day),
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Indicador de tipo / día actual ──────────────
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isCurrentDay && !isSimulated)
                          Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: isSimulated
                                ? AppColors.success
                                : isCurrentDay
                                ? AppColors.goldPrimary
                                : color.withValues(alpha:
                            dayPlan.hasActivities ? 1.0 : 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortLabel,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isSelected ? color : AppColors.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // ── Etiqueta NEXT ────────────────────────────────
                    if (isCurrentDay && !isSimulated)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.rajdhani(
                            fontSize: 7,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bgDeep,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 3),
                    // ── Ícono del tipo de día ────────────────────────
                    Icon(
                      switch (dayPlan.type) {
                        DayType.training   => AppIcons.trainingStrength,
                        DayType.rest       => Icons.hotel_rounded,
                        DayType.tournament => AppIcons.fightWin,
                      },
                      size: 14,
                      color: isSelected ? color : AppColors.textTertiary,
                    ),
                    // ── Número de actividades ────────────────────────
                    if (dayPlan.type == DayType.training &&
                        dayPlan.hasActivities) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${dayPlan.activityIds.length}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 9,
                          color: isSelected ? color : AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}