import 'package:isar/isar.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_model.g.dart';

@collection
class ScheduleModel {
  ScheduleModel();

  Id id = Isar.autoIncrement;
  
  @Index()
  late String localId;              // UUID for local tracking
  
  @Index()
  String? serverId;                 // Server-assigned ID
  
  late int version;                 // For conflict detection
  
  late String title;
  String? details;
  String? location;
  
  @Index()
  late DateTime startTime;
  late DateTime endTime;
  
  late DateTime createdAt;
  late DateTime updatedAt;
  DateTime? syncedAt;
  
  late bool isDirty;
  late bool isDeleted;
  
  // Metadata field for future-proofing
  String? metadata;

  // Convert from Entity to Model
  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel()
      ..localId = entity.id
      ..serverId = entity.serverId
      ..version = entity.version
      ..title = entity.title
      ..details = entity.details
      ..location = entity.location
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..syncedAt = entity.syncedAt
      ..isDirty = entity.isDirty
      ..isDeleted = entity.isDeleted;
  }

  // Convert from Model to Entity
  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: localId,
      serverId: serverId,
      version: version,
      title: title,
      details: details,
      location: location,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      isDirty: isDirty,
      isDeleted: isDeleted,
    );
  }
}
