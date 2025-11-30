import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../entities/schedule_entity.dart';

part 'create_schedule_usecase.g.dart';

@riverpod
CreateScheduleUseCase createScheduleUseCase(CreateScheduleUseCaseRef ref) {
  return CreateScheduleUseCase(ref.watch(scheduleRepositoryProvider));
}

class CreateScheduleUseCase {
  final scheduleRepository;

  CreateScheduleUseCase(this.scheduleRepository);

  Future<void> execute(ScheduleEntity schedule) async {
    await scheduleRepository.createSchedule(schedule);
  }
}
