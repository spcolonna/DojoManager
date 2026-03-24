import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/dojo.dart';
import '../../domain/entities/student.dart';
import '../../infrastructure/repositories/firebase_dojo_repository.dart';

final _repo = FirebaseDojoRepository();

// ─── DOJO ─────────────────────────────────────────────────────────────────────

final dojoProvider = FutureProvider<Dojo?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final result = await _repo.getDojoByOwner(userId);
  return result.fold((_) => null, (dojo) => dojo);
});

// ─── ESTUDIANTES ──────────────────────────────────────────────────────────────

final studentsProvider = FutureProvider<List<Student>>((ref) async {
  final dojo = await ref.watch(dojoProvider.future);
  if (dojo == null) return [];

  final result = await _repo.getStudentsByDojo(dojo.id);
  return result.fold((_) => [], (list) => list);
});