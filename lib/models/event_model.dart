import 'dart:convert';
import 'package:flutter/material.dart';

class EventModel {
  String id;
  String title;
  String description;
  DateTime dateTime;
  Duration duration;
  int colorValue;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.duration,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'dateTime': dateTime.toIso8601String(),
    'durationMins': duration.inMinutes,
    'colorValue': colorValue,
  };

  factory EventModel.fromMap(Map<String, dynamic> m) {
    return EventModel(
      id: m['id'],
      title: m['title'],
      description: m['description'],
      dateTime: DateTime.parse(m['dateTime']),
      duration: Duration(minutes: (m['durationMins'] as num).toInt()),
      colorValue: (m['colorValue'] as num).toInt(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory EventModel.fromJson(String s) => EventModel.fromMap(jsonDecode(s));
}
