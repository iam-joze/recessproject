class Property {
  final String id;
  final String type; // 'airbnb', 'rental', 'permanent'
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final double price; // Per month for rental/permanent, per night for Airbnb
  final double latitude;
  final double longitude;
  final int bedrooms;
  final int bathrooms;
  final double areaSqFt; // Square footage

  // Type-specific properties
  final String? houseType; // e.g., 'apartment', 'bungalow', 'condo' (for permanent)
  final String? roomType; // e.g., '1-bedroom', 'studio' (for rental)
  final bool? selfContained; // For rental
  final bool? fenced; // For rental
  final List<DateTime>? availableDates; // For Airbnb
  final Map<String, bool>? amenities; // e.g., {'wifi': true, 'kitchen': true} for Airbnb
  final int? maxGuests; // For Airbnb

  // Algorithm specific (will be used later, good to include now)
  int? clusterId; // For K-Means clustering
  double? matchScore; // Custom score based on user preferences
  double? distanceKm; // Distance from user's current location

  Property({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.price,
    required this.latitude,
    required this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqFt,
    this.houseType,
    this.roomType,
    this.selfContained,
    this.fenced,
    this.availableDates,
    this.amenities,
    this.maxGuests,
    this.clusterId,
    this.matchScore,
    this.distanceKm,
  });

  // Helper to update algorithm-related fields (we'll use this later)
  Property copyWith({
    int? clusterId,
    double? matchScore,
    double? distanceKm,
  }) {
    return Property(
      id: id,
      type: type,
      title: title,
      description: description,
      imageUrl: imageUrl,
      location: location,
      price: price,
      latitude: latitude,
      longitude: longitude,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqFt: areaSqFt,
      houseType: houseType,
      roomType: roomType,
      selfContained: selfContained,
      fenced: fenced,
      availableDates: availableDates,
      amenities: amenities,
      maxGuests: maxGuests,
      clusterId: clusterId ?? this.clusterId,
      matchScore: matchScore ?? this.matchScore,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}