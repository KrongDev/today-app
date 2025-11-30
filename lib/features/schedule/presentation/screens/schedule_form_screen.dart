import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final ScheduleEntity? schedule;
  final DateTime? initialDate;

  const ScheduleFormScreen({
    super.key,
    this.schedule,
    this.initialDate,
  });

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _detailsController.text = widget.schedule!.details ?? '';
      _locationController.text = widget.schedule!.location ?? '';
      _startTime = widget.schedule!.startTime;
      _endTime = widget.schedule!.endTime;
    } else if (widget.initialDate != null) {
      _startTime = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
        DateTime.now().hour,
        (DateTime.now().minute ~/ 15) * 15,
      );
      _endTime = _startTime.add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          picked.hour,
          picked.minute,
        );
        if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime),
    );
    if (picked != null) {
      setState(() {
        _endTime = DateTime(
          _endTime.year,
          _endTime.month,
          _endTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startTime.hour,
          _startTime.minute,
        );
        _endTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endTime.hour,
          _endTime.minute,
        );
      });
    }
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      if (widget.schedule != null) {
        // Update existing schedule
        ref.read(schedulesProvider.notifier).updateSchedule(
              widget.schedule!.copyWith(
                title: _titleController.text,
                details: _detailsController.text.isEmpty ? null : _detailsController.text,
                location: _locationController.text.isEmpty ? null : _locationController.text,
                startTime: _isAllDay
                    ? DateTime(_startTime.year, _startTime.month, _startTime.day)
                    : _startTime,
                endTime: _isAllDay
                    ? DateTime(_endTime.year, _endTime.month, _endTime.day, 23, 59)
                    : _endTime,
                updatedAt: DateTime.now(),
              ),
            );
      } else {
        // Create new schedule
        ref.read(schedulesProvider.notifier).createSchedule(
              title: _titleController.text,
              details: _detailsController.text.isEmpty ? null : _detailsController.text,
              location: _locationController.text.isEmpty ? null : _locationController.text,
              startTime: _isAllDay
                  ? DateTime(_startTime.year, _startTime.month, _startTime.day)
                  : _startTime,
              endTime: _isAllDay
                  ? DateTime(_endTime.year, _endTime.month, _endTime.day, 23, 59)
                  : _endTime,
            );
      }
      
      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.schedule != null ? 'Edit Schedule' : 'New Schedule'),
        actions: [
          TextButton(
            onPressed: _saveSchedule,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter schedule title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // All Day Toggle
            SwitchListTile(
              title: const Text('All Day'),
              subtitle: const Text('Schedule lasts all day'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date Selection
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEEE, MMMM d, y', 'ko_KR').format(_startTime)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _selectDate,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Time Selection (if not all day)
            if (!_isAllDay) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Start Time'),
                  subtitle: Text(DateFormat('HH:mm').format(_startTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectStartTime,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time_filled),
                  title: const Text('End Time'),
                  subtitle: Text(DateFormat('HH:mm').format(_endTime)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectEndTime,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter location',
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 24),
            
            // Details/Notes
            TextFormField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Details',
                hintText: 'Add notes or details',
                prefixIcon: Icon(Icons.note),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Schedule'),
              ),
            ),
            
            if (widget.schedule != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Schedule'),
                        content: const Text('Are you sure you want to delete this schedule?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true && context.mounted) {
                      await ref.read(schedulesProvider.notifier).deleteSchedule(widget.schedule!.id);
                      if (context.mounted) {
                        context.pop();
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete Schedule'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

