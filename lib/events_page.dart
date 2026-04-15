import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import 'event_detail_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<EventModel> _events = [];
  final String _storageKey = "events_storage_v1";

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];

    _events.clear();
    _events.addAll(raw.map((e) => EventModel.fromJson(e)));

    setState(() {});
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _events.map((e) => e.toJson()).toList();
    await prefs.setStringList(_storageKey, list);
  }

  Future<void> _addEvent() async {
    final event = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "",
      description: "",
      dateTime: DateTime.now(),
      duration: const Duration(hours: 1),
      colorValue: Colors.blue.value,
    );

    final result = await Navigator.push<EventModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(event: event, isNew: true),
      ),
    );

    if (result != null) {
      setState(() => _events.add(result));
      await _saveEvents();
    }
  }

  Future<void> _editEvent(EventModel e) async {
    final result = await Navigator.push<EventModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailPage(event: e, isNew: false),
      ),
    );

    if (result != null) {
      final i = _events.indexWhere((x) => x.id == result.id);
      if (i != -1) {
        setState(() => _events[i] = result);
        await _saveEvents();
      }
    }
  }

  Future<void> _deleteEvent(EventModel e) async {
    setState(() => _events.removeWhere((x) => x.id == e.id));
    await _saveEvents();
  }

  Widget _buildCard(EventModel e) {
    final color = Color(e.colorValue);

    return Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteEvent(e),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () => _editEvent(e),
          leading: Container(
            width: 6,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          title: Text(
            e.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(e.description),
              const SizedBox(height: 6),
              Text(
                "${e.dateTime.year}-${e.dateTime.month}-${e.dateTime.day} "
                    "${e.dateTime.hour.toString().padLeft(2, '0')}:${e.dateTime.minute.toString().padLeft(2, '0')}",
              ),
              Text("Duration: ${e.duration.inHours}h ${e.duration.inMinutes % 60}m"),
            ],
          ),
          trailing: const Icon(Icons.edit),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addEvent),
        ],
      ),
      body: _events.isEmpty
          ? const Center(child: Text("No events. Add one +"))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (_, i) => _buildCard(_events[i]),
      ),
    );
  }
}
