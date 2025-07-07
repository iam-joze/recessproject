import 'package:flutter/material.dart';

class PermanentHomePreferencesScreen extends StatelessWidget {
  const PermanentHomePreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permanent Home Preferences'),
      ),
      body: const Center(
        child: Text('This is the Permanent Home Preferences screen (Phase 2)'),
      ),
    );
  }
}