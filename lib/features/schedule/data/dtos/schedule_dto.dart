import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_dto.freezed.dart';
part 'schedule_dto.g.dart';

@freezed
class ScheduleDto with _$ScheduleDto {
  const factory ScheduleDto({
    required int id,
    required String title,
    String? details,
    String? location,
    required String startTime,
    required String endTime,
    required String createdAt,
    required String updatedAt,
  }) = _ScheduleDto;

  factory ScheduleDto.fromJson(Map<String, dynamic> json) => _$ScheduleDtoFromJson(json);
}

extension ScheduleDtoX on ScheduleDto {
  ScheduleEntity toEntity() {
    return ScheduleEntity(
      id: '',  // Local ID will be generated
      serverId: id.toString(),
      title: title,
      details: details,
      location: location,
      startTime: DateTime.parse(startTime),
      endTime: DateTime.parse(endTime),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDirty: false,  // From server, so not dirty
      syncedAt: DateTime.now(),
    );
  }
}

@freezed
class CreateScheduleRequest with _$CreateScheduleRequest {
  const factory CreateScheduleRequest({
    required String title,
    String? details,
    String? location,
    required String startTime,
    required String endTime,
  }) = _CreateScheduleRequest;

  factory CreateScheduleRequest.fromJson(Map<String, dynamic> json) => 
      _$CreateScheduleRequestFromJson(json);
}

extension ScheduleEntityX on ScheduleEntity {
  CreateScheduleRequest toCreateRequest() {
    return CreateScheduleRequest(
      title: title,
      details: details,
      location: location,
      startTime: startTime.toIso8601String(),
      endTime: endTime.toIso8601String(),
    );
  }
}
