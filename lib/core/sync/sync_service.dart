import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/schedule/data/datasources/schedule_local_data_source.dart';
import '../../features/schedule/data/datasources/schedule_remote_data_source.dart';
import '../../features/schedule/data/dtos/schedule_dto.dart';
import '../../features/schedule/domain/entities/schedule_entity.dart';
import '../logging/logger.dart';

part 'sync_service.g.dart';

@riverpod
SyncService syncService(SyncServiceRef ref) {
  return SyncService(
    ref.watch(scheduleLocalDataSourceProvider),
    ref.watch(scheduleRemoteDataSourceProvider),
  );
}

class SyncService {
  final ScheduleLocalDataSource _localDataSource;
  final ScheduleRemoteDataSource _remoteDataSource;

  SyncService(this._localDataSource, this._remoteDataSource);

  /// Sync all schedules with server
  Future<void> syncAll() async {
    try {
      Logger.d('Starting sync...');
      
      // Push local changes first
      await _pushLocalChanges();
      
      // Then pull server changes
      await _pullServerChanges();
      
      Logger.d('Sync completed successfully');
    } catch (e) {
      Logger.e('Sync failed: $e');
      rethrow;
    }
  }

  /// Push local dirty records to server
  Future<void> _pushLocalChanges() async {
    try {
      // Get all dirty (unsynced) schedules
      final dirtySchedules = await _localDataSource.getDirtySchedules();
      
      if (dirtySchedules.isEmpty) {
        Logger.d('No local changes to push');
        return;
      }
      
      Logger.d('Pushing ${dirtySchedules.length} local changes');
      
      for (final schedule in dirtySchedules) {
        try {
          if (schedule.isDeleted) {
            // Delete on server if it has a serverId
            if (schedule.serverId != null) {
              await _remoteDataSource.deleteSchedule(int.parse(schedule.serverId!));
            }
            // Remove from local DB
            await _localDataSource.deleteSchedule(schedule.id);
          } else if (schedule.serverId == null) {
            // Create new on server
            final dto = await _remoteDataSource.createSchedule(
              schedule.toCreateRequest(),
            );
            // Update local with server ID and mark as synced
            await _localDataSource.markAsSynced(schedule.id, dto.id.toString());
          } else {
            // Update existing on server
            await _remoteDataSource.updateSchedule(
              int.parse(schedule.serverId!),
              schedule.toCreateRequest(),
            );
            // Mark as synced
            await _localDataSource.markAsSynced(schedule.id, schedule.serverId!);
          }
        } catch (e) {
          Logger.e('Failed to sync schedule ${schedule.id}: $e');
          // Continue with other schedules
        }
      }
    } catch (e) {
      Logger.e('Push failed: $e');
      rethrow;
    }
  }

  /// Pull server changes since last sync
  Future<void> _pullServerChanges() async {
    try {
      // Get all schedules from server
      final serverSchedules = await _remoteDataSource.getSchedules();
      
      Logger.d('Pulled ${serverSchedules.length} schedules from server');
      
      for (final dto in serverSchedules) {
        try {
          final entity = dto.toEntity();
          
          // Check if exists locally
          final existing = await _localDataSource.getScheduleByServerId(
            entity.serverId!,
          );
          
          if (existing == null) {
            // New from server, create locally
            await _localDataSource.createSchedule(entity.copyWith(isDirty: false));
          } else {
            // Exists locally - use Last Write Wins based on updatedAt
            if (entity.updatedAt.isAfter(existing.updatedAt)) {
              // Server is newer, update local
              await _localDataSource.updateSchedule(
                entity.copyWith(id: existing.id, isDirty: false),
              );
            }
            // If local is newer and dirty, it will be pushed in next sync
          }
        } catch (e) {
          Logger.e('Failed to process server schedule: $e');
          // Continue with other schedules
        }
      }
    } catch (e) {
      Logger.e('Pull failed: $e');
      rethrow;
    }
  }
}
