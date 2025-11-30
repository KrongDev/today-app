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
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info Section
            _buildSection(
              context,
              children: [
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'What are you planning?',
                    prefixIcon: Icon(Icons.title),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Add location',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Time Section
            _buildSection(
              context,
              children: [
                SwitchListTile(
                  title: const Text('All Day'),
                  value: _isAllDay,
                  onChanged: (value) {
                    setState(() {
                      _isAllDay = value;
                    });
                  },
                  secondary: const Icon(Icons.access_time),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(DateFormat('EEEE, MMMM d, y', 'ko_KR').format(_startTime)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _selectDate,
                ),
                if (!_isAllDay) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Starts'),
                          trailing: Text(
                            DateFormat('HH:mm').format(_startTime),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          onTap: _selectStartTime,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Ends'),
                          trailing: Text(
                            DateFormat('HH:mm').format(_endTime),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          onTap: _selectEndTime,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Details Section
            _buildSection(
              context,
              children: [
                TextFormField(
                  controller: _detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add details, notes, or links',
                    prefixIcon: Icon(Icons.notes),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            if (widget.schedule != null)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
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
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Schedule'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

