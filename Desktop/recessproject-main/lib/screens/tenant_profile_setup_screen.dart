import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TenantProfileSetupScreen extends StatefulWidget {
  const TenantProfileSetupScreen({super.key});

  @override
  State<TenantProfileSetupScreen> createState() =>
      _TenantProfileSetupScreenState();
}

class _TenantProfileSetupScreenState extends State<TenantProfileSetupScreen> {
  // State variables for form inputs
  final _locationController = TextEditingController();
  RangeValues _budgetRange = const RangeValues(100000, 2000000);
  final Map<String, bool> _houseTypes = {
    'Apartment': false,
    'House': false,
    'Bedsitter': false,
    'Commercial': false,
  };

  // List of major rental areas in Uganda for autocomplete
  static const List<String> _locationOptions = <String>[
    'Kampala',
    'Entebbe',
    'Kira',
    'Nansana',
    'Makindye',
    'Rubaga',
    'Kawempe',
    'Gulu',
    'Mbarara',
    'Jinja',
  ];

  void _savePreferences() {
    // TODO: Implement logic to save preferences to Firebase/backend
    final selectedTypes = _houseTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print('Saving preferences...');
    print('Location: ${_locationController.text}');
    print(
      'Budget: ${_budgetRange.start.round()} - ${_budgetRange.end.round()}',
    );
    print('House Types: $selectedTypes');

    // Navigate to the tenant's home screen, replacing the setup flow
    context.go('/tenant-home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about your preferences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This will help us find the perfect rental for you.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Location Preference
            const Text(
              'Location Preference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _locationOptions.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                _locationController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'e.g., Kampala',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(height: 24),

            // Budget/Price Range
            const Text(
              'Monthly Budget (UGX)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            RangeSlider(
              values: _budgetRange,
              min: 50000,
              max: 5000000,
              divisions: 100,
              labels: RangeLabels(
                '${_budgetRange.start.round()}',
                '${_budgetRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _budgetRange = values;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: UGX ${_budgetRange.start.round()}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Max: UGX ${_budgetRange.end.round()}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // House Type
            const Text(
              'Type of House',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            ..._houseTypes.keys.map((String key) {
              return CheckboxListTile(
                title: Text(key),
                value: _houseTypes[key],
                onChanged: (bool? value) {
                  setState(() {
                    _houseTypes[key] = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _savePreferences,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
