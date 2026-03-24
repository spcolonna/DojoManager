import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/i_student_repository.dart';

class FirebaseStudentRepository implements IStudentRepository {
  final FirebaseFirestore _db;

  FirebaseStudentRepository(this._db);

  @override
  Future<Either<String, List<Student>>> getStudentsByDojo(String dojoId) async {
    try {
      final snap = await _db
          .collection('students')
          .where('dojoId', isEqualTo: dojoId)
          .get();
      final students = snap.docs
          .map((d) => Student.fromMap(d.data()..['id'] = d.id))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Student>> getStudentById(String studentId) async {
    try {
      final doc = await _db.collection('students').doc(studentId).get();
      if (!doc.exists) return const Left('student_not_found');
      return Right(Student.fromMap(doc.data()!..['id'] = doc.id));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Student>> saveStudent(Student student) async {
    try {
      await _db.collection('students').doc(student.id).set(student.toMap());
      return Right(student);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> deleteStudent(String studentId) async {
    try {
      await _db.collection('students').doc(studentId).delete();
      return const Right(true);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Student>>> getMarketCandidates({
    required String dojoId,
    required int maxBeltLevel,
  }) async {
    try {
      final snap = await _db
          .collection('market_students')
          .where('beltLevel', isLessThanOrEqualTo: maxBeltLevel)
          .limit(20)
          .get();
      final students = snap.docs
          .map((d) => Student.fromMap(d.data()..['id'] = d.id))
          .toList();
      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
