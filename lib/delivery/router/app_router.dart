import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/school_name_screen.dart';
import '../screens/onboarding/style_selection_screen.dart';
import '../screens/onboarding/intro_narrative_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dojo/dojo_screen.dart';
import '../screens/dojo/dojo_upgrades_screen.dart';
import '../screens/training/training_screen.dart';
import '../screens/training/week_simulation_screen.dart';
import '../screens/tournament/tournament_screen.dart';
import '../screens/tournament/pre_fight_screen.dart';
import '../screens/fight/fight_arena_screen.dart';
import '../screens/fight/fight_result_screen.dart';
import '../screens/students/students_screen.dart';
import '../screens/students/student_detail_screen.dart';
import '../screens/students/skill_tree_screen.dart';
import '../screens/market/market_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/messages/messages_screen.dart';

class AppRoutes {
  static const splash         = '/';
  static const login          = '/login';
  static const schoolName     = '/onboarding/school-name';
  static const styleSelection = '/onboarding/style';
  static const introNarrative = '/onboarding/intro';
  static const dashboard      = '/dashboard';
  static const dojo           = '/dojo';
  static const dojoUpgrades   = '/dojo/upgrades';
  static const training       = '/training';
  static const weekSimulation = '/training/simulate';
  static const tournament     = '/tournament';
  static const preFight       = '/tournament/pre-fight';
  static const fightArena     = '/fight';
  static const fightResult    = '/fight/result';
  static const students       = '/students';
  static const studentDetail  = '/students/:id';
  static const skillTree      = '/students/:id/skill-tree';
  static const market         = '/market';
  static const shop           = '/shop';
  static const messages       = '/messages';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash,         builder: (c, s) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,          builder: (c, s) => const LoginScreen()),
      GoRoute(path: AppRoutes.schoolName,     builder: (c, s) => const SchoolNameScreen()),
      GoRoute(path: AppRoutes.styleSelection, builder: (c, s) => const StyleSelectionScreen()),
      GoRoute(path: AppRoutes.introNarrative, builder: (c, s) => const IntroNarrativeScreen()),
      GoRoute(path: AppRoutes.dashboard,      builder: (c, s) => const DashboardScreen()),
      GoRoute(path: AppRoutes.dojo,           builder: (c, s) => const DojoScreen()),
      GoRoute(path: AppRoutes.dojoUpgrades,   builder: (c, s) => const DojoUpgradesScreen()),
      GoRoute(path: AppRoutes.training,       builder: (c, s) => const TrainingScreen()),
      GoRoute(path: AppRoutes.weekSimulation, builder: (c, s) => const WeekSimulationScreen()),
      GoRoute(path: AppRoutes.tournament,     builder: (c, s) => const TournamentScreen()),
      GoRoute(path: AppRoutes.preFight,       builder: (c, s) => const PreFightScreen()),
      GoRoute(path: AppRoutes.fightArena,     builder: (c, s) => const FightArenaScreen()),
      GoRoute(path: AppRoutes.fightResult,    builder: (c, s) => const FightResultScreen()),
      GoRoute(path: AppRoutes.students,       builder: (c, s) => const StudentsScreen()),
      GoRoute(path: AppRoutes.studentDetail,  builder: (c, s) => StudentDetailScreen(studentId: s.pathParameters['id']!)),
      GoRoute(path: AppRoutes.skillTree,      builder: (c, s) => SkillTreeScreen(studentId: s.pathParameters['id']!)),
      GoRoute(path: AppRoutes.market,         builder: (c, s) => const MarketScreen()),
      GoRoute(path: AppRoutes.shop,           builder: (c, s) => const ShopScreen()),
      GoRoute(path: AppRoutes.messages,       builder: (c, s) => const MessagesScreen()),
    ],
  );
});
