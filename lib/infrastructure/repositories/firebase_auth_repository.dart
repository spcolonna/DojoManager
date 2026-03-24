import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'package:dartz/dartz.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isLoggedIn => _auth.currentUser != null;

  @override
  Future<Either<String, String>> signInWithEmail(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e.code));
    }
  }

  @override
  Future<Either<String, String>> signUpWithEmail(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e.code));
    }
  }

  @override
  Future<Either<String, String>> signInWithGoogle() async {
    return const Left('Google sign-in not implemented yet');
  }

  @override
  Future<Either<String, String>> signInWithApple() async {
    return const Left('Apple sign-in not implemented yet');
  }

  @override
  Future<Either<String, void>> signOut() async {
    await _auth.signOut();
    return const Right(null);
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}