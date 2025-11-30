import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_failures.freezed.dart';

@freezed
class ScheduleFailure with _$ScheduleFailure {
  const factory ScheduleFailure.serverError(String message) = _ServerError;
  const factory ScheduleFailure.notFound() = _NotFound;
  const factory ScheduleFailure.networkError() = _NetworkError;
  const factory ScheduleFailure.cacheError(String message) = _CacheError;
  const factory ScheduleFailure.syncConflict() = _SyncConflict;
}
