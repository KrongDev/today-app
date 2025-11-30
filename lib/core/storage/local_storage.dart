import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/schedule/data/models/schedule_model.dart';

part 'local_storage.g.dart';

@riverpod
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  return Isar.open(
    [ScheduleModelSchema],
    directory: dir.path,
  );
}
