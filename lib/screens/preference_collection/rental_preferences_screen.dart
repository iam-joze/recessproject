import 'package:flutter/material.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/widgets/custom_text_field.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/screens/listings_display_screen.dart'; // Future import

class RentalPreferencesScreen extends StatefulWidget {
  const RentalPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<RentalPreferencesScreen> createState() => _RentalPreferencesScreenState();
}

class _RentalPreferencesScreenState extends State<RentalPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  String? _selectedRoomType;
  bool _isSelfContained = false;
  bool _isFenced = false;

  final List<String> _roomTypes = ['Studio', '1-Bedroom', '2-Bedroom', '3-Bedroom', '4+ Bedrooms', 'Single Room'];

  @override
  void initState() {
    super.initState();
    // Pre-fill if existing preferences are available
    final preferences = Provider.of<UserPreferences>(context, listen: false);
    _locationController.text = preferences.location ?? '';
    _minBudgetController.text = preferences.minBudget?.toString() ?? '';
    _maxBudgetController.text = preferences.maxBudget?.toString() ?? '';
    _selectedRoomType = preferences.roomType;
    _isSelfContained = preferences.selfContained ?? false;
    _isFenced = preferences.fenced ?? false;
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
        title: const Text('Rental Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What are you looking for in a rental?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _locationController,
                hintText: 'Preferred location (e.g., Nansana, Ntinda)',
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
                'Monthly Budget (UGX)',
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
                'Room Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                hint: const Text('Select Room Type'),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _roomTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRoomType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a room type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SwitchListTile(
                title: Text('Self-contained', style: Theme.of(context).textTheme.titleLarge),
                value: _isSelfContained,
                onChanged: (bool value) {
                  setState(() {
                    _isSelfContained = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Fenced Compound', style: Theme.of(context).textTheme.titleLarge),
                value: _isFenced,
                onChanged: (bool value) {
                  setState(() {
                    _isFenced = value;
                  });
                },
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Find My Rental',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final preferences = Provider.of<UserPreferences>(context, listen: false);
                    preferences.updateLocation(_locationController.text);
                    preferences.updateBudgetRange(
                      min: double.tryParse(_minBudgetController.text),
                      max: double.tryParse(_maxBudgetController.text),
                    );
                    preferences.updateRentalDetails(
                      roomType: _selectedRoomType!,
                      selfContained: _isSelfContained,
                      fenced: _isFenced,
                    );

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