import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/delivery/screens/dashboard/widgets/quick_card.dart';
import 'package:grand_dojo/delivery/screens/dashboard/widgets/student_card_skeleton.dart';
import 'package:grand_dojo/delivery/screens/dashboard/widgets/student_preview_card.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/providers/dojo_provider.dart';
import '../../../../core/utils/l10n_helper.dart';
import '../../dojo/dojo_screen.dart';
import '../../market/market_screen.dart';
import 'dojo_banner_skeleton.dart';


class DojoHome extends ConsumerWidget {
  const DojoHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc          = l10n(context);
    final dojoAsync    = ref.watch(dojoProvider);
    final studentsAsync = ref.watch(studentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // ── Banner del dojo ──────────────────────────────────────────
          dojoAsync.when(
            loading: () => DojoBannerSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (dojo) {
              if (dojo == null) return const SizedBox.shrink();

              final styleName  = _styleDisplayName(dojo.styleId, loc);
              final styleColor = AppColors.colorByStyle[dojo.styleId] ??
                  AppColors.goldPrimary;
              final slotsUsed  = studentsAsync.valueOrNull?.length ?? 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientDojo,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldDark, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldPrimary.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: styleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: styleColor.withOpacity(0.5)),
                      ),
                      child: Icon(Icons.home_work_rounded,
                          color: styleColor, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dojo.name,
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level ${dojo.level} · $styleName',
                            style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: slotsUsed / dojo.maxStudentSlots,
                              minHeight: 6,
                              backgroundColor: AppColors.bgDivider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  styleColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$slotsUsed / ${dojo.maxStudentSlots} students',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Quick access ─────────────────────────────────────────────
          Text(
            'QUICK ACCESS',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickCard(
                  title: loc.navMarket,
                  icon: PhosphorIconsRegular.storefront,
                  gradient: AppColors.gradientMarket,
                  iconColor: AppColors.purpleLight,
                  borderColor: AppColors.purple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MarketScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickCard(
                  title: loc.navDojo,
                  icon: PhosphorIconsRegular.wrench,
                  gradient: AppColors.gradientUpgrades,
                  iconColor: AppColors.successLight,
                  borderColor: AppColors.successBorder,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DojoScreen()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Estudiantes ──────────────────────────────────────────────
          Text(
            'MY STUDENTS',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          studentsAsync.when(
            loading: () => Column(
              children: [
                StudentCardSkeleton(),
                const SizedBox(height: 10),
                StudentCardSkeleton(),
              ],
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    'No students yet',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return Column(
                children: students.map((s) {
                  final beltColor = AppColors.beltColorByLevel[s.belt.level]
                      ?? AppColors.beltWhite;
                  final xpRequired = s.belt.xpRequiredForNextLevel;
                  final xpPercent  = xpRequired > 0
                      ? s.currentXP / xpRequired
                      : 0.0;
                  final styleColor = AppColors.colorByStyle[s.styleId]
                      ?? AppColors.goldPrimary;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudentPreviewCard(
                      name: s.nameKey,
                      styleId: s.styleId,
                      styleColor: styleColor,
                      belt: s.belt.titleKey,
                      beltColor: beltColor,
                      xpPercent: xpPercent.clamp(0.0, 1.0),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // ── Próximo torneo ───────────────────────────────────────────
          Text(
            'NEXT TOURNAMENT',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientTournament,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.redAction.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.redAction.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(AppIcons.fightWin,
                      color: AppColors.redLight, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly League',
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Saturday · White Belt division',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.redAction,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ENROLL',
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _styleDisplayName(String id, dynamic loc) => switch (id) {
    'kung_fu'   => loc.styleKungFu,
    'karate'    => loc.styleKarate,
    'taekwondo' => loc.styleTaekwondo,
    'judo'      => loc.styleJudo,
    'muay_thai' => loc.styleMuayThai,
    'bjj'       => loc.styleBjj,
    'boxing'    => loc.styleBoxing,
    'mma'       => loc.styleMma,
    _           => id,
  };
}