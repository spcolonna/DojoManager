import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/config/skill_tree_config.dart';
import '../../../core/animations/app_animations.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/use_cases/student/spend_skill_points_use_case.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../widgets/animations/skill_unlock_effect.dart';
import '../../widgets/animations/float_label.dart';
import '../../../core/providers/dojo_provider.dart';

class SkillTreeScreen extends ConsumerStatefulWidget {
  final Student student;
  const SkillTreeScreen({super.key, required this.student});

  @override
  ConsumerState<SkillTreeScreen> createState() => _SkillTreeScreenState();
}

class _SkillTreeScreenState extends ConsumerState<SkillTreeScreen> {
  late Student _student;
  String _selectedBranch = 'power';
  bool _isUnlocking = false;

  // Map de keys para efectos por nodeId
  final Map<String, GlobalKey<SkillUnlockEffectState>> _effectKeys = {};

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  Future<void> _unlockNode(SkillNodeDefinition node, String branchId) async {
    if (_isUnlocking) return;
    setState(() => _isUnlocking = true);

    final useCase = SpendSkillPointsUseCase(FirebaseDojoRepository());
    final result  = await useCase.execute(
      student: _student,
      nodeId: node.id,
      branchId: branchId,
      nodeDepth: node.depth,
    );

    if (!mounted) return;
    setState(() => _isUnlocking = false);

    if (result.success && result.updatedStudent != null) {
      setState(() => _student = result.updatedStudent!);

      // Efecto de desbloqueo
      _effectKeys[node.id]?.currentState?.play();

      // Float label con el bonus
      final bonus   = node.statBonuses.entries.first;
      final statName = bonus.key.toUpperCase();
      FloatLabel.show(
        context,
        '+${bonus.value} $statName',
        color: _branchColor(branchId),
      );

      // Invalida el provider para refrescar el dashboard
      ref.invalidate(studentsProvider);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Error',
            style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.redDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color _branchColor(String branchId) {
    return switch (branchId) {
      'power'     => AppColors.branchPower,
      'agility'   => AppColors.branchAgility,
      'technique' => AppColors.branchTechnique,
      'guard'     => AppColors.branchGuard,
      'mind'      => AppColors.branchMind,
      _           => AppColors.goldPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc           = l10n(context);
    final styleColor    = AppColors.colorByStyle[_student.styleId] ?? AppColors.goldPrimary;
    final branches      = SkillTreeConfig.branches;
    final selectedBranch = branches.firstWhere((b) => b.id == _selectedBranch);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.skillTreeTitle,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 15,
                color: AppColors.goldLight,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              _student.nameKey,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.goldPrimary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.psychology_rounded,
                        color: AppColors.goldPrimary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      loc.skillTreePointsLeft(_student.skillPoints),
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.bgDivider),
        ),
      ),
      body: Column(
        children: [
          // ── Selector de rama ─────────────────────────────────────────
          Container(
            color: AppColors.bgSurface,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: branches.map((branch) {
                final isSelected = branch.id == _selectedBranch;
                final color = Color(branch.colorHex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedBranch = branch.id),
                  child: AnimatedContainer(
                    duration: AppAnimations.fast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _branchIcon(branch.id),
                          color: isSelected ? color : AppColors.textTertiary,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _branchShortName(branch.id, loc),
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? color : AppColors.textTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.bgDivider),

          // ── Árbol de la rama seleccionada ────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _BranchTree(
                branch: selectedBranch,
                student: _student,
                effectKeys: _effectKeys,
                onUnlock: _unlockNode,
                isUnlocking: _isUnlocking,
                loc: loc,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _branchIcon(String id) => switch (id) {
    'power'     => Icons.fitness_center_rounded,
    'agility'   => Icons.directions_run_rounded,
    'technique' => Icons.precision_manufacturing_rounded,
    'guard'     => Icons.shield_rounded,
    'mind'      => Icons.psychology_rounded,
    _           => Icons.star_rounded,
  };

  String _branchShortName(String id, dynamic loc) => switch (id) {
    'power'     => loc.skillBranchPower,
    'agility'   => loc.skillBranchAgility,
    'technique' => loc.skillBranchTechnique,
    'guard'     => loc.skillBranchGuard,
    'mind'      => loc.skillBranchMind,
    _           => id,
  };
}

// ─── ÁRBOL VISUAL ─────────────────────────────────────────────────────────────

class _BranchTree extends StatelessWidget {
  final SkillBranchDefinition branch;
  final Student student;
  final Map<String, GlobalKey<SkillUnlockEffectState>> effectKeys;
  final Future<void> Function(SkillNodeDefinition, String) onUnlock;
  final bool isUnlocking;
  final dynamic loc;

  const _BranchTree({
    required this.branch,
    required this.student,
    required this.effectKeys,
    required this.onUnlock,
    required this.isUnlocking,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final color   = Color(branch.colorHex);
    final nodes   = branch.nodes;

    return Column(
      children: [
        // Título de la rama
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_tree_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                _branchName(branch.id, loc),
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Nodos del árbol
        ...List.generate(nodes.length, (i) {
          final node      = nodes[i];
          final isUnlocked = student.unlockedNodeIds.contains(node.id);
          final prevNode  = i > 0 ? nodes[i - 1] : null;
          final prevUnlocked = prevNode == null ||
              student.unlockedNodeIds.contains(prevNode.id);
          final canUnlock = !isUnlocked && prevUnlocked;
          final modifierMap =
          SkillTreeConfig.styleBranchModifiers[student.styleId];
          final modifier  = modifierMap?[branch.id] ?? 1.0;
          final baseCost  = SkillTreeConfig.phCostByNodeDepth[node.depth - 1];
          final finalCost = (baseCost * modifier).round();
          final canAfford = student.skillPoints >= finalCost;
          final meetsLevel = !node.isElite ||
              student.belt.level >= SkillTreeConfig.minBeltLevelForEliteNodes;

          // Registrar key si no existe
          effectKeys.putIfAbsent(
              node.id, () => GlobalKey<SkillUnlockEffectState>());

          return Column(
            children: [
              // Línea conectora
              if (i > 0)
                AnimatedContainer(
                  duration: AppAnimations.normal,
                  width: 2,
                  height: 32,
                  color: prevUnlocked
                      ? color.withOpacity(0.5)
                      : AppColors.bgDivider,
                ),

              SkillUnlockEffect(
                key: effectKeys[node.id],
                color: color,
                child: _SkillNodeCard(
                  node: node,
                  isUnlocked: isUnlocked,
                  canUnlock: canUnlock && canAfford && meetsLevel && !isUnlocking,
                  cost: finalCost,
                  color: color,
                  modifier: modifier,
                  meetsLevel: meetsLevel,
                  loc: loc,
                  onTap: canUnlock && !isUnlocking
                      ? () => onUnlock(node, branch.id)
                      : null,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  String _branchName(String id, dynamic loc) => switch (id) {
    'power'     => loc.skillBranchPower,
    'agility'   => loc.skillBranchAgility,
    'technique' => loc.skillBranchTechnique,
    'guard'     => loc.skillBranchGuard,
    'mind'      => loc.skillBranchMind,
    _           => id,
  };
}

// ─── NODO INDIVIDUAL ──────────────────────────────────────────────────────────

class _SkillNodeCard extends StatelessWidget {
  final SkillNodeDefinition node;
  final bool isUnlocked;
  final bool canUnlock;
  final int cost;
  final Color color;
  final double modifier;
  final bool meetsLevel;
  final dynamic loc;
  final VoidCallback? onTap;

  const _SkillNodeCard({
    required this.node,
    required this.isUnlocked,
    required this.canUnlock,
    required this.cost,
    required this.color,
    required this.modifier,
    required this.meetsLevel,
    required this.loc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isUnlocked) {
      borderColor = color;
      bgColor     = color.withOpacity(0.12);
      textColor   = color;
    } else if (canUnlock) {
      borderColor = color.withOpacity(0.6);
      bgColor     = color.withOpacity(0.05);
      textColor   = AppColors.textPrimary;
    } else {
      borderColor = AppColors.bgDivider;
      bgColor     = AppColors.bgElevated;
      textColor   = AppColors.textDisabled;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isUnlocked ? 2 : 1),
          boxShadow: isUnlocked
              ? [BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 2),
          )]
              : null,
        ),
        child: Row(
          children: [
            // Ícono de estado
            AnimatedContainer(
              duration: AppAnimations.normal,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked ? color.withOpacity(0.2) : AppColors.bgInput,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? color : borderColor,
                  width: isUnlocked ? 2 : 1,
                ),
              ),
              child: Icon(
                isUnlocked
                    ? Icons.check_rounded
                    : (canUnlock ? Icons.lock_open_rounded : Icons.lock_rounded),
                color: isUnlocked ? color : textColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Info del nodo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _nodeName(node.id, loc),
                        style: GoogleFonts.rajdhani(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      if (node.isElite) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ELITE',
                            style: GoogleFonts.rajdhani(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.goldPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bonuses
                  Wrap(
                    spacing: 6,
                    children: node.statBonuses.entries.map((e) =>
                        Text(
                          '+${e.value} ${e.key.toUpperCase()}',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            color: isUnlocked ? color : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                    ).toList(),
                  ),
                  if (!meetsLevel) ...[
                    const SizedBox(height: 4),
                    Text(
                      loc.skillTreeEliteRequirement,
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Costo / estado
            if (isUnlocked)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22)
            else
              Column(
                children: [
                  Text(
                    '$cost',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: canUnlock ? color : AppColors.textDisabled,
                    ),
                  ),
                  Text(
                    'PH',
                    style: GoogleFonts.rajdhani(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: canUnlock ? color : AppColors.textDisabled,
                      letterSpacing: 1,
                    ),
                  ),
                  if (modifier != 1.0)
                    Text(
                      modifier < 1.0 ? '▼ natural' : '▲ hard',
                      style: GoogleFonts.rajdhani(
                        fontSize: 9,
                        color: modifier < 1.0
                            ? AppColors.success
                            : AppColors.redLight,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _nodeName(String id, dynamic loc) => switch (id) {
    'heavy_strike'    => loc.skillHeavyStrike,
    'takedown'        => loc.skillTakedown,
    'raw_power'       => loc.skillRawPower,
    'sprint'          => loc.skillSprint,
    'evasion'         => loc.skillEvasion,
    'max_speed'       => loc.skillMaxSpeed,
    'precision'       => loc.skillPrecision,
    'counter_tech'    => loc.skillCounterTech,
    'technique_master'=> loc.skillTechniqueMaster,
    'basic_block'     => loc.skillBasicBlock,
    'armor'           => loc.skillArmor,
    'bunker'          => loc.skillBunker,
    'anticipation'    => loc.skillAnticipation,
    'fight_reading'   => loc.skillFightReading,
    'grand_strategist'=> loc.skillGrandStrategist,
    _                 => id,
  };
}