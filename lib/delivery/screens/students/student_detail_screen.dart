import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/animations/app_animations.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../core/utils/belt_helper.dart';
import '../../../core/config/training_activities_config.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/entities/training_session.dart';
import '../../widgets/animations/animated_stat_bar.dart';
import 'details/history_tab.dart';
import 'details/progress_tab.dart';
import 'details/stats_tab.dart';
import 'details/student_header.dart';
import 'skill_tree_screen.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final Student student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  ConsumerState<StudentDetailScreen> createState() =>
      _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late Student _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // Refrescar desde el provider cuando volvemos del skill tree
  void _refreshStudent() {
    final students = ref.read(studentsProvider).valueOrNull;
    if (students == null) return;
    final updated =
        students.where((s) => s.id == _student.id).firstOrNull;
    if (updated != null) setState(() => _student = updated);
  }

  @override
  Widget build(BuildContext context) {
    final loc        = l10n(context);
    final styleColor = AppColors.colorByStyle[_student.styleId] ?? AppColors.goldPrimary;
    final beltColor  = AppColors.beltColorByLevel[_student.belt.level] ?? AppColors.beltWhite;
    final xpRequired = _student.belt.xpRequiredForNextLevel;
    final xpPercent  = xpRequired > 0
        ? (_student.currentXP / xpRequired).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.bgSurface,
            iconTheme: const IconThemeData(color: AppColors.textSecondary),
            flexibleSpace: FlexibleSpaceBar(
              background: StudentHeader(
                student: _student,
                styleColor: styleColor,
                beltColor: beltColor,
                xpPercent: xpPercent,
                loc: loc,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.bgDeep,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: AppColors.goldPrimary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.bgDeep,
                  unselectedLabelColor: AppColors.textTertiary,
                  labelStyle: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: GoogleFonts.rajdhani(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: loc.studentStats),
                    Tab(text: loc.studentProgress),
                    Tab(text: loc.studentHistory),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            // ── Tab 1: Stats ───────────────────────────────────────
            StatsTab(student: _student, styleColor: styleColor),

            // ── Tab 2: Progress + árbol ────────────────────────────
            ProgressTab(
              student: _student,
              beltColor: beltColor,
              xpPercent: xpPercent,
              onOpenTree: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SkillTreeScreen(student: _student),
                ));
                _refreshStudent();
              },
              loc: loc,
            ),

            // ── Tab 3: Historial ────────────────────────────────────
            HistoryTab(student: _student, loc: loc),
          ],
        ),
      ),
    );
  }
}