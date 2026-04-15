// lib/pages/task_detail_page.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:flutter/cupertino.dart';


class TaskDetailPage extends StatefulWidget {
  final TaskModel task;
  final bool isNew;
  const TaskDetailPage({super.key, required this.task, this.isNew = false});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleC;
  late TextEditingController _descC;
  late DateTime _start;
  late Duration _duration;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.task.title);
    _descC = TextEditingController(text: widget.task.description);
    _start = widget.task.startTime;
    _duration = widget.task.duration;
    _color = Color(widget.task.colorValue);
  }

  Future<void> _pickStartTime() async {

    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (t != null) {
      setState(() {
        _start = DateTime(_start.year, _start.month, _start.day, t.hour, t.minute);
      });
    }
  }

  Future<void> _pickDurationIOS() async {
    _color = Color(widget.task.colorValue);
    // showCupertinoModalPopup returns when the sheet is dismissed
    await showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 260,
        // use theme-aware background
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey,
        child: SafeArea(
          top: false,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: _duration, // <-- از _duration استفاده کن
            onTimerDurationChanged: (val) {
              // این تابع در حین چرخش هم فراخوانی می‌شود؛ با setState مقدار را به‌روز کن
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
            Colors.white,          // سفید
            Colors.black,          // مشکی
            Color(0xFFFFC0CB),     // صورتی
            Color(0xFFE4C2C1),     // رزگلد
            Color(0xFF2E8B57),     // یشمی
            Colors.amberAccent,    // انتخاب خودم
            Colors.deepPurple,     // انتخاب خودم
            Colors.lightBlueAccent,

          ].map((c)=> GestureDetector(onTap: ()=> Navigator.pop(context, c), child: CircleAvatar(backgroundColor: c))).toList(),
        ),
      ),
    );
    if (selected != null) setState(()=> _color = selected);
  }

  void _saveAndReturn() {
    final title = _titleC.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title required')));
      return;
    }
    final updated = TaskModel(
      id: widget.task.id,
      title: title,
      description: _descC.text.trim(),
      startTime: _start,
      duration: _duration,
      colorValue: _color.value,
      history: widget.task.history, // keep history
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Task' : 'Edit Task'),
        actions: [IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: _saveAndReturn)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: _titleC, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: _descC, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 12),
            ListTile(title: const Text('Start Time'), subtitle: Text('${_start.hour.toString().padLeft(2,'0')}:${_start.minute.toString().padLeft(2,'0')}'), trailing: const Icon(Icons.access_time), onTap: _pickStartTime),
            ListTile(
              title: Text("Duration"),
              subtitle: Text("${_duration.inHours}h ${_duration.inMinutes % 60}m"),trailing: const Icon(Icons.timer),
              onTap: _pickDurationIOS,
            ),
            ListTile(title: const Text('Color'), trailing: CircleAvatar(backgroundColor: _color), onTap: _pickColor),
          ],
        ),
      ),
    );
  }
}
