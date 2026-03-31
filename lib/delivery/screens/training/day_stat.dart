import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class DayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const DayStat({super.key, 
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.rajdhani(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label,
            style: GoogleFonts.rajdhani(
                fontSize: 9, color: AppColors.textTertiary, letterSpacing: 0.3)),
      ],
    );
  }
}