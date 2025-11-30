import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/schedule_model.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_local_data_source.g.dart';

@riverpod
ScheduleLocalDataSource scheduleLocalDataSource(ScheduleLocalDataSourceRef ref) {
  return ScheduleLocalDataSource(ref.watch(isarProvider).value!);
}

class ScheduleLocalDataSource {
  final Isar _isar;
  final _uuid = const Uuid();

  ScheduleLocalDataSource(this._isar);

  // Create
  Future<ScheduleEntity> createSchedule(ScheduleEntity entity) async {
    final model = ScheduleModel.fromEntity(entity.copyWith(
      id: entity.id.isEmpty ? _uuid.v4() : entity.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDirty: true,
    ));

    await _isar.writeTxn(() async {
      await _isar.scheduleModels.put(model);
    });

    return model.toEntity();
  }

  // Read All
  Future<List<ScheduleEntity>> getAllSchedules() async {
    final models = await _isar.scheduleModels
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    
    return models.map((m) => m.toEntity()).toList();
  }

  // Read by Date Range
  Future<List<ScheduleEntity>> getSchedulesByDateRange(DateTime start, DateTime end) async {
    final models = await _isar.scheduleModels
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .startTimeBetween(start, end)
        .findAll();
    
    return models.map((m) => m.toEntity()).toList();
  }

  // Watch schedules (reactive)
  Stream<List<ScheduleEntity>> watchSchedules() {
    return _isar.scheduleModels
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  // Update
  Future<ScheduleEntity> updateSchedule(ScheduleEntity entity) async {
    final existingModel = await _isar.scheduleModels
        .where()
        .filter()
        .localIdEqualTo(entity.id)
        .findFirst();

    if (existingModel == null) {
      throw Exception('Schedule not found');
    }

    final updatedModel = ScheduleModel.fromEntity(entity.copyWith(
      updatedAt: DateTime.now(),
      version: entity.version + 1,
      isDirty: true,
    ))..id = existingModel.id;

    await _isar.writeTxn(() async {
      await _isar.scheduleModels.put(updatedModel);
    });

    return updatedModel.toEntity();
  }

  // Delete (soft delete)
  Future<void> deleteSchedule(String localId) async {
    final model = await _isar.scheduleModels
        .where()
        .filter()
        .localIdEqualTo(localId)
        .findFirst();

    if (model != null) {
      model.isDeleted = true;
      model.isDirty = true;
      model.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.scheduleModels.put(model);
      });
    }
  }

  // Get dirty schedules (for sync)
  Future<List<ScheduleEntity>> getDirtySchedules() async {
    final models = await _isar.scheduleModels
        .where()
        .filter()
        .isDirtyEqualTo(true)
        .findAll();
    
    return models.map((m) => m.toEntity()).toList();
  }

  // Get schedule by server ID
  Future<ScheduleEntity?> getScheduleByServerId(String serverId) async {
    final model = await _isar.scheduleModels
        .where()
        .filter()
        .serverIdEqualTo(serverId)
        .findFirst();
    
    return model?.toEntity();
  }

  // Mark as synced
  Future<void> markAsSynced(String localId, String serverId) async {
    final model = await _isar.scheduleModels
        .where()
        .filter()
        .localIdEqualTo(localId)
        .findFirst();

    if (model != null) {
      model.serverId = serverId;
      model.isDirty = false;
      model.syncedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.scheduleModels.put(model);
      });
    }
  }
}
