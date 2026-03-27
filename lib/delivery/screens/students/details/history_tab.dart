import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../domain/entities/student.dart';
import 'history_card.dart';

class HistoryTab extends StatelessWidget {
  final Student student;
  final dynamic loc;

  const HistoryTab({required this.student, required this.loc});

  @override
  Widget build(BuildContext context) {
    if (student.trainingHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.actionHistory,
                color: AppColors.textTertiary, size: 40),
            const SizedBox(height: 12),
            Text(
              loc.studentNoHistory,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: student.trainingHistory.length,
      itemBuilder: (_, i) {
        final session = student.trainingHistory[i];
        return HistoryCard(session: session, loc: loc);
      },
    );
  }
}