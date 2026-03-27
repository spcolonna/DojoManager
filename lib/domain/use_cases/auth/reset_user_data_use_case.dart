import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetUserDataUseCase {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  Future<void> execute() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 1 — Borrar todos los estudiantes del dojo del usuario
    final dojos = await _firestore
        .collection('dojos')
        .where('ownerId', isEqualTo: uid)
        .get();

    for (final dojo in dojos.docs) {
      // Borrar estudiantes
      final students = await _firestore
          .collection('students')
          .where('dojoId', isEqualTo: dojo.id)
          .get();
      for (final s in students.docs) {
        await s.reference.delete();
      }
      // Borrar el dojo
      await dojo.reference.delete();
    }

    // 2 — Borrar el perfil/progreso del usuario
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('progress')
        .delete();

    // 3 — Sign out
    await _auth.signOut();
  }
}