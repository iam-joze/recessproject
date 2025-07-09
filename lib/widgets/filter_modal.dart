import 'package:flutter/material.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/widgets/custom_button.dart'; // Make sure CustomButton is imported

class FilterModal extends StatefulWidget {
  final String housingType; // To customize filters based on type
  final String? initialLocation;
  final double? initialMinBudget;
  final double? initialMaxBudget;
  final int? initialBedrooms;
  final int? initialBathrooms;
  final String? initialHouseType; // For permanent homes
  final String? initialRoomType; // For rentals
  final bool? initialSelfContained; // For rentals
  final bool? initialFenced; // For rentals
  final int? initialMaxGuests; // For Airbnb
  final Map<String, bool> initialAmenities; // For Airbnb

  const FilterModal({
    Key? key,
    required this.housingType,
    this.initialLocation,
    this.initialMinBudget,
    this.initialMaxBudget,
    this.initialBedrooms,
    this.initialBathrooms,
    this.initialHouseType,
    this.initialRoomType,
    this.initialSelfContained,
    this.initialFenced,
    this.initialMaxGuests,
    this.initialAmenities = const {},
  }) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();

  int? _bedrooms;
  int? _bathrooms;
  String? _houseType;
  String? _roomType;
  bool? _selfContained;
  bool? _fenced;
  int? _maxGuests;
  Map<String, bool> _amenities = {};

  final List<String> _houseTypes = ['Bungalow', 'Mansion', 'Apartment', 'Condo', 'Townhouse'];
  final List<String> _roomTypes = ['Single Room', 'Self Contained', 'Shared Apartment', 'Hostel Room'];
  final List<String> _allAmenities = ['WiFi', 'Parking', 'Pool', 'Gym', 'Air Conditioning', 'Kitchen', 'TV']; // Common Airbnb amenities

  @override
  void initState() {
    super.initState();
    _locationController.text = widget.initialLocation ?? '';
    _minBudgetController.text = widget.initialMinBudget?.toString() ?? '';
    _maxBudgetController.text = widget.initialMaxBudget?.toString() ?? '';
    _bedrooms = widget.initialBedrooms;
    _bathrooms = widget.initialBathrooms;
    _houseType = widget.initialHouseType;
    _roomType = widget.initialRoomType;
    _selfContained = widget.initialSelfContained;
    _fenced = widget.initialFenced;
    _maxGuests = widget.initialMaxGuests;
    _amenities = Map.from(widget.initialAmenities); // Copy to be mutable
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'location': _locationController.text.isNotEmpty ? _locationController.text : null,
      'minBudget': double.tryParse(_minBudgetController.text),
      'maxBudget': double.tryParse(_maxBudgetController.text),
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'houseType': _houseType,
      'roomType': _roomType,
      'selfContained': _selfContained,
      'fenced': _fenced,
      'maxGuests': _maxGuests,
      'amenities': _amenities,
    });
  }

  void _resetFilters() {
    setState(() {
      _locationController.clear();
      _minBudgetController.clear();
      _maxBudgetController.clear();
      _bedrooms = null;
      _bathrooms = null;
      _houseType = null;
      _roomType = null;
      _selfContained = null;
      _fenced = null;
      _maxGuests = null;
      _amenities = {};
    });
    // Do NOT call _applyFilters here. The user explicitly presses apply.
    // If you want reset to also apply, call _applyFilters() here.
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
            Text('Location', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g., Kololo, Kampala',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),

            Text('Budget Range (UGX)', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Text('House Type', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _houseType,
                hint: const Text('Any'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  ..._houseTypes.map((type) => DropdownMenuItem(value: type.toLowerCase(), child: Text(type))),
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
              Text('Room Type', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<String>(
                value: _roomType,
                hint: const Text('Any'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  ..._roomTypes.map((type) => DropdownMenuItem(value: type.toLowerCase(), child: Text(type))),
                ],
                onChanged: (value) {
                  setState(() {
                    _roomType = value;
                  });
                },
              ),
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
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppStyles.primaryColor;
                      }
                      return null;
                    }),
                  ),
                  Text('Self-contained', style: Theme.of(context).textTheme.bodyLarge),
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
                    fillColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppStyles.primaryColor;
                      }
                      return null;
                    }),
                  ),
                  Text('Fenced Compound', style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 24),
            ],

            if (widget.housingType == 'airbnb') ...[
              Text('Max Guests', style: Theme.of(context).textTheme.titleMedium),
              DropdownButtonFormField<int>(
                value: _maxGuests,
                hint: const Text('Any'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Any')),
                  for (int i = 1; i <= 10; i++)
                    DropdownMenuItem(value: i, child: Text('$i')),
                ],
                onChanged: (value) {
                  setState(() {
                    _maxGuests = value;
                  });
                },
              ),
              const SizedBox(height: 24),

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
                    selectedColor: AppStyles.primaryColor.withOpacity(0.7),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: (_amenities[amenity] ?? false) ? Colors.white : AppStyles.textColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 32),
            CustomButton(
              text: 'Apply Filters',
              onPressed: _applyFilters,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}