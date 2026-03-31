import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class EmptyDayHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '← Select a day to plan',
        style: GoogleFonts.rajdhani(
            fontSize: 14, color: AppColors.textTertiary),
      ),
    );
  }
}