import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/training/training_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/weekly_plan.dart';

class SimulationBar extends StatelessWidget {
  final TrainingState state;
  final VoidCallback onSimulateDay;
  final VoidCallback onSimulateWeek;
  final VoidCallback onGoToTournament;

  const SimulationBar({
    required this.state,
    required this.onSimulateDay,
    required this.onSimulateWeek,
    required this.onGoToTournament,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final canSimDay = state.selectedDay != null &&
        !state.isDaySimulated(state.selectedDay!) &&
        state.plan.days[state.selectedDay!]?.type != DayType.tournament;
    final canSimWeek = !state.isSimulating &&
        state.plan.days.values.any((d) => !d.isSimulated);

    // Detectar si el día seleccionado O el día actual es torneo
    final selectedIsTournament = state.selectedDay != null &&
        state.plan.days[state.selectedDay!]?.type == DayType.tournament;
    final currentIsTournament = state.currentDay != null &&
        state.plan.days[state.currentDay!]?.type == DayType.tournament;
    final showFightButton = selectedIsTournament || currentIsTournament;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        border: Border(top: BorderSide(color: AppColors.bgDivider)),
      ),
      child: Row(
        children: [
          // Simular día
          Expanded(
            child: showFightButton
                ? ElevatedButton.icon(
              onPressed: onGoToTournament,
              icon: const Icon(Icons.emoji_events_rounded, size: 16),
              label: Text(
                'COMBATIR',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redAction,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
                : OutlinedButton(
              onPressed: canSimDay && !state.isSimulating ? onSimulateDay : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldPrimary,
                side: BorderSide(
                  color: canSimDay
                      ? AppColors.goldPrimary.withValues(alpha: 0.5)
                      : AppColors.bgDivider,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                loc.trainingSimulateDay,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Simular semana
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canSimWeek ? onSimulateWeek : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.bgDeep,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: state.isSimulating
                  ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.bgDeep))
                  : Text(
                loc.trainingSimulateWeek,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}