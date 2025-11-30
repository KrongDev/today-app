import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../dtos/schedule_dto.dart';

part 'schedule_remote_data_source.g.dart';

@riverpod
ScheduleRemoteDataSource scheduleRemoteDataSource(ScheduleRemoteDataSourceRef ref) {
  return ScheduleRemoteDataSource(ref.watch(dioProvider));
}

class ScheduleRemoteDataSource {
  final Dio _dio;

  ScheduleRemoteDataSource(this._dio);

  // Get all schedules
  Future<List<ScheduleDto>> getSchedules() async {
    final response = await _dio.get(ApiConstants.schedules);
    final List<dynamic> data = response.data;
    return data.map((json) => ScheduleDto.fromJson(json)).toList();
  }

  // Get schedules by date range
  Future<List<ScheduleDto>> getSchedulesByDateRange(DateTime start, DateTime end) async {
    final response = await _dio.get(
      ApiConstants.schedules,
      queryParameters: {
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ScheduleDto.fromJson(json)).toList();
  }

  // Create schedule
  Future<ScheduleDto> createSchedule(CreateScheduleRequest request) async {
    final response = await _dio.post(
      ApiConstants.schedules,
      data: request.toJson(),
    );
    return ScheduleDto.fromJson(response.data);
  }

  // Update schedule
  Future<ScheduleDto> updateSchedule(int id, CreateScheduleRequest request) async {
    final response = await _dio.put(
      '${ApiConstants.schedules}/$id',
      data: request.toJson(),
    );
    return ScheduleDto.fromJson(response.data);
  }

  // Delete schedule
  Future<void> deleteSchedule(int id) async {
    await _dio.delete('${ApiConstants.schedules}/$id');
  }

  // Get availability (for friend scheduling)
  Future<Map<String, dynamic>> getAvailability({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _dio.get(
      ApiConstants.availability,
      queryParameters: {
        'userId': userId,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
      },
    );
    return response.data;
  }
}
