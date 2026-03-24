import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/dojo.dart';

enum AppRoute { loading, login, onboarding, dashboard }

class AppState {
  final AppRoute route;
  final UserProgress? userProgress;
  final Dojo? dojo;

  const AppState({
    required this.route,
    this.userProgress,
    this.dojo,
  });
}

class AppStateNotifier extends StateNotifier<AppState> {
  final FirebaseDojoRepository _repo;

  AppStateNotifier(this._repo)
      : super(const AppState(route: AppRoute.loading)) {
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      state = const AppState(route: AppRoute.login);
      return;
    }

    await checkUserState(user.uid);
  }

  Future<void> checkUserState(String userId) async {
    state = const AppState(route: AppRoute.loading);

    final progress = await _repo.getUserProgress(userId);

    if (!progress.onboardingCompleted) {
      state = AppState(route: AppRoute.onboarding, userProgress: progress);
      return;
    }

    final dojoResult = await _repo.getDojoByOwner(userId);
    final dojo = dojoResult.fold((_) => null, (d) => d);

    if (dojo == null) {
      // Tiene onboarding marcado pero no tiene dojo — caso raro, manda a onboarding
      state = AppState(route: AppRoute.onboarding, userProgress: progress);
      return;
    }

    state = AppState(
      route: AppRoute.dashboard,
      userProgress: progress,
      dojo: dojo,
    );
  }

  Future<void> completeOnboarding({
    required String userId,
    required String schoolName,
    required String styleId,
    required int startingMD,
  }) async {
    // 1. Crear dojo
    final dojoResult = await _repo.createDojo(
      ownerId: userId,
      name: schoolName,
      styleId: styleId,
      startingMD: startingMD,
    );

    if (dojoResult.isLeft()) return;

    final dojo = dojoResult.fold((_) => null, (d) => d)!;

    // 2. Crear estudiantes iniciales
    await _repo.createStartingStudents(
      dojoId: dojo.id,
      styleId: styleId,
    );

    // 3. Marcar onboarding completo
    await _repo.markOnboardingCompleted(userId);

    state = AppState(
      route: AppRoute.dashboard,
      dojo: dojo,
    );
  }

  void signOut() {
    state = const AppState(route: AppRoute.login);
  }
}

final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(FirebaseDojoRepository());
});