// ignore_for_file: null_check_always_fails, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/services/property_service.dart'; // Import the PropertyService
// REMOVE THIS LINE: import 'package:housingapp/services/mock_property_service.dart';
import 'package:housingapp/widgets/listing_card.dart';
import 'package:housingapp/screens/property_detail_screen.dart';

class SavedPropertiesScreen extends StatefulWidget {
  const SavedPropertiesScreen({super.key});

  @override
  State<SavedPropertiesScreen> createState() => _SavedPropertiesScreenState();
}

class _SavedPropertiesScreenState extends State<SavedPropertiesScreen> {
  // Removed _savedProperties state variable as StreamBuilder will handle the list

  // We no longer need _loadSavedProperties, _onPreferencesChanged,
  // didChangeDependencies, or dispose for managing the stream.
  // The StreamBuilder will handle listening for changes to properties from Firestore,
  // and Provider.of<UserPreferences> (listen: true) in the build method
  // will react to changes in savedPropertyIds.

  @override
  Widget build(BuildContext context) {
    // Listen to UserPreferences to react to changes in savedPropertyIds
    final userPreferences = Provider.of<UserPreferences>(context);
    final propertyService = Provider.of<PropertyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Properties'),
      ),
      body: StreamBuilder<List<Property>>(
        stream: propertyService.getPropertiesStream(), // Get ALL properties from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading properties: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No properties available in the database.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please check your Firestore setup.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Filter properties based on user's savedPropertyIds
          final allProperties = snapshot.data!;
          final List<String> savedIds = userPreferences.savedPropertyIds;

          final filteredSavedProperties = allProperties
              .where((property) => savedIds.contains(property.id))
              .toList();

          if (filteredSavedProperties.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredSavedProperties.length,
            itemBuilder: (context, index) {
              final property = filteredSavedProperties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ListingCard(
                  property: property,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PropertyDetailScreen(property: property)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}