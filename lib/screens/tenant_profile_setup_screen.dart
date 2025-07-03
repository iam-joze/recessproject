import 'package:flutter/material.dart';

class TenantProfileSetupScreen extends StatefulWidget {
  const TenantProfileSetupScreen({super.key});

  @override
  State<TenantProfileSetupScreen> createState() => _TenantProfileSetupScreenState();
}

class _TenantProfileSetupScreenState extends State<TenantProfileSetupScreen> {
  final TextEditingController _locationController = TextEditingController();
  double _minRent = 0;
  double _maxRent = 500000; // Example

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Profile setup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tell us about your preferences',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            //Location Preference Input
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Preferred Location (e.g Kampala, Entebbe)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 30),

            // Budget/Prize Range Slider
            Text(
              'Budget/Price Range: UGX ${_minRent.toInt()} - UGX ${_maxRent.toInt()}/month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            RangeSlider(
              values: RangeValues(_minRent, _maxRent),
              min: 0,
              max: 10000000,
              divisions: 100,
              labels: RangeLabels(
                _minRent.toInt().toString(), 
                _maxRent.toInt().toString(),
              ), 
              onChanged: (RangeValues values) {
                setState(() {
                  _minRent = values.start.roundToDouble();
                  _maxRent = values.end.roundToDouble();
                });
              },
            ),
            const SizedBox(height: 10),

            // House Type Selection
            Text(
              'House Type:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 10, // Horizontal Spacing
              runSpacing: 5, // Vertical spacing
              children: _houseTypes.map((type) {
                return ChoiceChip(
                  label: Text(type), 
                  selected: _selectedHouseTypes.contains(type),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedHouseTypes.add(type);
                      } else {
                        _selectedHouseTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList()
            ),

            const SizedBox(height: 40),

            // Save Preferences Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Todo: Save preferences to a backed or local storage
                  print('Location: ${_locationController.text}');
                  print('Min Rent: UGX $_minRent');
                  print('Max Rent: $_maxRent');
                  print('Selected Hoouse Types: $_selectedHouseTypes');
                  // Todo: Navigate to home screen (tenant view)
                  print('Save preferences pressed');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ), 
                child: const Text('Save Preferences', style: TextStyle(fontSize: 18),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
