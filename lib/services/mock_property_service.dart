// lib/services/mock_property_service.dart
import 'package:housingapp/models/property.dart'; // Ensure correct import
import 'dart:math';

class MockPropertyService {
  // Use a fixed seed for the Random object to ensure consistent data generation
  static final Random _random = Random(42); // Fixed seed for reproducibility
  static final List<String> _ugandanLocations = [
    'Kololo', 'Bugolobi', 'Ntinda', 'Muyenga', 'Naalya', 'Kira', 'Makerere', 'Lubaga',
    'Kawempe', 'Nakawa', 'Munyonyo', 'Kiwatule', 'Gayaza', 'Najjera', 'Kyaliwajjala',
    'Entebbe', 'Jinja', 'Mbarara', 'Gulu', 'Fort Portal', 'Masaka', 'Mbale'
  ];

  // UPDATED LIST OF PLACEHOLDER IMAGE URLs using LOCAL ASSETS (format: house (X).jpg)
  // IMPORTANT: You MUST rename your actual downloaded images to these exact names
  // (e.g., house (1).jpg, house (2).jpg, etc.) and place them in assets/images/.
  // Ensure the file extensions here (.jpg) match your actual files' extensions.
  static const List<String> _propertyImageUrls = [
    'assets/images/house (1).jpg',
    'assets/images/house (2).jpg',
    'assets/images/house (3).jpg',
    'assets/images/house (4).jpg',
    'assets/images/house (5).jpg',
    'assets/images/house (6).jpg',
    'assets/images/house (7).jpg',
    'assets/images/house (8).jpg',
    'assets/images/house (9).jpg',
    'assets/images/house (10).jpg',
    'assets/images/house (11).jpg',
    'assets/images/house (12).jpg',
    'assets/images/house (13).jpg',
    'assets/images/house (14).jpg',
    'assets/images/house (15).jpg',
    'assets/images/house (16).jpg',
    'assets/images/house (17).jpg',
    'assets/images/house (18).jpg',
    'assets/images/house (19).jpg',
    'assets/images/house (20).jpg',
    'assets/images/house (21).jpg',
    'assets/images/house (22).jpg',
    'assets/images/house (23).jpg',
    'assets/images/house (24).jpg',
    'assets/images/house (25).jpg',
    'assets/images/house (26).jpg',
    'assets/images/house (27).jpg',
    'assets/images/house (28).jpg',
    'assets/images/house (29).jpg',
    'assets/images/house (30).jpg',
  ];

  // The static list of properties, initialized once
  static final List<Property> _staticProperties = _initializeProperties();

  // Public getter to retrieve the static mock properties
  static List<Property> getMockProperties() {
    return _staticProperties;
  }

  // Private method to initialize and populate the static properties list
  static List<Property> _initializeProperties() {
    List<Property> properties = [];
    int propertyIndex = 0;

    // Ensure at least 30 permanent homes
    for (int i = 0; i < 30; i++) {
      properties.add(_generateRandomProperty(propertyIndex++, 'permanent'));
    }
    // Ensure at least 30 rental properties
    for (int i = 0; i < 30; i++) {
      properties.add(_generateRandomProperty(propertyIndex++, 'rental'));
    }
    // Ensure at least 30 Airbnb properties
    for (int i = 0; i < 30; i++) {
      properties.add(_generateRandomProperty(propertyIndex++, 'airbnb'));
    }

    // Generate remaining 10 properties with random types to reach 100
    for (int i = 0; i < 10; i++) {
      properties.add(_generateRandomProperty(propertyIndex++, _getRandomHousingType()));
    }

    return properties;
  }

  // Helper to generate a single random property
  static Property _generateRandomProperty(int index, String typeOverride) {
    String id = 'prop_${index + 1}';
    String type = typeOverride;
    String location = _ugandanLocations[_random.nextInt(_ugandanLocations.length)];
    double price = _getRandomPrice(type);
    int bedrooms = _random.nextInt(4) + 1; // 1 to 4 bedrooms
    int bathrooms = _random.nextInt(3) + 1; // 1 to 3 bathrooms
    double areaSqFt = _random.nextDouble() * (2500 - 500) + 500; // 500 to 3000 sq ft
    // Adjusting latitude/longitude to be more centered around Nansana/Kampala area
    double latitude = 0.3180 + (_random.nextDouble() * 0.05 * (_random.nextBool() ? 1 : -1)); // Around Kampala/Uganda
    double longitude = 32.5825 + (_random.nextDouble() * 0.05 * (_random.nextBool() ? 1 : -1)); // Around Kampala/Uganda

    // Select a random image URL from the curated list
    String imageUrl = _propertyImageUrls[_random.nextInt(_propertyImageUrls.length)];

    String title = _generateRandomTitle(type, location, bedrooms);
    String description = 'A beautiful $type property located in $location. Spacious and modern with great amenities.';

    // Initialize type-specific properties as null
    String? houseType;
    bool? selfContained;
    bool? fenced;
    List<DateTime>? availableDates;
    Map<String, bool>? amenities;

    switch (type) {
      case 'permanent':
        houseType = _getRandomPermanentHouseType();
        break;
      case 'rental':
        selfContained = _random.nextBool();
        fenced = _random.nextBool();
        break;
      case 'airbnb':
        availableDates = _generateRandomAvailableDates();
        amenities = _getRandomAmenities();
        break;
    }

    return Property(
      id: id,
      type: type, // Directly use 'type' as it matches Property model
      title: title, // Directly use 'title' as it matches Property model
      description: description,
      imageUrl: imageUrl,
      location: location,
      price: price,
      latitude: latitude,
      longitude: longitude,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqFt: areaSqFt,
      houseType: houseType, // Pass nullable houseType
      selfContained: selfContained, // Pass nullable selfContained
      fenced: fenced, // Pass nullable fenced
      availableDates: availableDates, // Pass nullable availableDates
      amenities: amenities, // Pass nullable amenities (Map<String, bool>)
      // clusterId, matchScore, distanceKm are not generated here, they are for algorithms
    );
  }

  static String _getRandomHousingType() {
    final types = ['permanent', 'rental', 'airbnb'];
    return types[_random.nextInt(types.length)];
  }

  static double _getRandomPrice(String type) {
    switch (type) {
      case 'permanent':
      // UGX 50,000,000 to 1,500,000,000
        return (_random.nextDouble() * (1500 - 50) + 50) * 1000000.0;
      case 'rental':
      // UGX 300,000 to 5,000,000 per month
        return (_random.nextDouble() * (5000 - 300) + 300) * 1000.0;
      case 'airbnb':
      // UGX 50,000 to 500,000 per night
        return (_random.nextDouble() * (500 - 50) + 50) * 1000.0;
      default:
        return 1000000.0;
    }
  }

  static String _getRandomPermanentHouseType() {
    final types = ['Bungalow', 'Mansion', 'Apartment', 'Condo', 'Townhouse', 'Semi-Detached'];
    return types[_random.nextInt(types.length)].toLowerCase();
  }

  static List<DateTime> _generateRandomAvailableDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 60; i++) { // Check availability for next 60 days
      if (_random.nextDouble() > 0.4) { // 60% chance of being available on a given day
        dates.add(now.add(Duration(days: i)));
      }
    }
    return dates;
  }

  static Map<String, bool> _getRandomAmenities() {
    final allAmenities = [
      'WiFi', 'Parking', 'Pool', 'Gym', 'Air Conditioning', 'Kitchen', 'TV',
      'Hot Water', 'Balcony', 'Garden', 'Security', 'Pet-Friendly', 'Washer', 'Dryer'
    ];
    Map<String, bool> amenities = {};
    for (var amenity in allAmenities) {
      amenities[amenity] = _random.nextBool(); // Randomly include or exclude
    }
    // Ensure some common ones are often true
    if (_random.nextDouble() < 0.9) amenities['WiFi'] = true;
    if (_random.nextDouble() < 0.8) amenities['Parking'] = true;
    if (_random.nextDouble() < 0.7) amenities['Kitchen'] = true;
    if (_random.nextDouble() < 0.6) amenities['Security'] = true;
    return amenities;
  }

  static String _generateRandomTitle(String type, String location, int bedrooms) {
    String prefix = '';
    String suffix = '';

    switch (type) {
      case 'permanent':
        prefix = 'Luxury';
        suffix = 'Dream Home';
        break;
      case 'rental':
        prefix = 'Comfortable';
        suffix = 'Rental Unit';
        break;
      case 'airbnb':
        prefix = 'Charming';
        suffix = 'Getaway';
        break;
    }

    List<String> adjectives = ['Spacious', 'Modern', 'Cozy', 'Elegant', 'Bright', 'Serene', 'Vibrant'];
    String adjective = adjectives[_random.nextInt(adjectives.length)];

    String bedroomsText = bedrooms == 1 ? '1-Bedroom' : '$bedrooms-Bedroom';

    return '$adjective $bedroomsText $prefix $suffix in $location';
  }

  // Haversine formula to calculate distance between two lat/lon points in kilometers
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of Earth in kilometers

    double latRad1 = _degreesToRadians(lat1);
    double lonRad1 = _degreesToRadians(lon1);
    double latRad2 = _degreesToRadians(lat2);
    double lonRad2 = _degreesToRadians(lon2);

    double dLat = latRad2 - latRad1;
    double dLon = lonRad2 - lonRad1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(latRad1) * cos(latRad2) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // The main method to get properties with applied filters
  List<Property> getProperties({
    String? type,
    String? location,
    double? minBudget,
    double? maxBudget,
    int? bedrooms,
    int? bathrooms,
    String? permanentHouseType,
    bool? selfContained,
    bool? fenced,
    Map<String, bool>? amenities,
    // NEW: Proximity filter parameters
    double? referenceLatitude,
    double? referenceLongitude,
    double? radiusKm,
  }) {
    // Start with a copy of all mock properties to avoid modifying the static list directly
    List<Property> filteredProperties = List.from(_staticProperties);

    // Apply general filters
    if (type != null && type != 'all') {
      filteredProperties = filteredProperties.where((p) => p.type == type).toList();
    }
    if (location != null && location.isNotEmpty) {
      filteredProperties = filteredProperties
          .where((p) => p.location.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }
    if (minBudget != null) {
      filteredProperties = filteredProperties.where((p) => p.price >= minBudget).toList();
    }
    if (maxBudget != null) {
      filteredProperties = filteredProperties.where((p) => p.price <= maxBudget).toList();
    }
    if (bedrooms != null) {
      filteredProperties = filteredProperties.where((p) => p.bedrooms >= bedrooms).toList();
    }
    if (bathrooms != null) {
      filteredProperties = filteredProperties.where((p) => p.bathrooms >= bathrooms).toList();
    }

    // Apply type-specific filters
    if (type == 'permanent' && permanentHouseType != null && permanentHouseType.isNotEmpty) {
      filteredProperties = filteredProperties.where((p) => p.houseType == permanentHouseType).toList();
    }
    if (type == 'rental') {
      if (selfContained != null) {
        filteredProperties = filteredProperties.where((p) => p.selfContained == selfContained).toList();
      }
      if (fenced != null) {
        filteredProperties = filteredProperties.where((p) => p.fenced == fenced).toList();
      }
    }
    if (type == 'airbnb' && amenities != null && amenities.isNotEmpty) {
      amenities.forEach((amenity, isSelected) {
        if (isSelected) {
          filteredProperties = filteredProperties
              .where((p) => p.amenities != null && p.amenities![amenity] == true)
              .toList();
        }
      });
    }

    // NEW: Apply Proximity Filter
    if (referenceLatitude != null && referenceLongitude != null && radiusKm != null && radiusKm > 0) {
      List<Property> proximityFiltered = [];
      for (var property in filteredProperties) {
        double distance = _calculateDistance(
          referenceLatitude,
          referenceLongitude,
          property.latitude,
          property.longitude,
        );
        if (distance <= radiusKm) {
          // Create a new Property object with the calculated distance
          proximityFiltered.add(property.copyWith(distanceKm: distance));
        }
      }
      filteredProperties = proximityFiltered;
    } else {
      // If no proximity filter is applied, ensure distanceKm is null for all properties
      // This prevents carrying over distance from a previous filter application
      filteredProperties = filteredProperties.map((p) => p.copyWith(distanceKm: null)).toList();
    }
    
    // Sort properties by distance if a proximity filter was applied, otherwise maintain original order.
    // Ensure properties with null distanceKm are placed at the end if sorting by distance.
    if (referenceLatitude != null && referenceLongitude != null && radiusKm != null && radiusKm > 0) {
      filteredProperties.sort((a, b) {
        // Handle null cases for distanceKm during sorting
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1; // Put properties without distance at the end
        if (b.distanceKm == null) return -1; // Put properties without distance at the end
        return a.distanceKm!.compareTo(b.distanceKm!);
      });
    }


    return filteredProperties;
  }
}