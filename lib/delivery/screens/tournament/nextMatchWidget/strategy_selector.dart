import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/fight.dart';

class StrategySelector extends StatelessWidget {
  final FightStrategy selected;
  final Color color;
  final void Function(FightStrategy) onChanged;
  final dynamic loc;

  const StrategySelector({super.key, 
    required this.selected,
    required this.color,
    required this.onChanged,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FightStrategy.values.map((s) {
          final isSelected = s == selected;
          final label = switch (s) {
            FightStrategy.aggressive => loc.strategyAggressive,
            FightStrategy.defensive  => loc.strategyDefensive,
            FightStrategy.technical  => loc.strategyTechnical,
            FightStrategy.grappling  => loc.strategyGrappling,
            FightStrategy.adaptive   => loc.strategyAdaptive,
          };
          final sColor = switch (s) {
            FightStrategy.aggressive => AppColors.redLight,
            FightStrategy.defensive  => AppColors.info,
            FightStrategy.technical  => AppColors.goldPrimary,
            FightStrategy.grappling  => AppColors.orange,
            FightStrategy.adaptive   => AppColors.success,
          };

          return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? sColor.withValues(alpha: 0.15)
                    : AppColors.bgElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? sColor : AppColors.bgDivider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? sColor : AppColors.textTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}