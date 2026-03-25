import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/l10n_helper.dart';

class StudentPreviewCard extends StatelessWidget {
  final String name;
  final String styleId;
  final Color styleColor;
  final String belt;
  final Color beltColor;
  final double xpPercent;

  const StudentPreviewCard({
    required this.name,
    required this.styleId,
    required this.styleColor,
    required this.belt,
    required this.beltColor,
    required this.xpPercent,
  });

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    final styleDisplay = switch (styleId) {
      'kung_fu'   => loc.styleKungFu,
      'karate'    => loc.styleKarate,
      'taekwondo' => loc.styleTaekwondo,
      'judo'      => loc.styleJudo,
      'muay_thai' => loc.styleMuayThai,
      'bjj'       => loc.styleBjj,
      'boxing'    => loc.styleBoxing,
      'mma'       => loc.styleMma,
      _           => styleId,
    };

    final beltDisplay = switch (belt) {
      'belt_white'     => loc.beltWhite,
      'belt_yellow'    => loc.beltYellow,
      'belt_orange'    => loc.beltOrange,
      'belt_green'     => loc.beltGreen,
      'belt_blue'      => loc.beltBlue,
      'belt_purple'    => loc.beltPurple,
      'belt_brown'     => loc.beltBrown,
      'belt_red'       => loc.beltRed,
      'belt_red_black' => loc.beltRedBlack,
      'belt_black'     => loc.beltBlack,
      _                => belt,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: styleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: styleColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.person_rounded,
                color: styleColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: beltColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      beltDisplay,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: beltColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  styleDisplay,
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: xpPercent,
                    minHeight: 4,
                    backgroundColor: AppColors.bgDivider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.disabled, size: 20),
        ],
      ),
    );
  }
}