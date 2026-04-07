import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/tournament_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/tournament/tournament.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';

class StandingsTab extends ConsumerWidget {
  final Tournament tournament;
  const StandingsTab({super.key, required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc   = l10n(context);
    final teams = tournament.teams;
    final dojoAsync = ref.watch(dojoProvider);

    return dojoAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary)),
      error: (_, __) => const SizedBox.shrink(),
      data: (dojo) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Puntos por categoría del jugador ──────────────────
            if (dojo != null)
              _CategoryPointsSection(dojoId: dojo.id, loc: loc),

            const SizedBox(height: 20),

            // ── Tabla general de posiciones ────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered_rounded,
                      color: AppColors.textTertiary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'CLASIFICACIÓN GENERAL',
                    style: GoogleFonts.rajdhani(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        color: AppColors.textTertiary, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),

            // Header columnas
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text('TEAM',
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary, letterSpacing: 1)),
                  ),
                  ...[
                    loc.tournamentPlayed,
                    loc.tournamentWins,
                    loc.tournamentDraws,
                    loc.tournamentLosses,
                    loc.tournamentGoalDiff,
                    loc.tournamentPoints,
                  ].map((h) => SizedBox(
                    width: 28,
                    child: Text(h,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary, letterSpacing: 0.5)),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Filas de equipos
            ...List.generate(teams.length, (i) {
              final team     = teams[i];
              final isPlayer = team.isPlayer;
              final pos      = i + 1;
              final posColor = pos <= TournamentConfig.leaguePromotionSpots
                  ? AppColors.goldPrimary
                  : AppColors.textTertiary;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isPlayer
                      ? AppColors.goldPrimary.withValues(alpha: 0.07)
                      : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPlayer
                        ? AppColors.goldPrimary.withValues(alpha: 0.3)
                        : pos <= TournamentConfig.leaguePromotionSpots
                        ? AppColors.goldPrimary.withValues(alpha: 0.15)
                        : AppColors.bgDivider,
                    width: isPlayer ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('$pos',
                          style: GoogleFonts.rajdhani(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              color: posColor)),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          if (isPlayer)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.star_rounded,
                                  color: AppColors.goldPrimary, size: 12),
                            ),
                          Flexible(
                            child: Text(
                              team.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                  fontSize: 13,
                                  fontWeight: isPlayer
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isPlayer
                                      ? AppColors.goldLight
                                      : AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...[
                      team.matchesPlayed,
                      team.wins,
                      team.draws,
                      team.losses,
                      team.goalDifference,
                      team.points,
                    ].asMap().entries.map((e) {
                      final isLast = e.key == 5;
                      return SizedBox(
                        width: 28,
                        child: Text(
                          '${e.value}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                              fontSize: 13,
                              fontWeight: isLast
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isLast
                                  ? (isPlayer
                                  ? AppColors.goldPrimary
                                  : AppColors.textPrimary)
                                  : AppColors.textSecondary),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // Leyenda clasificación
            Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                        color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Top ${TournamentConfig.leaguePromotionSpots} clasifican a la Copa Inter-Estilos',
                  style: GoogleFonts.rajdhani(
                      fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PUNTOS POR CATEGORÍA ─────────────────────────────────────────────────────

class _CategoryPointsSection extends StatefulWidget {
  final String dojoId;
  final dynamic loc;
  const _CategoryPointsSection({required this.dojoId, required this.loc});

  @override
  State<_CategoryPointsSection> createState() =>
      _CategoryPointsSectionState();
}

class _CategoryPointsSectionState extends State<_CategoryPointsSection> {
  Map<String, int> _categoryPoints  = {};
  Map<String, int> _categoryMatches = {};
  int _totalPoints = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo  = FirebaseDojoRepository();
    final saved = await repo.getTournamentState(widget.dojoId);
    if (mounted) {
      setState(() {
        _categoryPoints = Map<String, int>.from(
          (saved?['categoryPoints'] as Map? ?? {}).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ),
        );
        _categoryMatches = Map<String, int>.from(
          (saved?['categoryMatches'] as Map? ?? {}).map(
                (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ),
        );
        _totalPoints = (saved?['totalPoints'] as num? ?? 0).toInt();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;

    if (_loading) return const SizedBox(
      height: 60,
      child: Center(child: CircularProgressIndicator(
          color: AppColors.goldPrimary, strokeWidth: 2)),
    );

    if (_categoryPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: AppColors.goldPrimary, size: 14),
            const SizedBox(width: 6),
            Text(
              'TUS PUNTOS POR CATEGORÍA',
              style: GoogleFonts.rajdhani(
                  fontSize: 10, fontWeight: FontWeight.w800,
                  color: AppColors.goldPrimary, letterSpacing: 1.5),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'TOTAL: $_totalPoints pts',
                style: GoogleFonts.rajdhani(
                    fontSize: 10, fontWeight: FontWeight.w800,
                    color: AppColors.goldPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Una fila por categoría
        ..._categoryPoints.entries.map((entry) {
          final beltLevel   = int.tryParse(entry.key) ?? 1;
          final points      = entry.value;
          final matches     = _categoryMatches[entry.key] ?? 0;
          final maxPoints   = TournamentConfig.pointsByBelt[beltLevel] ?? 3;
          final totalPossible = maxPoints * matches;
          final pct = totalPossible > 0
              ? (points / totalPossible).clamp(0.0, 1.0)
              : 0.0;
          final beltColor =
              AppColors.beltColorByLevel[beltLevel] ?? AppColors.beltWhite;
          final beltName =
          beltDisplayName('belt_${_beltKey(beltLevel)}', loc);
          final isChampion = matches > 0 && pct >= 0.6;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isChampion
                    ? beltColor.withValues(alpha: 0.5)
                    : AppColors.bgDivider,
                width: isChampion ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Indicador de faja
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                          color: beltColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      beltName.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: beltColor),
                    ),
                    const Spacer(),
                    if (isChampion)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.workspace_premium_rounded,
                            color: beltColor, size: 14),
                      ),
                    Text(
                      '$points pts',
                      style: GoogleFonts.cinzelDecorative(
                          fontSize: 14, fontWeight: FontWeight.bold,
                          color: beltColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ $totalPossible',
                      style: GoogleFonts.rajdhani(
                          fontSize: 10, color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: AppColors.bgDivider,
                    valueColor: AlwaysStoppedAnimation(beltColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$matches fechas jugadas · +$maxPoints pts por victoria',
                      style: GoogleFonts.rajdhani(
                          fontSize: 9, color: AppColors.textTertiary),
                    ),
                    const Spacer(),
                    Text(
                      isChampion
                          ? '${(pct * 100).toStringAsFixed(0)}% ✓'
                          : '${(pct * 100).toStringAsFixed(0)}% / 60%',
                      style: GoogleFonts.rajdhani(
                          fontSize: 9,
                          color: isChampion
                              ? beltColor
                              : AppColors.textTertiary,
                          fontWeight: isChampion
                              ? FontWeight.w700
                              : FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _beltKey(int level) => switch (level) {
    1 => 'white',   2 => 'yellow', 3 => 'orange',
    4 => 'green',   5 => 'blue',   6 => 'purple',
    7 => 'brown',   8 => 'red',    9 => 'red_black',
    10 => 'black',  _ => 'white',
  };
}