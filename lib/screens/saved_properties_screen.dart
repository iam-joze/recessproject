import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/services/mock_property_service.dart'; // To fetch property details by ID
import 'package:housingapp/widgets/listing_card.dart';
import 'package:housingapp/screens/property_detail_screen.dart'; // To navigate to detail view

class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  List<Property> _savedProperties = [];

  @override
  void initState() {
    super.initState();
    _loadSavedProperties();
  }

  // Listener to reload properties if saved list changes
  void _onPreferencesChanged() {
    _loadSavedProperties();
  }

  Future<void> _loadSavedProperties() async {
    final userPreferences = Provider.of<UserPreferences>(
      context,
      listen: false,
    );
    final allMockProperties = MockPropertyService.getMockProperties();

    List<Property> currentSavedProperties = [];
    for (String id in userPreferences.savedPropertyIds) {
      try {
        final property = allMockProperties.firstWhere((p) => p.id == id);
        currentSavedProperties.add(property);
      } catch (e) {
        // Property not found, skip it
      }
    }

    setState(() {
      _savedProperties = currentSavedProperties;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add listener when dependencies change (e.g., Provider is available)
    Provider.of<UserPreferences>(
      context,
      listen: true,
    ).addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    Provider.of<UserPreferences>(
      context,
      listen: false,
    ).removeListener(_onPreferencesChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties')),
      body: _savedProperties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No saved properties yet.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Save properties from the listings to view them here!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _savedProperties.length,
              itemBuilder: (context, index) {
                final property = _savedProperties[index];
                return ListingCard(
                  property: property,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailScreen(property: property),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
