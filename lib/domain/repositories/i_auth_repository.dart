import 'package:dartz/dartz.dart';

abstract class IAuthRepository {
  Future<Either<String, String>> signInWithGoogle();
  Future<Either<String, String>> signInWithApple();
  Future<Either<String, String>> signInWithEmail(String email, String password);
  Future<Either<String, String>> signUpWithEmail(String email, String password);
  Future<Either<String, void>> signOut();
  String? get currentUserId;
  bool get isLoggedIn;
}
