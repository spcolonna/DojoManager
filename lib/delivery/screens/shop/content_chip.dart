import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentChipIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const ContentChipIcon(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 3),
          Text(text, style: GoogleFonts.rajdhani(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}