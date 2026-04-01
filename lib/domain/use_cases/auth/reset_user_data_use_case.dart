import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetUserDataUseCase {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  Future<void> execute() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

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

      // ← NUEVO: Borrar subcolecciones del dojo
      for (final sub in ['weekly', 'tournament']) {
        final subDocs = await dojo.reference.collection(sub).get();
        for (final d in subDocs.docs) {
          await d.reference.delete();
        }
      }

      await dojo.reference.delete();
    }

    // Borrar perfil
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('progress')
        .delete();

    // ← NUEVO: Borrar mensajes
    final messages = await _firestore
        .collection('users')
        .doc(uid)
        .collection('messages')
        .get();
    for (final m in messages.docs) {
      await m.reference.delete();
    }

    await _auth.signOut();
  }
}