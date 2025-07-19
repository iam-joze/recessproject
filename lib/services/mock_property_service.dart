// lib/services/mock_property_service.dart
import 'package:housingapp/models/property.dart';
import 'dart:math';

class MockPropertyService {
  // Use a fixed seed for the Random object to ensure consistent data generation
  static final Random _random = Random(42); // Fixed seed for reproducibility
  static final List<String> _ugandanLocations = [
    'Kololo', 'Bugolobi', 'Ntinda', 'Muyenga', 'Naalya', 'Kira', 'Makerere', 'Lubaga',
    'Kawempe', 'Nakawa', 'Munyonyo', 'Kiwatule', 'Gayaza', 'Najjera', 'Kyaliwajjala',
    'Entebbe', 'Jinja', 'Mbarara', 'Gulu', 'Fort Portal', 'Masaka', 'Mbale'
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


    // Use specific image IDs from picsum.photos that tend to show buildings/interiors
    // These IDs are also determined by the fixed _random instance
    int imageId = _random.nextInt(300) + 1; // Use IDs from 1 to 300 for general variety
    if (index % 5 == 0) imageId = _random.nextInt(50) + 400; // More specific IDs for interiors/exteriors
    if (index % 7 == 0) imageId = _random.nextInt(50) + 500; // More specific IDs for landscapes/buildings

    String imageUrl = 'https://picsum.photos/id/$imageId/800/600';
    String title = _generateRandomTitle(type, location, bedrooms);
    String description = 'A beautiful ${type} property located in ${location}. Spacious and modern with great amenities.';

    // Type-specific details
    String? houseType;
    bool? selfContained;
    bool? fenced;
    // REMOVED: int? maxGuests;
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
        // REMOVED: maxGuests = _random.nextInt(6) + 1; // 1 to 6 guests
        availableDates = _generateRandomAvailableDates();
        amenities = _getRandomAmenities();
        break;
    }

    return Property(
      id: id,
      title: title,
      description: description,
      location: location,
      price: price,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqFt: areaSqFt,
      type: type,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      houseType: houseType,
      selfContained: selfContained,
      fenced: fenced,
      // REMOVED: maxGuests: maxGuests,
      availableDates: availableDates,
      amenities: amenities,
      // Default nulls for matchScore and distanceKm
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
}