class Task {
  String id;
  String title;
  String description;
  DateTime startTime;
  Duration duration;
  int progress; // 0 to 4
  int colorValue; // Color stored as int

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.duration,
    this.progress = 0,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'duration': duration.inMinutes,
    'progress': progress,
    'colorValue': colorValue,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    startTime: DateTime.parse(map['startTime']),
    duration: Duration(minutes: map['duration']),
    progress: map['progress'],
    colorValue: map['colorValue'],
  );
}
