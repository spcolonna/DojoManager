import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/animations/app_animations.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/use_cases/training/simulate_week_use_case.dart';
import '../../widgets/animations/staggered_list.dart';
import '../students/skill_tree_screen.dart';
import '../../../core/providers/dojo_provider.dart';

class WeekResultsScreen extends ConsumerStatefulWidget {
  final List<WeekSimulationResult> results;
  const WeekResultsScreen({super.key, required this.results});

  @override
  ConsumerState<WeekResultsScreen> createState() => _WeekResultsScreenState();
}

class _WeekResultsScreenState extends ConsumerState<WeekResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerScale;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerScale = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.elasticOut),
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc         = l10n(context);
    final studentsAsync = ref.watch(studentsProvider);
    final totalPH     = widget.results.fold(0, (sum, r) => sum + r.phGained);
    final anyLevelUp  = widget.results.any((r) => r.leveledUp);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header animado ───────────────────────────────────────────
            ScaleTransition(
              scale: _headerScale,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.goldPrimary.withOpacity(0.5),
                            width: 2),
                      ),
                      child: const Icon(AppIcons.actionConfirm,
                          color: AppColors.goldPrimary, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.trainingWeekComplete,
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldLight,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (totalPH > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.goldPrimary.withOpacity(0.3)),
                        ),
                        child: Text(
                          '+$totalPH PH disponibles',
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Resultados por estudiante ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StaggeredList(
                  children: widget.results.map((result) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ResultCard(result: result, loc: loc),
                      )
                  ).toList(),
                ),
              ),
            ),

            // ── Botones de acción ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                children: [
                  // Botón distribuir PH
                  if (totalPH > 0)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final students =
                          await ref.read(studentsProvider.future);
                          if (!context.mounted) return;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SkillTreeScreen(
                              student: students.first,
                            ),
                          ));
                        },
                        icon: const Icon(AppIcons.branchPower, size: 18),
                        label: Text(
                          loc.trainingDistributePoints,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldPrimary,
                          foregroundColor: AppColors.bgDeep,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.bgDivider),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final WeekSimulationResult result;
  final dynamic loc;

  const _ResultCard({required this.result, required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: result.leveledUp
              ? AppColors.goldPrimary.withOpacity(0.5)
              : AppColors.bgDivider,
          width: result.leveledUp ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                result.studentName,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (result.leveledUp)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward_rounded,
                          color: AppColors.goldPrimary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        result.newBelt?.titleKey ?? 'Level Up!',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                icon: Icons.stars_rounded,
                label: '+${result.xpGained} XP',
                color: AppColors.success,
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: AppIcons.trainingMind,
                label: '+${result.phGained} PH',
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 10),
              _StatChip(
                icon: Icons.battery_charging_full_rounded,
                label: '${result.newFatigue}% fatigue',
                color: result.newFatigue > 60
                    ? AppColors.warning
                    : AppColors.info,
              ),
              if (result.injured) ...[
                const SizedBox(width: 10),
                _StatChip(
                  icon: AppIcons.studentInjured,
                  label: 'Injured',
                  color: AppColors.redLight,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}