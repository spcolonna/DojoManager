import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/student.dart';
import '../../widgets/animations/staggered_list.dart';
import 'student_detail_screen.dart';

class StudentsScreen extends ConsumerWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc           = l10n(context);
    final studentsAsync = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 44,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          loc.studentsTitle,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 14,
            color: AppColors.goldLight,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.bgDivider),
        ),
      ),
      body: studentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Text(
                loc.trainingNoStudents,
                style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: StaggeredList(
              children: students.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StudentCard(
                  student: s,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StudentDetailScreen(student: s),
                    ),
                  ),
                ),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc        = l10n(context);
    final styleColor = AppColors.colorByStyle[student.styleId] ?? AppColors.goldPrimary;
    final beltColor  = AppColors.beltColorByLevel[student.belt.level] ?? AppColors.beltWhite;
    final xpRequired = student.belt.xpRequiredForNextLevel;
    final xpPercent  = xpRequired > 0
        ? (student.currentXP / xpRequired).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: student.isInjured
                ? AppColors.redAction.withOpacity(0.5)
                : AppColors.bgDivider,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: styleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: styleColor.withOpacity(0.35)),
                  ),
                  child: Icon(AppIcons.student,
                      color: styleColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + tier
                      Row(
                        children: [
                          Text(
                            student.nameKey,
                            style: GoogleFonts.rajdhani(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TierBadge(tier: student.tier),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Faja + estilo
                      Row(
                        children: [
                          Container(
                            width: 9, height: 9,
                            decoration: BoxDecoration(
                              color: beltColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            beltDisplayName(student.belt.titleKey, loc),
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: beltColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '·',
                            style: GoogleFonts.rajdhani(
                                color: AppColors.textTertiary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            styleDisplayName(student.styleId, loc),
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // PH disponibles
                if (student.skillPoints > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.goldPrimary.withOpacity(0.4)),
                    ),
                    child: Text(
                      '+${student.skillPoints} PH',
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                const Icon(AppIcons.actionForward,
                    color: AppColors.disabled, size: 20),
              ],
            ),

            const SizedBox(height: 14),

            // Barra XP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'XP',
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      loc.studentXPToNext(
                          (xpRequired - student.currentXP).clamp(0, 999999)),
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: xpPercent,
                    minHeight: 6,
                    backgroundColor: AppColors.bgDivider,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(styleColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Fatiga + lesión
            Row(
              children: [
                Icon(
                  AppIcons.statusFatigue,
                  size: 13,
                  color: student.fatiguePercent > 60
                      ? AppColors.warning
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${loc.studentFatigueLevel}: ${student.fatiguePercent}%',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: student.fatiguePercent > 60
                        ? AppColors.warning
                        : AppColors.textTertiary,
                  ),
                ),
                if (student.isInjured) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.redAction.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(AppIcons.studentInjured,
                            size: 10, color: AppColors.redLight),
                        const SizedBox(width: 3),
                        Text(
                          loc.studentInjured,
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${student.trainingHistory.length} sessions',
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final StudentTier tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      StudentTier.bronze   => const Color(0xFFCD7F32),
      StudentTier.silver   => const Color(0xFFC0C0C0),
      StudentTier.gold     => AppColors.goldPrimary,
      StudentTier.platinum => const Color(0xFF5DADE2),
    };
    final label = switch (tier) {
      StudentTier.bronze   => 'B',
      StudentTier.silver   => 'S',
      StudentTier.gold     => 'G',
      StudentTier.platinum => 'P',
    };

    return Container(
      width: 18, height: 18,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}