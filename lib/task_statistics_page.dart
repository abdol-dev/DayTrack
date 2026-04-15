// lib/pages/task_statistics_page.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'dart:math';

class TaskStatisticsPage extends StatelessWidget {
  final TaskModel task;
  const TaskStatisticsPage({super.key, required this.task});

  // returns list of pairs (dateKey, value) for last n days (oldest->newest)
  List<MapEntry<String,int>> lastNDays(int n) {
    final now = DateTime.now();
    final list = <MapEntry<String,int>>[];
    for (int i = n - 1; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final k = TaskModel.dateKeyFor(d);
      list.add(MapEntry(k, task.history[k] ?? 0));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final data7 = lastNDays(7);
    final data30 = lastNDays(30);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text('Statistics - ${task.title}'), bottom: const TabBar(tabs: [Tab(text:'7 days'), Tab(text:'30 days')])),
        body: TabBarView(
          children: [
            _buildChart(context, data7),
            _buildChart(context, data30),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<MapEntry<String,int>> data) {
    final maxVal = 3.0;
    final values = data.map((e)=> e.value.toDouble()).toList();
    final labels = data.map((e){
      final parts = e.key.split('-');
      return '${parts[1]}/${parts[2]}';
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // bar chart
          Expanded(
            child: CustomPaint(
              painter: _BarChartPainter(values: values, labels: labels, maxVal: maxVal),
              child: Container(),
            ),
          ),
          const SizedBox(height: 12),
          // legend and average
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Average: ${_avg(values).toStringAsFixed(2)} / $maxVal'),
              Text('Recorded days: ${values.where((v)=> v>0).length}'),
            ],
          ),
        ],
      ),
    );
  }

  double _avg(List<double> v) => v.isEmpty ? 0.0 : v.reduce((a,b)=> a+b)/v.length;
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxVal;
  _BarChartPainter({required this.values, required this.labels, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blueAccent;
    final w = size.width;
    final h = size.height;
    final barWidth = (w / (values.length * 1.6)).clamp(6.0, 40.0);
    final gap = (w - barWidth * values.length) / (values.length + 1);
    final topPadding = 12.0;
    final bottomPadding = 28.0;
    final usableH = h - topPadding - bottomPadding;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < values.length; i++) {
      final val = values[i].clamp(0.0, maxVal);
      final left = gap + i * (barWidth + gap);
      final barH = (val / maxVal) * usableH;
      final rect = Rect.fromLTWH(left, topPadding + (usableH - barH), barWidth, barH);
      // bar with rounded top
      final rrect = RRect.fromRectAndCorners(rect, topLeft: const Radius.circular(6), topRight: const Radius.circular(6));
      final grad = LinearGradient(colors: [Colors.blueAccent.withOpacity(0.9), Colors.blueAccent.withOpacity(0.5)], begin: Alignment.topCenter, end: Alignment.bottomCenter);
      final paintBar = Paint()..shader = grad.createShader(rect);
      canvas.drawRRect(rrect, paintBar);

      // label (bottom)
      final label = labels[i];
      textPainter.text = TextSpan(text: label, style: const TextStyle(color: Colors.black54, fontSize: 10));
      textPainter.layout(maxWidth: barWidth*1.5);
      final lp = Offset(left + (barWidth - textPainter.width)/2, h - bottomPadding + 6);
      textPainter.paint(canvas, lp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
