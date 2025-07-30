import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
// REMOVED: import 'package:housingapp/services/property_service.dart'; // No longer needed for mock data
import 'package:housingapp/services/mock_property_service.dart'; // ADDED: Import the mock service
import 'package:housingapp/widgets/listing_card.dart';
import 'package:housingapp/algorithms/haversine_formula.dart';
import 'package:housingapp/algorithms/matching_algorithm.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:housingapp/widgets/filter_modal.dart';
//import 'package:housingapp/utils/app_styles.dart';

class DiscoverListingsScreen extends StatefulWidget {
  const DiscoverListingsScreen({super.key});

  @override
  State<DiscoverListingsScreen> createState() => _DiscoverListingsScreenState();
}

class _DiscoverListingsScreenState extends State<DiscoverListingsScreen> {
  // These will store the filters applied from the filter modal
  String? _appliedLocationFilter;
  double? _appliedMinBudget;
  double? _appliedMaxBudget;
  String? _appliedHouseType; // Stores permanentHouseType
  bool? _appliedSelfContained;
  bool? _appliedFenced;
  int? _appliedBedrooms;
  int? _appliedBathrooms;
  Map<String, bool> _appliedAmenities = {};

  // State variables for the proximity filter
  String? _appliedReferenceLocationText;
  double? _appliedReferenceLatitude;
  double? _appliedReferenceLongitude;
  double? _appliedRadiusKm;

  // State variable to track if filters have been explicitly applied
  bool _filtersApplied = false;

  // NEW: Store all mock properties and currently filtered properties
  List<Property> _allMockProperties = [];
  List<Property> _displayedProperties = []; // This list will be updated after filtering/scoring

  @override
  void initState() {
    super.initState();
    _loadAndProcessProperties(); // Load mock properties on init
  }

  // NEW: Method to load mock properties and apply initial client-side processing
  void _loadAndProcessProperties() {
    // We need userPreferences to apply initial client-side filters and scoring
    // However, Provider.of can't be called directly in initState.
    // We'll defer the client-side processing until build, or use a FutureBuilder
    // for initial load if _loadMockProperties becomes async and independent of context.

    // For simplicity with mock data, let's load all mock data here.
    // Client-side filtering/scoring will happen in the build method.
    _allMockProperties = MockPropertyService.getMockProperties();

    // Trigger a rebuild to apply initial filters and scoring based on default preferences
    // This will happen when build runs and accesses userPreferences via Provider.of
    setState(() {
      // Just ensure _allMockProperties is loaded
    });
  }

  // Method to show the filter modal
  Future<void> _showFilterModal(UserPreferences userPreferences) async {
    final Map<String, dynamic>? appliedFilters = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: FilterModal(
            housingType: userPreferences.housingType!,
            initialLocation: _appliedLocationFilter,
            initialMinBudget: _appliedMinBudget,
            initialMaxBudget: _appliedMaxBudget,
            initialBedrooms: _appliedBedrooms,
            initialBathrooms: _appliedBathrooms,
            initialPermanentHouseType: _appliedHouseType,
            initialSelfContained: _appliedSelfContained,
            initialFenced: _appliedFenced,
            initialAmenities: _appliedAmenities,
            initialReferenceLocationText: _appliedReferenceLocationText,
            initialReferenceLatitude: _appliedReferenceLatitude,
            initialReferenceLongitude: _appliedReferenceLongitude,
            initialRadiusKm: _appliedRadiusKm,
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
        _appliedHouseType = appliedFilters['permanentHouseType'];
        _appliedSelfContained = appliedFilters['selfContained'];
        _appliedFenced = appliedFilters['fenced'];
        _appliedAmenities = appliedFilters['amenities'] ?? {};

        _appliedReferenceLocationText = appliedFilters['referenceLocationText'];
        _appliedReferenceLatitude = appliedFilters['referenceLatitude'];
        _appliedReferenceLongitude = appliedFilters['longitude']; // Corrected to 'longitude' from 'referenceLongitude' assuming key name match
        _appliedRadiusKm = appliedFilters['radiusKm'];

        _filtersApplied = true;
      });

      // Update user preferences (if they are meant to persist filters)
      userPreferences.updateLocation(_appliedLocationFilter);
      userPreferences.updateBudgetRange(min: _appliedMinBudget, max: _appliedMaxBudget);
      userPreferences.updateBedrooms(_appliedBedrooms);
      userPreferences.updateBathrooms(_appliedBathrooms);

      if (userPreferences.housingType == 'permanent') {
        userPreferences.updateHouseType(_appliedHouseType);
        userPreferences.updateRentalDetails(selfContained: null, fenced: null);
        userPreferences.updateAirbnbDetails(amenities: {});
      } else if (userPreferences.housingType == 'rental') {
        userPreferences.updateRentalDetails(
          selfContained: _appliedSelfContained,
          fenced: _appliedFenced,
        );
        userPreferences.updateHouseType(null);
        userPreferences.updateAirbnbDetails(amenities: {});
      } else if (userPreferences.housingType == 'airbnb') {
        userPreferences.updateAirbnbDetails(
          amenities: _appliedAmenities,
        );
        userPreferences.updateHouseType(null);
        userPreferences.updateRentalDetails(selfContained: null, fenced: null);
      }
      // The `build` method will automatically re-run and call _applyClientSideFiltersAndScore
      // with the updated state variables and user preferences.
    }
  }

  // This method encapsulates the client-side filtering and scoring
  List<Property> _applyClientSideFiltersAndScore(List<Property> properties, UserPreferences userPreferences) {
    List<Property> currentFilteredProperties = List.from(properties);

    // Apply primary property type filter first
    currentFilteredProperties = currentFilteredProperties.where((property) =>
      property.type == userPreferences.housingType
    ).toList();


    if (_filtersApplied && properties.isNotEmpty) {
      currentFilteredProperties = currentFilteredProperties.where((property) {
        // All filters below must match if explicitly applied
        bool matchesAllCurrentFilters = true;

        // 1. General Location Filter
        if (_appliedLocationFilter != null && _appliedLocationFilter!.isNotEmpty) {
          if (!property.location.toLowerCase().contains(_appliedLocationFilter!.toLowerCase())) {
            matchesAllCurrentFilters = false;
          }
        }

        // 2. Budget Filter
        if (_appliedMinBudget != null && property.price < _appliedMinBudget!) {
          matchesAllCurrentFilters = false;
        }
        if (_appliedMaxBudget != null && property.price > _appliedMaxBudget!) {
          matchesAllCurrentFilters = false;
        }

        // 3. Bedrooms Filter
        if (_appliedBedrooms != null && property.bedrooms < _appliedBedrooms!) {
          matchesAllCurrentFilters = false;
        }

        // 4. Bathrooms Filter
        if (_appliedBathrooms != null && property.bathrooms < _appliedBathrooms!) {
          matchesAllCurrentFilters = false;
        }

        // 5. Type-specific dynamic filtering
        if (userPreferences.housingType == 'permanent') {
          if (_appliedHouseType != null && property.houseType != null &&
              _appliedHouseType!.toLowerCase() != property.houseType!.toLowerCase()) {
            matchesAllCurrentFilters = false;
          }
        } else if (userPreferences.housingType == 'rental') {
          if (_appliedSelfContained != null && property.selfContained != null &&
              _appliedSelfContained! != property.selfContained!) {
            matchesAllCurrentFilters = false;
          }
          if (_appliedFenced != null && property.fenced != null &&
              _appliedFenced! != property.fenced!) {
            matchesAllCurrentFilters = false;
          }
        } else if (userPreferences.housingType == 'airbnb') {
          if (_appliedAmenities.isNotEmpty) {
            bool allSelectedAmenitiesPresent = true;
            _appliedAmenities.forEach((amenityKey, isSelected) {
              if (isSelected && (property.amenities == null || property.amenities![amenityKey] != true)) {
                allSelectedAmenitiesPresent = false;
              }
            });
            if(!allSelectedAmenitiesPresent) {
              matchesAllCurrentFilters = false;
            }
          }
        }
        return matchesAllCurrentFilters;
      }).toList();
    }

    // Proximity Filter (applied after all other filters)
    if (_appliedReferenceLatitude != null && _appliedReferenceLongitude != null && _appliedRadiusKm != null) {
      List<Property> proximityFiltered = [];
      for (var property in currentFilteredProperties) {
        double distance = HaversineFormula.calculateDistance(
          _appliedReferenceLatitude!,
          _appliedReferenceLongitude!,
          property.latitude,
          property.longitude,
        );
        Property updatedProperty = property.copyWith(distanceKm: distance); // Update distanceKm
        if (distance <= _appliedRadiusKm!) {
          proximityFiltered.add(updatedProperty);
        }
      }
      currentFilteredProperties = proximityFiltered;
    } else {
      // If proximity filter is NOT applied, ensure distanceKm is null
      currentFilteredProperties = currentFilteredProperties.map((property) =>
          property.copyWith(distanceKm: null)
      ).toList();
    }

    // Apply Match Score and Sorting (only if filters were applied by user)
    List<Property> propertiesWithScores = [];
    if (_filtersApplied) {
      for (var property in currentFilteredProperties) {
        double score = MatchingAlgorithm.calculateMatchScore(userPreferences, property);
        propertiesWithScores.add(property.copyWith(matchScore: score));
      }
      // Sort by match score in descending order
      propertiesWithScores.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    } else {
      // If no filters applied, clear match scores
      propertiesWithScores = currentFilteredProperties.map((property) =>
          property.copyWith(matchScore: null)
      ).toList();
    }

    // Sort by price (ascending) if no match score sorting is active
    // This is a default sort if no other specific sorting (like by match score) is present
    propertiesWithScores.sort((a, b) => a.price.compareTo(b.price));


    return propertiesWithScores;
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    // REMOVED: final propertyService = Provider.of<PropertyService>(context); // No longer needed

    // Re-apply client-side filters and scoring every time build runs
    // (e.g., when _appliedFilters or userPreferences change)
    _displayedProperties = _applyClientSideFiltersAndScore(_allMockProperties, userPreferences);


    return Scaffold(
      appBar: AppBar(
        title: Text('${userPreferences.housingType![0].toUpperCase() + userPreferences.housingType!.substring(1)} Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterModal(userPreferences),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _filtersApplied = false; // Reset filter state
                _appliedLocationFilter = null;
                _appliedMinBudget = null;
                _appliedMaxBudget = null;
                _appliedBedrooms = null;
                _appliedBathrooms = null;
                _appliedHouseType = null;
                _appliedSelfContained = null;
                _appliedFenced = null;
                _appliedAmenities = {};
                _appliedReferenceLocationText = null;
                _appliedReferenceLatitude = null;
                _appliedReferenceLongitude = null;
                _appliedRadiusKm = null;
                // Reload mock data and re-process it
                _loadAndProcessProperties();
              });
              // Also reset user preferences to default if the refresh button is meant for a full reset
              userPreferences.updateLocation(null);
              userPreferences.updateBudgetRange(min: null, max: null);
              userPreferences.updateBedrooms(null);
              userPreferences.updateBathrooms(null);
              userPreferences.updateHouseType(null);
              userPreferences.updateRentalDetails(selfContained: null, fenced: null);
              userPreferences.updateAirbnbDetails(amenities: {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // Use a conditional check for _displayedProperties
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
                          'Try adjusting your filters.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _displayedProperties.length,
                    itemBuilder: (context, index) {
                      final property = _displayedProperties[index];
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
                  ),
          ),
        ],
      ),
    );
  }
}