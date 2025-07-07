import 'package:flutter/material.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/screens/preference_collection/permanent_home_preferences_screen.dart'; // Future import
import 'package:housingapp/screens/preference_collection/rental_preferences_screen.dart'; // Future import
import 'package:housingapp/screens/preference_collection/airbnb_preferences_screen.dart'; // Future import
import 'package:housingapp/models/user_preferences.dart'; // Import UserPreferences
import 'package:provider/provider.dart';

class HousingTypeSelectionScreen extends StatefulWidget {
  const HousingTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<HousingTypeSelectionScreen> createState() => _HousingTypeSelectionScreenState();
}

class _HousingTypeSelectionScreenState extends State<HousingTypeSelectionScreen> {
  String? _selectedHousingType; // To hold the selected type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Housing Type'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'What kind of home are you looking for?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildHousingTypeCard(
                context,
                'Permanent Home',
                Icons.house,
                'permanent',
              ),
              const SizedBox(height: 20),
              _buildHousingTypeCard(
                context,
                'Rental',
                Icons.apartment,
                'rental',
              ),
              const SizedBox(height: 20),
              _buildHousingTypeCard(
                context,
                'Airbnb',
                Icons.bed,
                'airbnb',
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Next',
                onPressed: _selectedHousingType == null
                    ? null // If null, the button will be disabled
                    : () {
                        // Save selected housing type using Provider
                        Provider.of<UserPreferences>(context, listen: false).updateHousingType(
                          _selectedHousingType!,
                        );

                        // Navigate based on selection (we'll create these screens in Phase 2)
                        if (_selectedHousingType == 'permanent') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PermanentHomePreferencesScreen()),
                          );
                        } else if (_selectedHousingType == 'rental') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RentalPreferencesScreen()),
                          );
                        } else if (_selectedHousingType == 'airbnb') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AirbnbPreferencesScreen()),
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

  Widget _buildHousingTypeCard(
      BuildContext context, String title, IconData icon, String typeValue) {
    bool isSelected = _selectedHousingType == typeValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHousingType = typeValue;
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}