import 'package:flutter/material.dart';

class TenantProfileSetupScreen extends StatefulWidget {
  const TenantProfileSetupScreen({super.key});

  @override
  State<TenantProfileSetupScreen> createState() => _TenantProfileSetupScreenState();
}

class _TenantProfileSetupScreenState extends State<TenantProfileSetupScreen> {
  final TextEditingController _locationController = TextEditingController();
  double _minRent = 0;
  double maxRent = 500000; // Example

  // List of house types for selection
  final List<String> _houseTypes = [
    'Apartment',
    'House',
    'bedsitter',
    'Commercial',
  ];
  final List<String> _selectedHouseTypes = [];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}