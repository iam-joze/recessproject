import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/services/mock_property_service.dart';
import 'package:housingapp/widgets/listing_card.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/algorithms/haversine_formula.dart';
import 'package:housingapp/algorithms/matching_algorithm.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:housingapp/widgets/filter_modal.dart';

class DiscoverListingsScreen extends StatefulWidget {
  const DiscoverListingsScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverListingsScreen> createState() => _DiscoverListingsScreenState();
}

class _DiscoverListingsScreenState extends State<DiscoverListingsScreen> {
  List<Property> _displayedProperties = [];

  // These will store the filters applied from the new filter modal
  String? _appliedLocationFilter;
  double? _appliedMinBudget;
  double? _appliedMaxBudget;
  String? _appliedHouseType; // Stores permanentHouseType
  bool? _appliedSelfContained;
  bool? _appliedFenced;
  int? _appliedBedrooms;
  int? _appliedBathrooms;
  // REMOVED: int? _appliedMaxGuests;
  Map<String, bool> _appliedAmenities = {};

  // NEW: State variables for the proximity filter
  String? _appliedReferenceLocationText;
  double? _appliedReferenceLatitude;
  double? _appliedReferenceLongitude;
  double? _appliedRadiusKm;

  // State variable to track if filters have been explicitly applied
  bool _filtersApplied = false;

  @override
  void initState() {
    super.initState();
    _loadAndFilterProperties();
  }

  // Consolidated method to load, filter, and score properties
  Future<void> _loadAndFilterProperties() async {
    final userPreferences = Provider.of<UserPreferences>(context, listen: false);
    List<Property> allProperties = MockPropertyService.getMockProperties();
    List<Property> currentFilteredProperties = [];

    // --- BASE FILTERING (from initial housing type selection - ALWAYS "AND") ---
    currentFilteredProperties = allProperties.where((property) {
      return property.type == userPreferences.housingType;
    }).toList();

    // Check if any dynamic filter criteria are actually set.
    bool anySpecificDynamicFilterCriteriaSet =
        (_appliedLocationFilter != null && _appliedLocationFilter!.isNotEmpty) ||
        _appliedMinBudget != null ||
        _appliedMaxBudget != null ||
        _appliedBedrooms != null ||
        _appliedBathrooms != null ||
        (_appliedHouseType != null && _appliedHouseType!.isNotEmpty) ||
        _appliedSelfContained != null ||
        _appliedFenced != null ||
        // REMOVED: _appliedMaxGuests != null ||
        _appliedAmenities.isNotEmpty;

    // --- DYNAMIC FILTERING (from filter modal - now using "at least 2" logic) ---
    if (_filtersApplied && anySpecificDynamicFilterCriteriaSet) {
      currentFilteredProperties = currentFilteredProperties.where((property) {
        int matchedFilterCount = 0;
        bool locationFilterAppliedByUser = (_appliedLocationFilter != null && _appliedLocationFilter!.isNotEmpty);
        bool propertyMatchesLocationFilter = false; // Tracks if this property matches the applied location filter

        // --- Evaluate each dynamic filter contribution ---

        // 1. General Location Filter
        if (locationFilterAppliedByUser) {
          if (property.location.toLowerCase().contains(_appliedLocationFilter!.toLowerCase())) {
            matchedFilterCount++;
            propertyMatchesLocationFilter = true; // Mark that location matched for this property
          }
        }

        // 2. Budget Filter
        if (_appliedMinBudget != null || _appliedMaxBudget != null) {
            bool budgetMeetsCriteria = true;
            if (_appliedMinBudget != null && property.price < _appliedMinBudget!) {
                budgetMeetsCriteria = false;
            }
            if (_appliedMaxBudget != null && property.price > _appliedMaxBudget!) {
                budgetMeetsCriteria = false;
            }
            if (budgetMeetsCriteria) {
                matchedFilterCount++;
            }
        }

        // 3. Bedrooms Filter
        if (_appliedBedrooms != null) {
          if (property.bedrooms >= _appliedBedrooms!) {
            matchedFilterCount++;
          }
        }

        // 4. Bathrooms Filter
        if (_appliedBathrooms != null) {
          if (property.bathrooms >= _appliedBathrooms!) {
            matchedFilterCount++;
          }
        }

        // 5. Type-specific dynamic filtering
        if (userPreferences.housingType == 'permanent') {
          if (_appliedHouseType != null && property.houseType != null &&
              _appliedHouseType!.toLowerCase() == property.houseType!.toLowerCase()) {
            matchedFilterCount++;
          }
        } else if (userPreferences.housingType == 'rental') {
          // Self-contained filter
          if (_appliedSelfContained != null && property.selfContained != null &&
              _appliedSelfContained! == property.selfContained!) {
            matchedFilterCount++;
          }
          // Fenced filter
          if (_appliedFenced != null && property.fenced != null &&
              _appliedFenced! == property.fenced!) {
            matchedFilterCount++;
          }
        } else if (userPreferences.housingType == 'airbnb') {
          // REMOVED: Max Guests filter
          // if (_appliedMaxGuests != null && property.maxGuests != null &&
          //     property.maxGuests! >= _appliedMaxGuests!) {
          //   matchedFilterCount++;
          // }
          // Amenities filter (counts as 1 match if property has ANY of the selected amenities)
          if (_appliedAmenities.isNotEmpty) {
            bool anySelectedAmenityPresentInProperty = false;
            _appliedAmenities.forEach((amenityKey, isSelected) {
              if (isSelected && (property.amenities != null && property.amenities![amenityKey] == true)) {
                anySelectedAmenityPresentInProperty = true;
              }
            });
            if(anySelectedAmenityPresentInProperty) {
                matchedFilterCount++;
            }
          }
        }

        // --- Final Decision for this property based on "at least 2 filters, location mandatory if specified" ---
        if (locationFilterAppliedByUser) {
          // If the user *applied* a location filter, this property MUST match that location filter
          // AND it must match at least one other dynamic filter (making a total of >= 2 matches).
          return propertyMatchesLocationFilter && matchedFilterCount >= 2;
        } else {
          // If the user did *not* apply a location filter, then the property just needs to match
          // any two or more dynamic filters.
          return matchedFilterCount >= 2;
        }
      }).toList();
    }
    // If _filtersApplied is false OR anySpecificDynamicFilterCriteriaSet is false,
    // currentFilteredProperties remains filtered only by housingType at this point.


    // NEW: --- PROXIMITY FILTERING (remains an "AND" condition and is applied after dynamic filters) ---
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
      // If proximity filter is off, ensure distanceKm is null for all properties unless set by old GPS
      for (int i = 0; i < currentFilteredProperties.length; i++) {
        currentFilteredProperties[i] = currentFilteredProperties[i].copyWith(distanceKm: null);
      }
    }


    // --- MATCHING SCORE CALCULATION & SORTING ---
    List<Property> propertiesToScoreOrNullify = [];
    if (_filtersApplied) {
      for (var property in currentFilteredProperties) {
        double score = MatchingAlgorithm.calculateMatchScore(userPreferences, property);
        propertiesToScoreOrNullify.add(property.copyWith(matchScore: score));
      }
      propertiesToScoreOrNullify.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    } else {
      for (var property in currentFilteredProperties) {
        propertiesToScoreOrNullify.add(property.copyWith(matchScore: null));
      }
    }

    setState(() {
      _displayedProperties = propertiesToScoreOrNullify;
    });
  }

  // Method to show the filter modal
  Future<void> _showFilterModal() async {
    final userPreferences = Provider.of<UserPreferences>(context, listen: false);

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
            // REMOVED: initialMaxGuests: _appliedMaxGuests,
            initialAmenities: _appliedAmenities,
            // NEW: Pass current proximity filter values to the modal
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
        // 1. Update internal state variables (used for filtering the list)
        _appliedLocationFilter = appliedFilters['location'];
        _appliedMinBudget = appliedFilters['minBudget'];
        _appliedMaxBudget = appliedFilters['maxBudget'];
        _appliedBedrooms = appliedFilters['bedrooms'];
        _appliedBathrooms = appliedFilters['bathrooms'];
        _appliedHouseType = appliedFilters['permanentHouseType'];
        _appliedSelfContained = appliedFilters['selfContained'];
        _appliedFenced = appliedFilters['fenced'];
        // REMOVED: _appliedMaxGuests = appliedFilters['maxGuests'];
        _appliedAmenities = appliedFilters['amenities'] ?? {};

        // NEW: Update proximity filter state variables
        _appliedReferenceLocationText = appliedFilters['referenceLocationText'];
        _appliedReferenceLatitude = appliedFilters['referenceLatitude'];
        _appliedReferenceLongitude = appliedFilters['referenceLongitude'];
        _appliedRadiusKm = appliedFilters['radiusKm'];

        _filtersApplied = true; // Mark filters as applied when modal returns data
      });

      // 2. Update UserPreferences with the applied filters (for MatchingAlgorithm)
      userPreferences.updateLocation(_appliedLocationFilter);
      userPreferences.updateBudgetRange(min: _appliedMinBudget, max: _appliedMaxBudget);
      userPreferences.updateBedrooms(_appliedBedrooms);
      userPreferences.updateBathrooms(_appliedBathrooms);

      if (userPreferences.housingType == 'permanent') {
        userPreferences.updateHouseType(_appliedHouseType);
        userPreferences.updateRentalDetails(selfContained: null, fenced: null);
        // MODIFIED: Removed 'guests: null'
        userPreferences.updateAirbnbDetails(amenities: {});
      } else if (userPreferences.housingType == 'rental') {
        userPreferences.updateRentalDetails(
          selfContained: _appliedSelfContained,
          fenced: _appliedFenced,
        );
        userPreferences.updateHouseType(null);
        // MODIFIED: Removed 'guests: null'
        userPreferences.updateAirbnbDetails(amenities: {});
      } else if (userPreferences.housingType == 'airbnb') {
        // MODIFIED: Removed 'guests: _appliedMaxGuests'
        userPreferences.updateAirbnbDetails(
          amenities: _appliedAmenities,
        );
        userPreferences.updateHouseType(null);
        userPreferences.updateRentalDetails(selfContained: null, fenced: null);
      }

      // Proximity filters are not part of UserPreferences for matching score,
      // as they are hard 'AND' filters applied *before* scoring.

      _loadAndFilterProperties(); // Re-filter properties with new settings
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${userPreferences.housingType![0].toUpperCase() + userPreferences.housingType!.substring(1)} Listings'),
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterModal,
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _filtersApplied = false; // Reset filtersApplied to false on refresh
                // Reset all applied filters to their initial (null/empty) states
                _appliedLocationFilter = null;
                _appliedMinBudget = null;
                _appliedMaxBudget = null;
                _appliedBedrooms = null;
                _appliedBathrooms = null;
                _appliedHouseType = null;
                _appliedSelfContained = null;
                _appliedFenced = null;
                // REMOVED: _appliedMaxGuests = null;
                _appliedAmenities = {};
                
                // NEW: Reset proximity filter state variables
                _appliedReferenceLocationText = null;
                _appliedReferenceLatitude = null;
                _appliedReferenceLongitude = null;
                _appliedRadiusKm = null;
              });

              // Also clear these preferences in UserPreferences so matching algorithm resets
              userPreferences.updateLocation(null);
              userPreferences.updateBudgetRange(min: null, max: null);
              userPreferences.updateBedrooms(null);
              userPreferences.updateBathrooms(null);
              userPreferences.updateHouseType(null);
              userPreferences.updateRentalDetails(selfContained: null, fenced: null);
              // MODIFIED: Removed 'guests: null'
              userPreferences.updateAirbnbDetails(amenities: {});

              _loadAndFilterProperties();
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                          'Try adjusting your filters.',
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