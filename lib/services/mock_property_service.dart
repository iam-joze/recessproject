import 'package:housingapp/models/property.dart';
import 'dart:math'; // For random number generation

class MockPropertyService {
  static final Random _random = Random();
  static final List<String> _ugandanLocations = [
    'Kololo', 'Bugolobi', 'Ntinda', 'Muyenga', 'Naalya', 'Kira', 'Makerere', 'Lubaga',
    'Kawempe', 'Nakawa', 'Munyonyo', 'Kiwatule', 'Gayaza', 'Najjera', 'Kyaliwajjala'
  ];

  static List<Property> getMockProperties() {
    List<Property> properties = [];
    for (int i = 0; i < 100; i++) { // Generate 100 properties
      properties.add(_generateRandomProperty(i));
    }
    return properties;
  }

  static Property _generateRandomProperty(int index) {
    String id = 'prop_${index + 1}';
    String type = _getRandomHousingType();
    String location = _ugandanLocations[_random.nextInt(_ugandanLocations.length)];
    double price = _getRandomPrice(type);
    int bedrooms = _random.nextInt(4) + 1; // 1 to 4 bedrooms
    int bathrooms = _random.nextInt(3) + 1; // 1 to 3 bathrooms
    double areaSqFt = _random.nextDouble() * (2500 - 500) + 500; // 500 to 3000 sq ft
    double latitude = 0.3180 + (_random.nextDouble() * 0.05 * (_random.nextBool() ? 1 : -1)); // Around Kampala
    double longitude = 32.5825 + (_random.nextDouble() * 0.05 * (_random.nextBool() ? 1 : -1)); // Around Kampala
    String imageUrl = 'https://picsum.photos/id/${_random.nextInt(1000)}/800/600'; // Random image from Lorem Picsum
    String title = _generateRandomTitle(type, location, bedrooms);
    String description = 'A beautiful ${type} property located in ${location}. Spacious and modern with great amenities.';

    // Type-specific details
    String? houseType;
    String? roomType;
    bool? selfContained;
    bool? fenced;
    int? maxGuests;
    List<DateTime>? availableDates;
    Map<String, bool>? amenities;
    
    switch (type) {
      case 'permanent':
        houseType = _getRandomPermanentHouseType();
        break;
      case 'rental':
        roomType = _getRandomRentalRoomType();
        selfContained = _random.nextBool();
        fenced = _random.nextBool();
        break;
      case 'airbnb':
        maxGuests = _random.nextInt(6) + 1; // 1 to 6 guests
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
      roomType: roomType,
      selfContained: selfContained,
      fenced: fenced,
      maxGuests: maxGuests,
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
        return (_random.nextInt(100) + 50) * 1000000.0; // 50M - 150M+ UGX
      case 'rental':
        return (_random.nextInt(20) + 5) * 100000.0; // 500k - 2.5M UGX
      case 'airbnb':
        return (_random.nextInt(100) + 30) * 1000.0; // 30k - 130k UGX per night
      default:
        return 1000000.0;
    }
  }

  static String _getRandomPermanentHouseType() {
    final types = ['Bungalow', 'Mansion', 'Apartment', 'Condo', 'Townhouse'];
    return types[_random.nextInt(types.length)].toLowerCase();
  }

  static String _getRandomRentalRoomType() {
    final types = ['Single Room', 'Self Contained', 'Shared Apartment', 'Hostel Room'];
    return types[_random.nextInt(types.length)].toLowerCase();
  }

  static List<DateTime> _generateRandomAvailableDates() {
    List<DateTime> dates = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 30; i++) { // Generate availability for the next 30 days
      if (_random.nextDouble() > 0.3) { // 70% chance of being available
        dates.add(now.add(Duration(days: i)));
      }
    }
    return dates;
  }

  static Map<String, bool> _getRandomAmenities() {
    final allAmenities = ['WiFi', 'Parking', 'Pool', 'Gym', 'Air Conditioning', 'Kitchen', 'TV', 'Hot Water', 'Balcony'];
    Map<String, bool> amenities = {};
    for (var amenity in allAmenities) {
      amenities[amenity] = _random.nextBool(); // Randomly include or exclude
    }
    // Ensure at least a few common ones are true
    if (_random.nextDouble() < 0.8) amenities['WiFi'] = true;
    if (_random.nextDouble() < 0.7) amenities['Parking'] = true;
    if (_random.nextDouble() < 0.6) amenities['Kitchen'] = true;
    return amenities;
  }

  static String _generateRandomTitle(String type, String location, int bedrooms) {
    String baseTitle = '';
    switch (type) {
      case 'permanent':
        baseTitle = 'Spacious ${bedrooms}BR ${location} Home';
        break;
      case 'rental':
        baseTitle = '${bedrooms}BR Rental in ${location}';
        break;
      case 'airbnb':
        baseTitle = 'Cozy ${bedrooms}BR Airbnb in ${location}';
        break;
    }
    return '$baseTitle #${_random.nextInt(999) + 1}'; // Add a random number for uniqueness
  }
}