import 'package:flutter/material.dart';
import 'daily_tasks_page.dart';
import 'events_page.dart';
import 'quotes_screen.dart';
import 'settings_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int index = 0;

  final pages =  [
    DailyTasksPage(),
    EventsPage(),
    QuotesScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: "Quotes"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}
