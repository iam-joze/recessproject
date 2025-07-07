import 'package:flutter/material.dart';

class RentalPreferencesScreen extends StatelessWidget {
  const RentalPreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Preferences'),
      ),
      body: const Center(
        child: Text('This is the Rental Preferences screen (Phase 2)'),
      ),
    );
  }
}