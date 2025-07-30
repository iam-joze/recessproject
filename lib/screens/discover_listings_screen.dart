import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/services/mock_property_service.dart'; // ADDED: Import the mock service
import 'package:housingapp/widgets/listing_card.dart';
import 'package:housingapp/algorithms/haversine_formula.dart';
import 'package:housingapp/algorithms/matching_algorithm.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:housingapp/widgets/filter_modal.dart';
import 'package:intl/intl.dart'; // Import for number formatting

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
    _allMockProperties = MockPropertyService.getMockProperties();

    // Trigger a rebuild to apply initial filters and scoring based on default preferences
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
        _appliedReferenceLongitude = appliedFilters['referenceLongitude']; // Corrected key name to 'referenceLongitude'
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
    // Instantiate MockPropertyService to use its filtering logic
    final mockPropertyService = MockPropertyService();

    List<Property> currentFilteredProperties = mockPropertyService.getProperties(
      type: userPreferences.housingType,
      location: _appliedLocationFilter,
      minBudget: _appliedMinBudget,
      maxBudget: _appliedMaxBudget,
      bedrooms: _appliedBedrooms,
      bathrooms: _appliedBathrooms,
      permanentHouseType: _appliedHouseType,
      selfContained: _appliedSelfContained,
      fenced: _appliedFenced,
      amenities: _appliedAmenities,
      referenceLatitude: _appliedReferenceLatitude,
      referenceLongitude: _appliedReferenceLongitude,
      radiusKm: _appliedRadiusKm,
    );

    // After getting the filtered properties from the service,
    // apply the match score if filters were explicitly applied by the user.
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

    // Secondary sort by price (ascending) if no match score sorting is active
    // This will act as a tie-breaker or default sort if matchScore is null or equal
    propertiesWithScores.sort((a, b) {
      // First, sort by distanceKm if it's available for both and a proximity filter was applied
      if (_appliedReferenceLatitude != null && _appliedReferenceLongitude != null && _appliedRadiusKm != null && _appliedRadiusKm! > 0) {
        if (a.distanceKm != null && b.distanceKm != null) {
          int distanceComparison = a.distanceKm!.compareTo(b.distanceKm!);
          if (distanceComparison != 0) return distanceComparison;
        }
      }
      // Then, sort by matchScore (descending) if available for both
      if (a.matchScore != null && b.matchScore != null) {
        int scoreComparison = b.matchScore!.compareTo(a.matchScore!);
        if (scoreComparison != 0) return scoreComparison;
      }
      // Finally, sort by price (ascending)
      return a.price.compareTo(b.price);
    });

    return propertiesWithScores;
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);

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
                          // Pass distanceKm to ListingCard if available
                          distanceKm: property.distanceKm,
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