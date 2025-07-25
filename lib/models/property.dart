//import 'package:flutter/material.dart'; // Often needed for UI-related stuff, even in models
import 'package:cloud_firestore/cloud_firestore.dart'; // ADD THIS IMPORT

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
  final bool? selfContained; // For rental
  final bool? fenced; // For rental
  final List<DateTime>? availableDates; // For Airbnb - stored as Timestamps in Firestore
  final Map<String, bool>? amenities; // e.g., {'wifi': true, 'kitchen': true} for Airbnb

  // Algorithm specific (will be used later, good to include now, but NOT stored in Firestore document itself)
  int? clusterId;
  double? matchScore;
  double? distanceKm;

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
    this.selfContained,
    this.fenced,
    this.availableDates,
    this.amenities,
    this.clusterId,
    this.matchScore,
    this.distanceKm,
  });

  // --- Firestore Integration Methods ---

  // Converts a Property object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'price': price,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqFt': areaSqFt,
      if (houseType != null) 'houseType': houseType,
      if (selfContained != null) 'selfContained': selfContained,
      if (fenced != null) 'fenced': fenced,
      // Convert DateTime list to Timestamp list for Firestore
      if (availableDates != null && availableDates!.isNotEmpty)
        'availableDates': availableDates!.map((date) => Timestamp.fromDate(date)).toList(),
      if (amenities != null && amenities!.isNotEmpty) 'amenities': amenities,
      // Note: id, clusterId, matchScore, distanceKm are not stored directly in the document map.
      // 'id' is the document ID, and the other three are derived values.
    };
  }

  // Factory constructor to create a Property object from a Firestore DocumentSnapshot
  factory Property.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError("Missing data for property ${snapshot.id}");
    }

    return Property(
      id: snapshot.id, // Set the id from the document ID
      type: data['type'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      imageUrl: data['imageUrl'] as String,
      location: data['location'] as String,
      price: (data['price'] as num).toDouble(), // Handle int/double from Firestore
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      bedrooms: data['bedrooms'] as int,
      bathrooms: data['bathrooms'] as int,
      areaSqFt: (data['areaSqFt'] as num).toDouble(),
      houseType: data['houseType'] as String?,
      selfContained: data['selfContained'] as bool?,
      fenced: data['fenced'] as bool?,
      // Convert Timestamp list back to DateTime list
      availableDates: (data['availableDates'] as List<dynamic>?)
          ?.map((timestamp) => (timestamp as Timestamp).toDate())
          .toList(),
      amenities: data['amenities'] != null
          ? Map<String, bool>.from(data['amenities']) // Ensure correct type mapping
          : null,
      // clusterId, matchScore, distanceKm are not loaded from Firestore
    );
  }

  // Helper to update algorithm-related fields (we'll use this later)
  Property copyWith({
    String? id, // Allow updating ID if needed, though typically not for existing properties
    String? type,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    double? price,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? areaSqFt,
    String? houseType,
    bool? selfContained,
    bool? fenced,
    List<DateTime>? availableDates,
    Map<String, bool>? amenities,
    int? clusterId,
    double? matchScore,
    double? distanceKm,
  }) {
    return Property(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      price: price ?? this.price,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      houseType: houseType ?? this.houseType,
      selfContained: selfContained ?? this.selfContained,
      fenced: fenced ?? this.fenced,
      availableDates: availableDates ?? this.availableDates,
      amenities: amenities ?? this.amenities,
      clusterId: clusterId ?? this.clusterId,
      matchScore: matchScore ?? this.matchScore,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}