import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/services/mock_property_service.dart';
import 'package:housingapp/widgets/listing_card.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:housingapp/algorithms/haversine_formula.dart';
import 'package:housingapp/algorithms/matching_algorithm.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:housingapp/widgets/filter_modal.dart'; // New filter modal widget
// import 'package:housingapp/screens/filter_modal_screen.dart'; // Will create this next

class DiscoverListingsScreen extends StatefulWidget { // Renamed from ListingsDisplayScreen
  const DiscoverListingsScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverListingsScreen> createState() => _DiscoverListingsScreenState(); // Renamed state class
}

class _DiscoverListingsScreenState extends State<DiscoverListingsScreen> { // Renamed state class
  List<Property> _displayedProperties = []; // Renamed from _availableProperties for clarity
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _useGPSFilter = false;
  final double _gpsFilterRadiusKm = 10.0;

  // These will store the filters applied from the new filter modal
  String? _appliedLocationFilter;
  double? _appliedMinBudget;
  double? _appliedMaxBudget;
  String? _appliedHouseType;
  String? _appliedRoomType;
  bool? _appliedSelfContained;
  bool? _appliedFenced;
  int? _appliedBedrooms; // New filter
  int? _appliedBathrooms; // New filter
  int? _appliedMaxGuests; // New filter for Airbnb
  Map<String, bool> _appliedAmenities = {}; // New filter for Airbnb

  @override
  void initState() {
    super.initState();
    _loadAndFilterProperties(); // Updated method name to reflect broader filtering
  }

  // Consolidated method to load, filter, and score properties
  Future<void> _loadAndFilterProperties() async {
    final userPreferences = Provider.of<UserPreferences>(context, listen: false);
    List<Property> allProperties = MockPropertyService.getMockProperties();
    List<Property> currentFilteredProperties = [];

    // --- BASE FILTERING (from initial housing type selection) ---
    currentFilteredProperties = allProperties.where((property) {
      return property.type == userPreferences.housingType;
    }).toList();

    // --- DYNAMIC FILTERING (from filter modal) ---
    currentFilteredProperties = currentFilteredProperties.where((property) {
      bool matches = true;

      // Filter by dynamic location string
      if (_appliedLocationFilter != null && _appliedLocationFilter!.isNotEmpty) {
        if (!property.location.toLowerCase().contains(_appliedLocationFilter!.toLowerCase())) {
          matches = false;
        }
      }

      // Filter by dynamic budget
      if (_appliedMinBudget != null && property.price < _appliedMinBudget!) {
        matches = false;
      }
      if (_appliedMaxBudget != null && property.price > _appliedMaxBudget!) {
        matches = false;
      }

      // Filter by dynamic bedrooms
      if (_appliedBedrooms != null && property.bedrooms < _appliedBedrooms!) {
        matches = false;
      }

      // Filter by dynamic bathrooms
      if (_appliedBathrooms != null && property.bathrooms < _appliedBathrooms!) {
        matches = false;
      }

      // Type-specific dynamic filtering
      if (userPreferences.housingType == 'permanent') {
        if (_appliedHouseType != null && property.houseType != null &&
            _appliedHouseType!.toLowerCase() != property.houseType!.toLowerCase()) {
          matches = false;
        }
      } else if (userPreferences.housingType == 'rental') {
        if (_appliedRoomType != null && property.roomType != null &&
            _appliedRoomType!.toLowerCase() != property.roomType!.toLowerCase()) {
          matches = false;
        }
        if (_appliedSelfContained != null && property.selfContained != null &&
            _appliedSelfContained! != property.selfContained!) {
          matches = false;
        }
        if (_appliedFenced != null && property.fenced != null &&
            _appliedFenced! != property.fenced!) {
          matches = false;
        }
      } else if (userPreferences.housingType == 'airbnb') {
        if (_appliedMaxGuests != null && property.maxGuests != null &&
            _appliedMaxGuests! > property.maxGuests!) {
          matches = false;
        }
        // Filter by amenities (ensure all applied amenities are present)
        if (_appliedAmenities.isNotEmpty) {
          _appliedAmenities.forEach((amenityKey, isSelected) {
            if (isSelected && (property.amenities == null || property.amenities![amenityKey] != true)) {
              matches = false; // Property must have this selected amenity
            }
          });
        }
      }

      return matches;
    }).toList();


    // --- GPS FILTERING (remains the same) ---
    if (_useGPSFilter) {
      await _getCurrentLocation();
      if (_currentPosition != null) {
        List<Property> gpsFiltered = [];
        for (var property in currentFilteredProperties) {
          double distance = HaversineFormula.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            property.latitude,
            property.longitude,
          );
          Property updatedProperty = property.copyWith(distanceKm: distance);
          if (distance <= _gpsFilterRadiusKm) {
            gpsFiltered.add(updatedProperty);
          }
        }
        currentFilteredProperties = gpsFiltered;
      } else {
        currentFilteredProperties = [];
      }
    } else {
      for (int i = 0; i < currentFilteredProperties.length; i++) {
        currentFilteredProperties[i] = currentFilteredProperties[i].copyWith(distanceKm: null);
      }
    }

    // --- MATCHING SCORE CALCULATION (remains the same) ---
    for (int i = 0; i < currentFilteredProperties.length; i++) {
      double score = MatchingAlgorithm.calculateMatchScore(userPreferences, currentFilteredProperties[i]);
      currentFilteredProperties[i] = currentFilteredProperties[i].copyWith(matchScore: score);
    }

    // Sort properties by match score (descending)
    currentFilteredProperties.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));


    setState(() {
      _displayedProperties = currentFilteredProperties; // Update displayed list
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

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
      _locationError = null;
    } catch (e) {
      _locationError = 'Failed to get current location: $e';
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Method to show the filter modal
  Future<void> _showFilterModal() async {
    final Map<String, dynamic>? appliedFilters = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the modal to take full height
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Adjust height as needed
          child: FilterModal( // This widget will be created next
            initialLocation: _appliedLocationFilter,
            initialMinBudget: _appliedMinBudget,
            initialMaxBudget: _appliedMaxBudget,
            initialBedrooms: _appliedBedrooms,
            initialBathrooms: _appliedBathrooms,
            initialHouseType: _appliedHouseType,
            initialRoomType: _appliedRoomType,
            initialSelfContained: _appliedSelfContained,
            initialFenced: _appliedFenced,
            initialMaxGuests: _appliedMaxGuests,
            initialAmenities: _appliedAmenities,
            housingType: Provider.of<UserPreferences>(context, listen: false).housingType!,
          ),
        );
      },
    );

    if (appliedFilters != null) {
      setState(() {
        _appliedLocationFilter = appliedFilters['location'];
        _appliedMinBudget = appliedFilters['minBudget'];
        _appliedMaxBudget = appliedFilters['maxBudget'];
        _appliedBedrooms = appliedFilters['bedrooms'];
        _appliedBathrooms = appliedFilters['bathrooms'];
        _appliedHouseType = appliedFilters['houseType'];
        _appliedRoomType = appliedFilters['roomType'];
        _appliedSelfContained = appliedFilters['selfContained'];
        _appliedFenced = appliedFilters['fenced'];
        _appliedMaxGuests = appliedFilters['maxGuests'];
        _appliedAmenities = appliedFilters['amenities'] ?? {}; // Ensure it's not null
      });
      _loadAndFilterProperties(); // Re-filter properties with new settings
    }
  }


  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context); // Listen to housing type changes if needed elsewhere

    return Scaffold(
      appBar: AppBar(
        title: Text('${userPreferences.housingType![0].toUpperCase() + userPreferences.housingType!.substring(1)} Listings'),
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal, // Calls the new filter modal
          ),
          // GPS Filter Toggle (moved from previous layout)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Near Me',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
              ),
              Switch(
                value: _useGPSFilter,
                onChanged: (bool value) async {
                  setState(() {
                    _useGPSFilter = value;
                  });
                  await _loadAndFilterProperties(); // Refetch/refilter/rescore when toggle changes
                },
                activeColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAndFilterProperties,
          ),
        ],
      ),
      body: Column(
        children: [
          // Removed redundant GPS filter display from body, it's in AppBar actions now
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
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
            child: _displayedProperties.isEmpty
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
                          'No properties found matching your criteria.',
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
                    itemCount: _displayedProperties.length,
                    itemBuilder: (context, index) {
                      final property = _displayedProperties[index];
                      return ListingCard(
                        property: property,
                        onTap: () {
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