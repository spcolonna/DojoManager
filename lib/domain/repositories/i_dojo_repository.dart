import 'package:dartz/dartz.dart';
import '../entities/dojo.dart';

abstract class IDojoRepository {
  Future<Either<String, Dojo>> getDojoById(String dojoId);
  Future<Either<String, List<Dojo>>> getDojosByOwner(String ownerId);
  Future<Either<String, Dojo>> createDojo(Dojo dojo);
  Future<Either<String, Dojo>> updateDojo(Dojo dojo);
}
