import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_local_data_source.dart';
import '../datasources/schedule_remote_data_source.dart';
import '../dtos/schedule_dto.dart';

part 'schedule_repository_impl.g.dart';

@riverpod
IScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  return ScheduleRepositoryImpl(
    ref.watch(scheduleLocalDataSourceProvider),
    ref.watch(scheduleRemoteDataSourceProvider),
    ref.watch(syncServiceProvider),
    ref,
  );
}

class ScheduleRepositoryImpl implements IScheduleRepository {
  final ScheduleLocalDataSource _localDataSource;
  final ScheduleRemoteDataSource _remoteDataSource;
  final SyncService _syncService;
  final ScheduleRepositoryRef _ref;

  ScheduleRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._syncService,
    this._ref,
  );

  // Check if user is authenticated
  bool get _isOnline {
    final authState = _ref.read(authProvider);
    return authState.value != null;
  }

  @override
  Future<Either<Failure, ScheduleEntity>> createSchedule(ScheduleEntity schedule) async {
    try {
      // Always save locally first (offline-first)
      final localResult = await _localDataSource.createSchedule(schedule);
      
      // If online and authenticated, also save to server
      if (_isOnline) {
        try {
          final dto = await _remoteDataSource.createSchedule(
            localResult.toCreateRequest(),
          );
          // Update local record with server ID
          await _localDataSource.markAsSynced(localResult.id, dto.id.toString());
        } catch (e) {
          // Server failed, but local save succeeded - this is OK for offline-first
          // Schedule will sync later
        }
      }
      
      return right(localResult);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getAllSchedules() async {
    try {
      // Try to fetch from server if online
      if (_isOnline) {
        try {
          final dtos = await _remoteDataSource.getSchedules();
          // TODO: Merge with local data (sync logic)
          // For now, just return server data
          return right(dtos.map((dto) => dto.toEntity()).toList());
        } catch (e) {
          // Server failed, fall back to local
        }
      }
      
      // Return local data
      final result = await _localDataSource.getAllSchedules();
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEntity>>> getSchedulesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Try server first if online
      if (_isOnline) {
        try {
          final dtos = await _remoteDataSource.getSchedulesByDateRange(start, end);
          return right(dtos.map((dto) => dto.toEntity()).toList());
        } catch (e) {
          // Fall back to local
        }
      }
      
      final result = await _localDataSource.getSchedulesByDateRange(start, end);
      return right(result);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> updateSchedule(ScheduleEntity schedule) async {
    try {
      // Update locally first
      final localResult = await _localDataSource.updateSchedule(schedule);
      
      // If online and has server ID, update on server
      if (_isOnline && schedule.serverId != null) {
        try {
          await _remoteDataSource.updateSchedule(
            int.parse(schedule.serverId!),
            schedule.toCreateRequest(),
          );
        } catch (e) {
          // Server update failed, but local succeeded
        }
      }
      
      return right(localResult);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) async {
    try {
      // Soft delete locally
      await _localDataSource.deleteSchedule(id);
      
      // If online, delete from server
      // TODO: Get server ID from local record
      
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<ScheduleEntity>> watchSchedules() {
    // Always watch local data for reactive UI
    return _localDataSource.watchSchedules();
  }

  @override
  Future<Either<Failure, void>> syncSchedules() async {
    try {
      if (!_isOnline) {
        return left(const NetworkFailure('Cannot sync while offline'));
      }
      
      await _syncService.syncAll();
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
