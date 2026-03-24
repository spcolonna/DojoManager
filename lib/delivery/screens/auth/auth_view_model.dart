import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/repositories/firebase_auth_repository.dart';

enum AuthMode { login, signup }

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final AuthMode mode;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.mode = AuthMode.login,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    AuthMode? mode,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      mode: mode ?? this.mode,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final FirebaseAuthRepository _repo;

  AuthViewModel(this._repo) : super(const AuthState());

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == AuthMode.login ? AuthMode.signup : AuthMode.login,
      clearError: true,
    );
  }

  Future<void> submit(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = state.mode == AuthMode.login
        ? await _repo.signInWithEmail(email, password)
        : await _repo.signUpWithEmail(email, password);

    result.fold(
          (error) => state = state.copyWith(isLoading: false, error: error),
          (_) => state = state.copyWith(isLoading: false, isAuthenticated: true),
    );
  }
}

final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(FirebaseAuthRepository());
});