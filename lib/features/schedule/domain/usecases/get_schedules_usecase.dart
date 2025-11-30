import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule_entity.dart';

part 'get_schedules_usecase.g.dart';

@riverpod
GetSchedulesUseCase getSchedulesUseCase(GetSchedulesUseCaseRef ref) {
  return GetSchedulesUseCase(ref.watch(scheduleRepositoryProvider));
}

class GetSchedulesUseCase {
  final scheduleRepository;

  GetSchedulesUseCase(this.scheduleRepository);

  Stream<List<ScheduleEntity>> execute() {
    return scheduleRepository.watchSchedules();
  }

  Future<List<ScheduleEntity>> getByDateRange(DateTime start, DateTime end) async {
    final result = await scheduleRepository.getSchedulesByDateRange(start, end);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (schedules) => schedules,
    );
  }
}
