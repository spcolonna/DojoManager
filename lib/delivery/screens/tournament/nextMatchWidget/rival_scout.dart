import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/belt_helper.dart';
import 'avg_stat_bar.dart';

class RivalScout extends StatelessWidget {
  final dynamic rival;
  final dynamic loc;
  const RivalScout({required this.rival, required this.loc});

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
            AvgStatBar('STR', rival.fighters, 'str', AppColors.branchPower),
            AvgStatBar('SPD', rival.fighters, 'spd', AppColors.branchAgility),
            AvgStatBar('TEC', rival.fighters, 'tec', AppColors.branchTechnique),
            AvgStatBar('DEF', rival.fighters, 'def', AppColors.branchGuard),
            AvgStatBar('MEN', rival.fighters, 'men', AppColors.branchMind),
          ],
        ],
      ),
    );
  }
}