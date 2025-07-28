import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/services/property_service.dart';
// REMOVE THIS IMPORT: import 'package:housingapp/services/mock_property_service.dart';
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

  @override
  void initState() {
    super.initState();
    // No need to call _loadAndFilterProperties here anymore, StreamBuilder handles initial load.
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
        _appliedReferenceLongitude = appliedFilters['longitude'];
        _appliedRadiusKm = appliedFilters['radiusKm'];

        _filtersApplied = true;
      });

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
    }
  }

  // This method encapsulates the client-side filtering and scoring
  List<Property> _applyClientSideFiltersAndScore(List<Property> properties, UserPreferences userPreferences) {
    List<Property> currentFilteredProperties = List.from(properties);

    if (_filtersApplied && properties.isNotEmpty) {
      currentFilteredProperties = currentFilteredProperties.where((property) {
        int matchedFilterCount = 0;
        bool locationFilterAppliedByUser = (_appliedLocationFilter != null && _appliedLocationFilter!.isNotEmpty);
        bool propertyMatchesLocationFilter = false;

        // 1. General Location Filter
        if (locationFilterAppliedByUser) {
          if (property.location.toLowerCase().contains(_appliedLocationFilter!.toLowerCase())) {
            matchedFilterCount++;
            propertyMatchesLocationFilter = true;
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
          if (_appliedSelfContained != null && property.selfContained != null &&
              _appliedSelfContained! == property.selfContained!) {
            matchedFilterCount++;
          }
          if (_appliedFenced != null && property.fenced != null &&
              _appliedFenced! == property.fenced!) {
            matchedFilterCount++;
          }
        } else if (userPreferences.housingType == 'airbnb') {
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

        if (locationFilterAppliedByUser) {
          return propertyMatchesLocationFilter && matchedFilterCount >= 2;
        } else {
          return matchedFilterCount >= 2;
        }
      }).toList();
    }

    if (_appliedReferenceLatitude != null && _appliedReferenceLongitude != null && _appliedRadiusKm != null) {
      List<Property> proximityFiltered = [];
      for (var property in currentFilteredProperties) {
        double distance = HaversineFormula.calculateDistance(
          _appliedReferenceLatitude!,
          _appliedReferenceLongitude!,
          property.latitude,
          property.longitude,
        );
        Property updatedProperty = property.copyWith(distanceKm: distance);
        if (distance <= _appliedRadiusKm!) {
          proximityFiltered.add(updatedProperty);
        }
      }
      currentFilteredProperties = proximityFiltered;
    } else {
      for (int i = 0; i < currentFilteredProperties.length; i++) {
        currentFilteredProperties[i] = currentFilteredProperties[i].copyWith(distanceKm: null);
      }
    }

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

    return propertiesToScoreOrNullify;
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    final propertyService = Provider.of<PropertyService>(context);

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
                _filtersApplied = false;
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
              });
              userPreferences.updateLocation(null);
              userPreferences.updateBudgetRange(min: null, max: null);
              userPreferences.updateBedrooms(null);
              userPreferences.updateBathrooms(null);
              userPreferences.updateHouseType(null);
              userPreferences.updateRentalDetails(selfContained: null, fenced: null);
              userPreferences.updateAirbnbDetails(amenities: {});
            },
          ),
          // REMOVED: IconButton for favorite_border
        ],
      ),
      body: Column(
        children: [
          // REMOVED: Padding and Text for "Showing properties for:..."
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: propertyService.getFilteredPropertiesStream(userPreferences),
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
                  );
                }

                final firebaseProperties = snapshot.data!;
                final displayedProperties = _applyClientSideFiltersAndScore(firebaseProperties, userPreferences);

                if (displayedProperties.isEmpty) {
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
                          'No properties found matching your advanced filters.',
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displayedProperties.length,
                  itemBuilder: (context, index) {
                    final property = displayedProperties[index];
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
          ),
        ],
      ),
      // REMOVED THE FLOATING ACTION BUTTON
    );
  }
}