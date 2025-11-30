import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_entity.freezed.dart';
part 'schedule_entity.g.dart';

@freezed
class ScheduleEntity with _$ScheduleEntity {
  const factory ScheduleEntity({
    required String id,              // Local UUID
    String? serverId,                // Server-assigned ID (null if not synced)
    @Default(1) int version,         // For optimistic locking
    required String title,
    String? details,
    String? location,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? syncedAt,              // Last successful sync timestamp
    @Default(true) bool isDirty,     // Has local changes not synced
    @Default(false) bool isDeleted,  // Soft delete flag
  }) = _ScheduleEntity;

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) => _$ScheduleEntityFromJson(json);
}
