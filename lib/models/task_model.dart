// lib/models/task_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class TaskModel {
  String id;
  String title;
  String description;
  DateTime startTime;
  Duration duration;
  int colorValue;
  // history: dateString (YYYY-MM-DD) -> progress (0..4)
  Map<String, int> history;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.duration,
    required this.colorValue,
    Map<String, int>? history,
  }) : history = history ?? {};

  // Helper: format date key
  static String dateKeyFor(DateTime dt) =>
      "${dt.year.toString().padLeft(4,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}";

  // get today's progress (0..4)
  int getTodayProgress() {
    final k = dateKeyFor(DateTime.now());
    return history[k] ?? 0;
  }

  // set today's progress and return whether changed
  bool setTodayProgress(int v) {
    final k = dateKeyFor(DateTime.now());
    v = v.clamp(0, 4);
    final prev = history[k] ?? 0;
    if (prev == v) return false;
    history[k] = v;
    return true;
  }

  // ensure today's entry exists (used after midnight reset)
  void ensureTodayEntryExists() {
    final k = dateKeyFor(DateTime.now());
    history.putIfAbsent(k, () => 0);
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'durationMins': duration.inMinutes,
    'colorValue': colorValue,
    'history': history, // map of String->int
  };

  factory TaskModel.fromMap(Map<String, dynamic> m) {
    final rawHistory = (m['history'] ?? {}) as Map;
    final parsedHistory = <String, int>{};
    rawHistory.forEach((k, v) {
      parsedHistory[k.toString()] = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
    });

    return TaskModel(
      id: m['id'] as String,
      title: m['title'] as String,
      description: m['description'] as String,
      startTime: DateTime.parse(m['startTime'] as String),
      duration: Duration(minutes: (m['durationMins'] as num).toInt()),
      colorValue: (m['colorValue'] as num).toInt(),
      history: parsedHistory,
    );
  }

  String toJson() => jsonEncode(toMap());
  factory TaskModel.fromJson(String s) => TaskModel.fromMap(jsonDecode(s));
}
