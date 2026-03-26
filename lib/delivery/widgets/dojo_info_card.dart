import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/animations/app_animations.dart';
import '../../domain/entities/dojo.dart';

class DojoInfoCard extends StatefulWidget {
  final Dojo dojo;
  final int studentCount;
  final VoidCallback onEnter;
  final VoidCallback onDismiss;

  const DojoInfoCard({
    super.key,
    required this.dojo,
    required this.studentCount,
    required this.onEnter,
    required this.onDismiss,
  });

  @override
  State<DojoInfoCard> createState() => _DojoInfoCardState();
}

class _DojoInfoCardState extends State<DojoInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: AppAnimations.normal);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _c, curve: AppAnimations.slideIn),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _c, curve: AppAnimations.fadeIn),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleColor =
        AppColors.colorByStyle[widget.dojo.styleId] ?? AppColors.goldPrimary;

    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: styleColor.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: styleColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: styleColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: styleColor.withOpacity(0.4)),
                  ),
                  child: Icon(Icons.home_work_rounded,
                      color: styleColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dojo.name,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Level ${widget.dojo.level} · ${_styleName(widget.dojo.styleId)}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cerrar
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textTertiary, size: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Stats rápidos
            Row(
              children: [
                _StatPill(
                  icon: Icons.people_rounded,
                  label:
                  '${widget.studentCount}/${widget.dojo.maxStudentSlots}',
                  sublabel: 'Students',
                  color: styleColor,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  icon: Icons.military_tech_rounded,
                  label: 'Div. 3',
                  sublabel: 'Division',
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  icon: Icons.emoji_events_rounded,
                  label: '0',
                  sublabel: 'Wins',
                  color: AppColors.success,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Barra de capacidad
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.studentCount / widget.dojo.maxStudentSlots,
                minHeight: 5,
                backgroundColor: AppColors.bgDivider,
                valueColor: AlwaysStoppedAnimation<Color>(styleColor),
              ),
            ),

            const SizedBox(height: 14),

            // Botón entrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onEnter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: styleColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'ENTER DOJO',
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _styleName(String id) => switch (id) {
    'kung_fu'   => 'Kung Fu',
    'karate'    => 'Karate',
    'taekwondo' => 'Taekwondo',
    'judo'      => 'Judo',
    'muay_thai' => 'Muay Thai',
    'bjj'       => 'BJJ',
    'boxing'    => 'Boxing',
    'mma'       => 'MMA',
    _           => id,
  };
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts.rajdhani(
                fontSize: 9,
                color: AppColors.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}