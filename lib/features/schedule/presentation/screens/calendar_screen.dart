import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../../domain/entities/schedule_entity.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: (day) {
              return schedulesAsync.when(
                data: (schedules) => schedules
                    .where((s) => isSameDay(s.startTime, day))
                    .toList(),
                loading: () => [],
                error: (_, __) => [],
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: schedulesAsync.when(
              data: (schedules) {
                final selectedSchedules = _selectedDay == null
                    ? schedules
                    : schedules
                        .where((s) => isSameDay(s.startTime, _selectedDay!))
                        .toList();

                if (selectedSchedules.isEmpty) {
                  return const Center(
                    child: Text('No schedules for this day'),
                  );
                }

                return ListView.builder(
                  itemCount: selectedSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = selectedSchedules[index];
                    return _ScheduleListItem(schedule: schedule);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context) {
    final titleController = TextEditingController();
    final detailsController = TextEditingController();
    DateTime startTime = _selectedDay ?? DateTime.now();
    DateTime endTime = startTime.add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailsController,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(schedulesProvider.notifier).createSchedule(
                    title: titleController.text,
                    details: detailsController.text,
                    startTime: startTime,
                    endTime: endTime,
                  );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleListItem extends ConsumerWidget {
  final ScheduleEntity schedule;

  const _ScheduleListItem({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(schedule.title),
      subtitle: Text(schedule.details ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          ref.read(schedulesProvider.notifier).deleteSchedule(schedule.id);
        },
      ),
    );
  }
}
