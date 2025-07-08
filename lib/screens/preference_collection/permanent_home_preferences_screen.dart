import 'package:flutter/material.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/widgets/custom_text_field.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/screens/listings_display_screen.dart'; // Future import

class PermanentHomePreferencesScreen extends StatefulWidget {
  const PermanentHomePreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PermanentHomePreferencesScreen> createState() => _PermanentHomePreferencesScreenState();
}

class _PermanentHomePreferencesScreenState extends State<PermanentHomePreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  String? _selectedHouseType;

  final List<String> _houseTypes = ['Bungalow', 'Apartment', 'Villa', 'Condo', 'Land'];

  @override
  void initState() {
    super.initState();
    // Pre-fill if existing preferences are available
    final preferences = Provider.of<UserPreferences>(context, listen: false);
    _locationController.text = preferences.location ?? '';
    _minBudgetController.text = preferences.minBudget?.toString() ?? '';
    _maxBudgetController.text = preferences.maxBudget?.toString() ?? '';
    _selectedHouseType = preferences.houseType;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permanent Home Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us about your dream home:',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _locationController,
                hintText: 'Preferred region or city (e.g., Kampala, Entebbe)',
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a preferred location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Budget Range (UGX)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _minBudgetController,
                      hintText: 'Min. Budget',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.money),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _maxBudgetController,
                      hintText: 'Max. Budget',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.money),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'House Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedHouseType,
                hint: const Text('Select House Type'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _houseTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHouseType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a house type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Find My Permanent Home',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final preferences = Provider.of<UserPreferences>(context, listen: false);
                    preferences.updateLocation(_locationController.text);
                    preferences.updateBudgetRange(
                      min: double.tryParse(_minBudgetController.text),
                      max: double.tryParse(_maxBudgetController.text),
                    );
                    preferences.updateHouseType(_selectedHouseType!);

                    // Navigate to listings screen (we'll build this next)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListingsDisplayScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}