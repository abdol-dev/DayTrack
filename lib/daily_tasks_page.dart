// lib/pages/daily_tasks_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'task_detail_page.dart';
import 'task_statistics_page.dart';
import '../widgets/status_emoji_picker.dart';




class DailyTasksPage extends StatefulWidget {
  const DailyTasksPage({super.key});
  @override
  State<DailyTasksPage> createState() => _DailyTasksPageState();
}

class _DailyTasksPageState extends State<DailyTasksPage> {
  final List<TaskModel> _tasks = [];
  final String _storageKey = 'daily_tasks_v2';
  final String _lastResetKey = 'last_reset_date_v2';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }
  Color _backgroundFromPercent(double p) {
    // p بین 0 و 1
    int r, g, b = 0;

    if (p <= 0.5) {
      // قرمز → زرد
      double t = p / 0.5; // 0..1
      r = 255;
      g = (255 * t).toInt();
      b = 0;
    } else {
      // زرد → سبز
      double t = (p - 0.5) / 0.5;
      r = (255 * (1 - t)).toInt();
      g = 255;
      b = 0;
    }

    return Color.fromARGB(255, r, g, b);
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    _tasks.clear();
    _tasks.addAll(raw.map((e) => TaskModel.fromJson(e)));
    // check last reset date
    final last = prefs.getString(_lastResetKey);
    final todayKey = TaskModel.dateKeyFor(DateTime.now());
    if (last != todayKey) {
      // it's a new day (or never set): ensure today's entry exists for each task
      for (final t in _tasks) {
        t.history[todayKey] = 0;
      }
      await prefs.setString(_lastResetKey, todayKey);
      await _saveAll();
    } else {
      // ensure today's entry exists (in case a task added later)
      for (final t in _tasks) {
        t.ensureTodayEntryExists();
      }
    }
    setState(() {});
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_storageKey, list);
  }

  Future<void> _addNewTask() async {
    // create a template and open TaskDetailPage for editing
    final t = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Task',
      description: '',
      startTime: DateTime.now(),
      duration: const Duration(minutes: 60),
      colorValue: Colors.blue.value,
    );
    final res = await Navigator.push<TaskModel?>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailPage(task: t, isNew: true)),
    );
    if (res != null) {
      // ensure today's entry
      res.history[TaskModel.dateKeyFor(DateTime.now())] = 0;
      setState(() => _tasks.add(res));
      await _saveAll();
    }
  }

  Future<void> _editTask(TaskModel t) async {
    final res = await Navigator.push<TaskModel?>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailPage(task: t, isNew: false)),
    );
    if (res != null) {
      final idx = _tasks.indexWhere((x) => x.id == res.id);
      if (idx != -1) {
        setState(() => _tasks[idx] = res);
        await _saveAll();
      }
    }
  }

  Future<void> _deleteTask(TaskModel t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${t.title}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _tasks.removeWhere((x) => x.id == t.id));
      await _saveAll();
    }
  }

  // set today's progress for a task
  Future<void> _setTodayProgress(TaskModel t, int progress) async {
    t.history[TaskModel.dateKeyFor(DateTime.now())] = progress.clamp(0, 3);
    await _saveAll();
    setState(() {});
  }

  // compute today's overall percent (sum of today's progress / (tasks * 4))
  double _todayPercent() {
    if (_tasks.isEmpty) return 0.0;
    final totalPossible = _tasks.length * 3;
    int gained = 0;
    final key = TaskModel.dateKeyFor(DateTime.now());
    for (final t in _tasks) {
      gained += (t.history[key] ?? 0);
    }
    return totalPossible == 0 ? 0.0 : (gained / totalPossible);
  }

  Widget _buildTaskCard(TaskModel t) {
    final todayKey = TaskModel.dateKeyFor(DateTime.now());
    t.history.putIfAbsent(todayKey, () => 0);
    final todayProgress = t.history[todayKey] ?? 0;
    final color = Color(t.colorValue);
    return Dismissible(
      key: Key(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTask(t),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.12), Theme.of(context).cardColor],
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,6))],
        ),
        child: ListTile(
          onTap: () => _editTask(t),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 56, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
            ],
          ),
          title: Text(t.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text('${t.startTime.hour.toString().padLeft(2,'0')}:${t.startTime.minute.toString().padLeft(2,'0')}  •  ${t.duration.inHours}h ${t.duration.inMinutes % 60}m', style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              // progress ticks
              StatusEmojiPicker(
                value: todayProgress,
                onChanged: (newValue) {
                  _setTodayProgress(t, newValue);
                },
              ),

            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.bar_chart_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskStatisticsPage(task: t)))),
              IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _editTask(t)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = (_todayPercent() * 100).round();
    final p = _todayPercent();
    final baseColor = _backgroundFromPercent(p);
    final bgColor = baseColor.withOpacity(0.3); // شفافیت 20٪ برای هایلایت ملایم


    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), // مدت زمان انیمیشن
      curve: Curves.easeInOut, // انیمیشن نرم
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Scaffold شفاف
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.1),
          elevation: 0,
          title: const Text('Daily Tasks'),
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _addNewTask),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () async { await _loadAll(); }),
          ],
        ),
        body: SafeArea(
          child: Column(

            children: [
            // summary card with circular percent
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // circular percent
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: CustomPaint(
                      painter: _CircleProgressPainter(progress: _todayPercent()),
                      child: Center(child: Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('${_tasks.length} tasks • ${(_todayPercent()*100).toStringAsFixed(1)} %', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {
                    // overview statistics: navigate to a summary page (optional)
                    Navigator.push(context, MaterialPageRoute(builder: (_) => _OverviewStatsPage(tasks: _tasks)));
                  }),
                ],
              ),
            ),

            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks yet. Add one with +', style: TextStyle(color: Colors.grey[600])))
                  : ListView.builder(itemCount: _tasks.length, itemBuilder: (_, i) => _buildTaskCard(_tasks[i])),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// ---------------- Custom painter for circular percent ----------------
class _CircleProgressPainter extends CustomPainter {
  final double progress; // 0..1
  _CircleProgressPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.12;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    final bgPaint = Paint()..color = Colors.grey.withOpacity(0.12)..style = PaintingStyle.stroke..strokeWidth = stroke;
    final fgPaint = Paint()..color = Colors.deepPurple..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    final sweep = 2 * 3.1415926535 * (progress.clamp(0.0, 1.0));
    final start = -3.1415926535 / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ---------------- Overview stats page (simple) ----------------
class _OverviewStatsPage extends StatelessWidget {
  final List<TaskModel> tasks;
  const _OverviewStatsPage({required this.tasks, super.key});

  @override
  Widget build(BuildContext context) {
    final key = TaskModel.dateKeyFor(DateTime.now());
    final totalPossible = tasks.length * 3;
    int gained = 0;
    for (final t in tasks) gained += (t.history[key] ?? 0);
    final pct = totalPossible == 0 ? 0.0 : gained / totalPossible;
    return Scaffold(
      appBar: AppBar(title: const Text('Overview')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: 140, height: 140, child: CustomPaint(painter: _CircleProgressPainter(progress: pct), child: Center(child: Text('${(pct*100).round()}%')))),
          const SizedBox(height: 12),
          Text('${tasks.length} tasks • $gained / $totalPossible ticks'),
        ]),
      ),
    );
  }
}
