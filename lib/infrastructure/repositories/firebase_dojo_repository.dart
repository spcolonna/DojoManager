import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/dojo.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/weekly_plan.dart';
import '../../domain/use_cases/training/generate_learning_coefficients.dart';
import '../../domain/value_objects/student_stats.dart';
import '../../domain/value_objects/belt.dart';

class FirebaseDojoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ─── USER PROGRESS ────────────────────────────────────────────────────────

  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('progress')
          .get();

      if (!doc.exists) {
        return UserProgress(userId: userId, onboardingCompleted: false);
      }
      return UserProgress.fromMap(userId, doc.data()!);
    } catch (e) {
      return UserProgress(userId: userId, onboardingCompleted: false);
    }
  }

  Future<void> markOnboardingCompleted(String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('progress')
        .set({
      'onboardingCompleted': true,
      'createdAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // ─── DOJO ─────────────────────────────────────────────────────────────────

  Future<Either<String, Dojo?>> getDojoByOwner(String ownerId) async {
    try {
      final query = await _db
          .collection('dojos')
          .where('ownerId', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return const Right(null);
      final doc = query.docs.first;
      return Right(Dojo.fromMap({...doc.data(), 'id': doc.id}));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Dojo>> createDojo({
    required String ownerId,
    required String name,
    required String styleId,
    required int startingMD,
  }) async {
    try {
      final id  = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      final dojo = Dojo(
        id: id,
        ownerId: ownerId,
        name: name,
        styleId: styleId,
        level: 1,
        md: startingMD,
        gm: 0,
        unlockedUpgradeIds: [],
        maxStudentSlots: 2,
        currentSeason: 1,
        currentWeek: 1,
        hasActiveMasterPass: false,
      );

      await _db.collection('dojos').doc(id).set({
        ...dojo.toMap(),
        'createdAt': now,
      });

      return Right(dojo);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Dojo>> updateDojo(Dojo dojo) async {
    try {
      await _db.collection('dojos').doc(dojo.id).update(dojo.toMap());
      return Right(dojo);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ─── STUDENTS ─────────────────────────────────────────────────────────────

  Future<Either<String, List<Student>>> getStudentsByDojo(
      String dojoId) async {
    try {
      final query = await _db
          .collection('students')
          .where('dojoId', isEqualTo: dojoId)
          .get();

      final students = query.docs
          .map((d) => Student.fromMap({...d.data(), 'id': d.id}))
          .toList();

      return Right(students);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Student>> createStudent(Student student) async {
    try {
      final id = _uuid.v4();
      final s  = student.copyWith(id: id);
      await _db.collection('students').doc(id).set(s.toMap());
      return Right(s);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, Student>> updateStudent(Student student) async {
    try {
      await _db
          .collection('students')
          .doc(student.id)
          .update(student.toMap());
      return Right(student);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ─── ECONOMÍA ─────────────────────────────────────────────────────────────

  Future<void> addMD(String dojoId, int amount) async {
    await _db.collection('dojos').doc(dojoId).update({
      'md': FieldValue.increment(amount),
    });
  }

  Future<void> spendMD(String dojoId, int amount) async {
    await _db.collection('dojos').doc(dojoId).update({
      'md': FieldValue.increment(-amount),
    });
  }

  Future<void> addGems(String dojoId, int amount) async {
    await _db.collection('dojos').doc(dojoId).update({
      'gm': FieldValue.increment(amount),
    });
  }

  Future<void> spendGems(String dojoId, int amount) async {
    await _db.collection('dojos').doc(dojoId).update({
      'gm': FieldValue.increment(-amount),
    });
  }

  // ─── WEEKLY PLAN ──────────────────────────────────────────────────────────

  Future<WeeklyPlan?> getWeeklyPlan(String dojoId) async {
    try {
      final doc = await _db
          .collection('dojos')
          .doc(dojoId)
          .collection('weekly')
          .doc('current')
          .get();
      if (!doc.exists) return null;
      return WeeklyPlan.fromMap(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWeeklyPlan(String dojoId, WeeklyPlan plan) async {
    await _db
        .collection('dojos')
        .doc(dojoId)
        .collection('weekly')
        .doc('current')
        .set(plan.toMap());
  }

  Future<void> clearWeeklyPlan(String dojoId) async {
    await _db
        .collection('dojos')
        .doc(dojoId)
        .collection('weekly')
        .doc('current')
        .delete();
  }

// ─── TOURNAMENT STATE ─────────────────────────────────────────────────────

  Future<void> saveTournamentState(String dojoId, Map<String, dynamic> data) async {
    await _db
        .collection('dojos')
        .doc(dojoId)
        .collection('tournament')
        .doc('current')
        .set(data);
  }

  Future<Map<String, dynamic>?> getTournamentState(String dojoId) async {
    try {
      final doc = await _db
          .collection('dojos')
          .doc(dojoId)
          .collection('tournament')
          .doc('current')
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ─── FICHAR ESTUDIANTE DESDE OFERTA ──────────────────────────────────────

  Future<void> createStudentFromOffer({
    required String dojoId,
    required String name,
    required String styleId,
    required int beltLevel,
    required StudentStats stats,
  }) async {
    final coeffGen = GenerateLearningCoefficients();
    final id = _uuid.v4();
    final student = Student(
      id: id,
      dojoId: dojoId,
      nameKey: name,
      avatarAsset: '',
      styleId: styleId,
      belt: Belt(level: beltLevel),
      currentXP: 0,
      stats: stats,
      tier: beltLevel >= 7
          ? StudentTier.platinum
          : beltLevel >= 5
          ? StudentTier.gold
          : StudentTier.silver,
      skillPoints: beltLevel * 3,
      unlockedNodeIds: [],
      fatiguePercent: 0,
      isInjured: false,
      injuryWeeksRemaining: 0,
      learningCoefficients: coeffGen.execute(id),
    );

    await createStudent(student);
  }

  // ─── MENSAJES ─────────────────────────────────────────────────────────────

  Future<List<AppMessage>> getMessages(String userId) async {
    try {
      final query = await _db
          .collection('users')
          .doc(userId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs
          .map((d) => AppMessage.fromMap({...d.data(), 'id': d.id}))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addMessage(String userId, AppMessage message) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<void> markMessageRead(String userId, String messageId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // ─── HELPER: crear los 2 estudiantes iniciales ────────────────────────────

  Future<void> createStartingStudents({
    required String dojoId,
    required String styleId,
  }) async {
    final zhangStats = StudentStats(
      str: 12, spd: 10, tec: 8, def: 9, men: 10, res: 50,
    );
    final keikoStats = StudentStats(
      str: 8, spd: 11, tec: 12, def: 9, men: 10, res: 50,
    );

    final coeffGen = GenerateLearningCoefficients();

    final zhangId = _uuid.v4();
    final zhang = Student(
      id: zhangId,
      dojoId: dojoId,
      nameKey: 'Zhang Wei',
      avatarAsset: 'assets/images/students/student_zhang_wei_portrait.png',
      styleId: styleId,
      belt: const Belt(level: 1),
      currentXP: 0,
      stats: zhangStats,
      tier: StudentTier.silver,
      skillPoints: 0,
      unlockedNodeIds: [],
      fatiguePercent: 0,
      isInjured: false,
      injuryWeeksRemaining: 0,
      learningCoefficients: coeffGen.execute(zhangId),
    );

    final keikoId = _uuid.v4();
    final keiko = Student(
      id: keikoId,
      dojoId: dojoId,
      nameKey: 'Keiko Mori',
      avatarAsset: 'assets/images/students/student_keiko_mori_portrait.png',
      styleId: styleId,
      belt: const Belt(level: 1),
      currentXP: 0,
      stats: keikoStats,
      tier: StudentTier.silver,
      skillPoints: 0,
      unlockedNodeIds: [],
      fatiguePercent: 0,
      isInjured: false,
      injuryWeeksRemaining: 0,
      learningCoefficients: coeffGen.execute(keikoId),
    );

    await createStudent(zhang);
    await createStudent(keiko);
  }
}