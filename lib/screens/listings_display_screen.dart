import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/services/mock_property_service.dart';
import 'package:housingapp/widgets/listing_card.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // For location
import 'package:permission_handler/permission_handler.dart'; // For permission handling
import 'package:housingapp/algorithms/haversine_formula.dart'; // For distance calculation
import 'package:housingapp/algorithms/matching_algorithm.dart'; // For matching score
import 'package:housingapp/screens/property_detail_screen.dart'; // For navigating to detail view

class ListingsDisplayScreen extends StatefulWidget {
  const ListingsDisplayScreen({Key? key}) : super(key: key);

  @override
  State<ListingsDisplayScreen> createState() => _ListingsDisplayScreenState();
}

class _ListingsDisplayScreenState extends State<ListingsDisplayScreen> {
  List<Property> _availableProperties = [];
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _useGPSFilter = false; // Toggle for GPS filtering
  final double _gpsFilterRadiusKm = 10.0; // Hardcoded radius for now

  @override
  void initState() {
    super.initState();
    // Ensure this method is called with the correct name
    _fetchAndFilterAndScoreProperties();
  }

  // Consolidated method to fetch, filter, and score properties
  Future<void> _fetchAndFilterAndScoreProperties() async {
    final userPreferences = Provider.of<UserPreferences>(context, listen: false);
    List<Property> allProperties = MockPropertyService.getMockProperties();
    List<Property> filteredProperties = [];

    // 1. Filter by housing type
    filteredProperties = allProperties.where((property) {
      return property.type == userPreferences.housingType;
    }).toList();

    // 2. Apply basic preference filtering (from Phase 2)
    filteredProperties = filteredProperties.where((property) {
      bool matches = true;

      // Location match (basic string contains check for now)
      // This will be superseded by GPS filter when active
      if (!_useGPSFilter && userPreferences.location != null && userPreferences.location!.isNotEmpty) {
        if (!property.location.toLowerCase().contains(userPreferences.location!.toLowerCase())) {
          matches = false;
        }
      }

      // Budget match
      if (userPreferences.minBudget != null && property.price < userPreferences.minBudget!) {
        matches = false;
      }
      if (userPreferences.maxBudget != null && property.price > userPreferences.maxBudget!) {
        matches = false;
      }

      // Type-specific filtering
      if (userPreferences.housingType == 'permanent') {
        if (userPreferences.houseType != null && property.houseType != null &&
            userPreferences.houseType!.toLowerCase() != property.houseType!.toLowerCase()) {
          matches = false;
        }
      } else if (userPreferences.housingType == 'rental') {
        if (userPreferences.roomType != null && property.roomType != null &&
            userPreferences.roomType!.toLowerCase() != property.roomType!.toLowerCase()) {
          matches = false;
        }
        if (userPreferences.selfContained != null && property.selfContained != null &&
            userPreferences.selfContained! != property.selfContained!) {
          matches = false;
        }
        if (userPreferences.fenced != null && property.fenced != null &&
            userPreferences.fenced! != property.fenced!) {
          matches = false;
        }
      } else if (userPreferences.housingType == 'airbnb') {
        // Airbnb filtering will be enhanced in Phase 4 (dates, guests, amenities)
        // For now, basic preference updates are in the user_preferences model.
        // The matching algorithm handles scoring amenities and dates.
      }

      return matches;
    }).toList();


    // 3. Apply GPS filtering if enabled and update distanceKm
    if (_useGPSFilter) {
      await _getCurrentLocation(); // Ensure we have the current location
      if (_currentPosition != null) {
        List<Property> gpsFiltered = [];
        for (var property in filteredProperties) {
          double distance = HaversineFormula.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            property.latitude,
            property.longitude,
          );
          // Update property with distance for display (using copyWith for immutability)
          Property updatedProperty = property.copyWith(distanceKm: distance);
          if (distance <= _gpsFilterRadiusKm) {
            gpsFiltered.add(updatedProperty);
          }
        }
        filteredProperties = gpsFiltered;
      } else {
        // If GPS filter is on but location couldn't be obtained, clear results
        filteredProperties = [];
      }
    } else {
      // Clear distances if GPS filter is off, to prevent stale data
      for (int i = 0; i < filteredProperties.length; i++) {
        filteredProperties[i] = filteredProperties[i].copyWith(distanceKm: null);
      }
    }

    // 4. Calculate and apply Matching Score
    // Iterate through the filtered properties and calculate a score for each
    for (int i = 0; i < filteredProperties.length; i++) {
      double score = MatchingAlgorithm.calculateMatchScore(userPreferences, filteredProperties[i]);
      // Update the property's matchScore using copyWith
      filteredProperties[i] = filteredProperties[i].copyWith(matchScore: score);
    }

    // Sort properties by match score (descending) if GPS filter is not primary or if both are off
    // If GPS filter is active, distance is already implicitly handled by inclusion.
    // For now, we'll sort by score if location is not the primary filter.
    filteredProperties.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));


    setState(() {
      _availableProperties = filteredProperties;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Location services are disabled. Please enable them.';
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Location permissions are denied.';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Location permissions are permanently denied. Please enable from app settings.';
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _locationError = null; // Clear any previous error
    } catch (e) {
      _locationError = 'Failed to get current location: $e';
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: No direct use of userPreferences in build as _fetchAndFilterAndScoreProperties
    // already uses it with listen: false to avoid unnecessary rebuilds.
    // final userPreferences = Provider.of<UserPreferences>(context); // Not needed here, but can be used for displaying preference summary

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAndFilterAndScoreProperties, // Refresh button calls the main method
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search near me (${_gpsFilterRadiusKm}km)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: _useGPSFilter,
                  onChanged: (bool value) async {
                    setState(() {
                      _useGPSFilter = value;
                    });
                    await _fetchAndFilterAndScoreProperties(); // Refetch/refilter/rescore when toggle changes
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(), // Use LinearProgressIndicator for a subtle loading bar
            ),
          if (_locationError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _locationError!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _availableProperties.isEmpty
                ? Center(
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
                          'No properties found for your preferences.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Try adjusting your filters or location settings.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _availableProperties.length,
                    itemBuilder: (context, index) {
                      final property = _availableProperties[index];
                      return ListingCard(
                        property: property,
                        onTap: () {
                          // Navigate to Property Detail Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PropertyDetailScreen(property: property)),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}