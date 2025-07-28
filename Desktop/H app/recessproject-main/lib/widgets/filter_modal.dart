// lib/widgets/filter_modal.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/widgets/custom_button.dart';

// IMPORTANT: Ensure 'geocoding: ^2.0.0' (or latest compatible version)
// is added to your pubspec.yaml file under dependencies.

class FilterModal extends StatefulWidget {
  final String housingType; // To customize filters based on type
  final String? initialLocation; // General location filter
  final double? initialMinBudget;
  final double? initialMaxBudget;
  final int? initialBedrooms;
  final int? initialBathrooms;
  final String? initialPermanentHouseType;
  final bool? initialSelfContained;
  final bool? initialFenced;
  // REMOVED: final int? initialMaxGuests;
  final Map<String, bool> initialAmenities;

  // NEW: Initial values for proximity filter
  final String? initialReferenceLocationText; // Text entered by user
  final double? initialReferenceLatitude;
  final double? initialReferenceLongitude;
  final double? initialRadiusKm;

  const FilterModal({
    super.key,
    required this.housingType,
    this.initialLocation,
    this.initialMinBudget,
    this.initialMaxBudget,
    this.initialBedrooms,
    this.initialBathrooms,
    this.initialPermanentHouseType,
    this.initialSelfContained,
    this.initialFenced,
    // REMOVED: this.initialMaxGuests,
    this.initialAmenities = const {},
    // NEW
    this.initialReferenceLocationText,
    this.initialReferenceLatitude,
    this.initialReferenceLongitude,
    this.initialRadiusKm,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final TextEditingController _locationController =
      TextEditingController(); // General location filter
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();

  // NEW: Proximity filter controllers and state
  final TextEditingController _referenceLocationController =
      TextEditingController();
  double? _radiusKm;
  double? _geocodedLatitude;
  double? _geocodedLongitude;
  bool _isGeocoding = false;
  String? _geocodingError;

  int? _bedrooms;
  int? _bathrooms;
  String? _houseType;
  bool? _selfContained;
  bool? _fenced;
  // REMOVED: int? _maxGuests;
  Map<String, bool> _amenities = {};

  final List<String> _houseTypes = [
    'Bungalow',
    'Mansion',
    'Apartment',
    'Condo',
    'Townhouse'
  ];
  final List<String> _allAmenities = [
    'WiFi',
    'Parking',
    'Pool',
    'Gym',
    'Air Conditioning',
    'Kitchen',
    'TV'
  ];

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.initialLocation ?? '';
    _minBudgetController.text = widget.initialMinBudget?.toString() ?? '';
    _maxBudgetController.text = widget.initialMaxBudget?.toString() ?? '';
    _bedrooms = widget.initialBedrooms;
    _bathrooms = widget.initialBathrooms;
    _houseType = widget.initialPermanentHouseType;
    _selfContained = widget.initialSelfContained;
    _fenced = widget.initialFenced;
    // REMOVED: _maxGuests = widget.initialMaxGuests;
    _amenities = Map.from(widget.initialAmenities);

    // NEW: Initialize proximity filter state
    _referenceLocationController.text =
        widget.initialReferenceLocationText ?? '';
    _radiusKm = widget.initialRadiusKm;
    _geocodedLatitude = widget.initialReferenceLatitude;
    _geocodedLongitude = widget.initialReferenceLongitude;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _referenceLocationController.dispose(); // NEW: Dispose new controller
    super.dispose();
  }

  Future<void> _applyFilters() async {
    _geocodingError = null; // Clear previous errors

    String? refLocationText = _referenceLocationController.text.trim();
    double? finalGeocodedLat = _geocodedLatitude;
    double? finalGeocodedLon = _geocodedLongitude;

    // For now, just use the existing coordinates if available
    if (refLocationText.isEmpty) {
      // If reference location text is cleared, clear geocoded coordinates too
      finalGeocodedLat = null;
      finalGeocodedLon = null;
      _radiusKm = null; // Also clear radius if no reference point
    }

    // Only proceed if no geocoding error or no reference location was provided (or geocoding succeeded)
    if (mounted) {
      Navigator.pop(context, {
        'location': _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        'minBudget': double.tryParse(_minBudgetController.text),
        'maxBudget': double.tryParse(_maxBudgetController.text),
        'bedrooms': _bedrooms,
        'bathrooms': _bathrooms,
        'permanentHouseType': _houseType,
        'selfContained': _selfContained,
        'fenced': _fenced,
        // REMOVED: 'maxGuests': _maxGuests,
        'amenities': _amenities,
        // NEW: Proximity filter results
        'referenceLocationText':
            refLocationText.isNotEmpty ? refLocationText : null,
        'referenceLatitude': finalGeocodedLat,
        'referenceLongitude': finalGeocodedLon,
        'radiusKm': _radiusKm,
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _locationController.clear();
      _minBudgetController.clear();
      _maxBudgetController.clear();
      _bedrooms = null;
      _bathrooms = null;
      _houseType = null;
      _selfContained = null;
      _fenced = null;
      // REMOVED: _maxGuests = null;
      _amenities = {};

      // NEW: Reset proximity filter
      _referenceLocationController.clear();
      _radiusKm = null;
      _geocodedLatitude = null;
      _geocodedLongitude = null;
      _isGeocoding = false;
      _geocodingError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Listings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Close without applying
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General Filters',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            Text('Location (General Search)',
                style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g., Kololo, Kampala',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),

            // NEW: Proximity Filter Section
            Text('Proximity Filter',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Reference Point (Address)',
                style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _referenceLocationController,
              decoration: const InputDecoration(
                hintText: 'e.g., Makerere University, Kampala',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            if (_isGeocoding)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(),
              ),
            if (_geocodingError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _geocodingError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            Text('Radius (km)', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _radiusKm ??
                        0, // Default to 0 if null, will be set once user interacts
                    min: 0,
                    max: 50, // Max radius of 50 km
                    divisions: 10, // 0, 5, 10, 15, ..., 50
                    label:
                        _radiusKm == null ? 'Any' : '${_radiusKm!.round()} km',
                    onChanged: (value) {
                      setState(() {
                        _radiusKm = value;
                      });
                    },
                  ),
                ),
                Text(_radiusKm == null ? 'Any' : '${_radiusKm!.round()} km',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 24),
            // End of Proximity Filter Section

            Text('Budget Range (UGX)',
                style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Max',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Bedrooms', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<int>(
              value: _bedrooms,
              hint: const Text('Any'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                for (int i = 1; i <= 5; i++)
                  DropdownMenuItem(value: i, child: Text('$i+')),
              ],
              onChanged: (value) {
                setState(() {
                  _bedrooms = value;
                });
              },
            ),
            const SizedBox(height: 24),

            Text('Bathrooms', style: Theme.of(context).textTheme.titleMedium),
            DropdownButtonFormField<int>(
              value: _bathrooms,
              hint: const Text('Any'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Any')),
                for (int i = 1; i <= 3; i++)
                  DropdownMenuItem(value: i, child: Text('$i+')),
              ],
              onChanged: (value) {
                setState(() {
                  _bathrooms = value;
                });
              },
            ),
            const SizedBox(height: 24),

            if (widget.housingType == 'permanent') ...[
              Text('House Type',
                  style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _houseType,
                hint: const Text('Any'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  ..._houseTypes.map((type) => DropdownMenuItem(
                      value: type.toLowerCase(), child: Text(type))),
                ],
                onChanged: (value) {
                  setState(() {
                    _houseType = value;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            if (widget.housingType == 'rental') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _selfContained ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        _selfContained = value;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppStyles.primaryColor;
                      }
                      return null;
                    }),
                  ),
                  Text('Self-contained',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _fenced ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        _fenced = value;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppStyles.primaryColor;
                      }
                      return null;
                    }),
                  ),
                  Text('Fenced Compound',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (widget.housingType == 'airbnb') ...[
              // REMOVED: Max Guests section
              Text('Amenities', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _allAmenities.map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: _amenities[amenity] ?? false,
                    onSelected: (bool selected) {
                      setState(() {
                        _amenities[amenity] = selected;
                      });
                    },
                    selectedColor:
                        AppStyles.primaryColor.withAlpha((0.7 * 255).round()),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: (_amenities[amenity] ?? false)
                          ? Colors.white
                          : AppStyles.textColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),
            CustomButton(
              text: _isGeocoding ? 'Locating...' : 'Apply Filters',
              onPressed: _isGeocoding
                  ? null
                  : _applyFilters, // Disable button while geocoding
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
