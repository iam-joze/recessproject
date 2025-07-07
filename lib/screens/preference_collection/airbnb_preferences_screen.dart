import 'package:flutter/material.dart';

class AirbnbPreferencesScreen extends StatelessWidget {
  const AirbnbPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airbnb Preferences'),
      ),
      body: const Center(
        child: Text('This is the Airbnb Preferences screen (Phase 2)'),
      ),
    );
  }
}