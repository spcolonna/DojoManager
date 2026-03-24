import 'package:dartz/dartz.dart';
import '../entities/student.dart';

abstract class IStudentRepository {
  Future<Either<String, List<Student>>> getStudentsByDojo(String dojoId);
  Future<Either<String, Student>> getStudentById(String studentId);
  Future<Either<String, Student>> createStudent(Student student);
  Future<Either<String, Student>> updateStudent(Student student);
  Future<Either<String, void>> deleteStudent(String studentId);
  Future<Either<String, List<Student>>> getMarketStudents(int dojoLevel);
}
