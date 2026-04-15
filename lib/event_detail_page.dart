import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/event_model.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final bool isNew;

  const EventDetailPage({super.key, required this.event, this.isNew = false});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late TextEditingController _titleC;
  late TextEditingController _descC;

  late DateTime _dateTime;
  late Duration _duration;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.event.title);
    _descC = TextEditingController(text: widget.event.description);
    _dateTime = widget.event.dateTime;
    _duration = widget.event.duration;
    _color = Color(widget.event.colorValue);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _dateTime,
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );

    if (time == null) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _pickDuration() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[300],
        child: SafeArea(
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: _duration,
            onTimerDurationChanged: (val) {
              setState(() {
                _duration = val;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickColor() async {
    final selected = await showDialog<Color?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick color'),
        content: Wrap(
          spacing: 8,
          children: [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.pink,
            Colors.amber,
            Colors.deepPurple,
          ]
              .map((c) => GestureDetector(
            onTap: () => Navigator.pop(context, c),
            child: CircleAvatar(backgroundColor: c),
          ))
              .toList(),
        ),
      ),
    );

    if (selected != null) setState(() => _color = selected);
  }

  void _saveAndBack() {
    if (_titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title is required")),
      );
      return;
    }

    final updated = EventModel(
      id: widget.event.id,
      title: _titleC.text.trim(),
      description: _descC.text.trim(),
      dateTime: _dateTime,
      duration: _duration,
      colorValue: _color.value,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? "New Event" : "Edit Event"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndBack,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _titleC, decoration: const InputDecoration(labelText: "Title")),
          const SizedBox(height: 12),
          TextField(controller: _descC, decoration: const InputDecoration(labelText: "Description")),
          const SizedBox(height: 16),

          ListTile(
            title: const Text("Date & Time"),
            subtitle: Text(
              "${_dateTime.year}-${_dateTime.month}-${_dateTime.day}  "
                  "${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}",
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),

          ListTile(
            title: const Text("Duration"),
            subtitle: Text("${_duration.inHours}h ${_duration.inMinutes % 60}m"),
            trailing: const Icon(Icons.timer),
            onTap: _pickDuration,
          ),

          ListTile(
            title: const Text("Color"),
            trailing: CircleAvatar(backgroundColor: _color),
            onTap: _pickColor,
          ),
        ],
      ),
    );
  }
}
