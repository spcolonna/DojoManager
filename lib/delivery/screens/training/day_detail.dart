import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grand_dojo/delivery/screens/training/rest_day_view.dart';
import 'package:grand_dojo/delivery/screens/training/tournament_day_view.dart';
import 'package:grand_dojo/delivery/screens/training/training_day_view.dart';
import 'package:grand_dojo/delivery/screens/training/training_view_model.dart';

import '../../../core/utils/l10n_helper.dart';
import '../../../domain/day_plan.dart';
import '../../../domain/entities/weekly_plan.dart';
import 'activity_picker_sheet.dart';

class DayDetail extends ConsumerWidget {
  final DayOfWeek day;
  final DayPlan plan;
  final bool isSimulated;

  const DayDetail({
    required this.day,
    required this.plan,
    required this.isSimulated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = l10n(context);

    final dayName = switch (day) {
      DayOfWeek.monday    => loc.dayMonday,
      DayOfWeek.tuesday   => loc.dayTuesday,
      DayOfWeek.wednesday => loc.dayWednesday,
      DayOfWeek.thursday  => loc.dayThursday,
      DayOfWeek.friday    => loc.dayFriday,
      DayOfWeek.saturday  => loc.daySaturday,
      DayOfWeek.sunday    => loc.daySunday,
    };

    // Torneo
    if (plan.type == DayType.tournament) {
      return TournamentDayView(dayName: dayName, loc: loc);
    }

    // Descanso
    if (plan.type == DayType.rest) {
      return RestDayView(
        dayName: dayName,
        loc: loc,
        onChangeTap: () => ref
            .read(trainingViewModelProvider.notifier)
            .setDayType(day, DayType.training),
      );
    }

    // Entrenamiento
    return TrainingDayView(
      day: day,
      dayName: dayName,
      plan: plan,
      isSimulated: isSimulated,
      loc: loc,
      onEditTap: () => _showActivityPicker(context, ref, day, plan),
    );
  }

  void _showActivityPicker(
      BuildContext context,
      WidgetRef ref,
      DayOfWeek day,
      DayPlan plan,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivityPickerSheet(
        currentIds: plan.activityIds,
        onConfirm: (ids) {
          ref
              .read(trainingViewModelProvider.notifier)
              .setDayActivities(day, ids);
        },
      ),
    );
  }
}