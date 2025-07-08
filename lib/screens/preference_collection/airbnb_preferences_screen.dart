import 'package:flutter/material.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/widgets/custom_text_field.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add intl dependency for date formatting
import 'package:housingapp/screens/listings_display_screen.dart'; // Future import

class AirbnbPreferencesScreen extends StatefulWidget {
  const AirbnbPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<AirbnbPreferencesScreen> createState() => _AirbnbPreferencesScreenState();
}

class _AirbnbPreferencesScreenState extends State<AirbnbPreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();

  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  Map<String, bool> _amenities = {
    'wifi': false,
    'kitchen': false,
    'ac': false,
    'pool': false,
    'gym': false,
    'parking': false,
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill if existing preferences are available
    final preferences = Provider.of<UserPreferences>(context, listen: false);
    _locationController.text = preferences.location ?? '';
    _minBudgetController.text = preferences.minBudget?.toString() ?? '';
    _maxBudgetController.text = preferences.maxBudget?.toString() ?? '';
    _guestsController.text = preferences.guests?.toString() ?? '1';
    _checkInDate = preferences.checkInDate;
    _checkOutDate = preferences.checkOutDate;
    _amenities = preferences.airbnbAmenities.isEmpty
        ? _amenities // Use default if no preferences are set
        : Map.from(preferences.airbnbAmenities); // Copy map
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _guestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isCheckIn ? _checkInDate : _checkOutDate) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Ensure check-out is after check-in
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
          // Ensure check-in is before check-out
          if (_checkInDate != null && _checkInDate!.isAfter(_checkOutDate!)) {
            _checkInDate = null;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airbnb Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where and when are you traveling?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _locationController,
                hintText: 'Preferred location (e.g., Entebbe, Jinja)',
                prefixIcon: const Icon(Icons.location_on),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a preferred location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: CustomTextField(
                    hintText: _checkInDate == null
                        ? 'Check-in Date'
                        : DateFormat('yyyy-MM-dd').format(_checkInDate!),
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (_checkInDate == null) {
                        return 'Please select a check-in date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: CustomTextField(
                    hintText: _checkOutDate == null
                        ? 'Check-out Date'
                        : DateFormat('yyyy-MM-dd').format(_checkOutDate!),
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (_checkOutDate == null) {
                        return 'Please select a check-out date';
                      }
                      if (_checkInDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
                        return 'Check-out date must be after check-in date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _guestsController,
                hintText: 'Number of Guests',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.group),
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                    return 'Please enter a valid number of guests';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Budget Range (UGX / Night)',
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
                'Amenities',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              ..._amenities.keys.map((amenity) {
                return CheckboxListTile(
                  title: Text(amenity[0].toUpperCase() + amenity.substring(1)), // Capitalize first letter
                  value: _amenities[amenity],
                  onChanged: (bool? value) {
                    setState(() {
                      _amenities[amenity] = value!;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Find My Airbnb',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final preferences = Provider.of<UserPreferences>(context, listen: false);
                    preferences.updateLocation(_locationController.text);
                    preferences.updateBudgetRange(
                      min: double.tryParse(_minBudgetController.text),
                      max: double.tryParse(_maxBudgetController.text),
                    );
                    preferences.updateAirbnbDetails(
                      checkIn: _checkInDate!,
                      checkOut: _checkOutDate!,
                      guests: int.parse(_guestsController.text),
                      amenities: _amenities,
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