import 'package:flutter/material.dart';
import 'main.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  bool dark = false;

  @override
  Widget build(BuildContext context) {
    final themeState = MyApp.of(context);
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SwitchListTile(
        title: const Text("Dark Mode"),
        value: isDarkNow,
        onChanged: (v) => themeState?.toggleTheme(v),
      ),
    );
  }
}
