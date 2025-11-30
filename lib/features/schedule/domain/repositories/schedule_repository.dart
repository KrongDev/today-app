import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/schedule_entity.dart';

abstract class IScheduleRepository {
  // Local CRUD
  Future<Either<Failure, ScheduleEntity>> createSchedule(ScheduleEntity schedule);
  Future<Either<Failure, List<ScheduleEntity>>> getAllSchedules();
  Future<Either<Failure, List<ScheduleEntity>>> getSchedulesByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, ScheduleEntity>> updateSchedule(ScheduleEntity schedule);
  Future<Either<Failure, void>> deleteSchedule(String id);
  
  // Reactive
  Stream<List<ScheduleEntity>> watchSchedules();
  
  // Sync (to be implemented in Phase 3.3)
  Future<Either<Failure, void>> syncSchedules();
}
