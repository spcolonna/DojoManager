import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class RestDayView extends StatelessWidget {
  final String dayName;
  final dynamic loc;
  final VoidCallback onChangeTap;
  const RestDayView({super.key, 
    required this.dayName,
    required this.loc,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.4), width: 2),
              ),
              child: const Icon(Icons.hotel_rounded,
                  color: AppColors.infoLight, size: 36),
            ),
            const SizedBox(height: 16),
            Text(dayName,
                style: GoogleFonts.cinzelDecorative(
                    fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.goldLight)),
            const SizedBox(height: 8),
            Text(
              loc.trainingDayRest,
              style: GoogleFonts.rajdhani(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onChangeTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldPrimary,
                side: const BorderSide(color: AppColors.bgDivider),
              ),
              child: Text(loc.trainingDayTraining,
                  style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}