// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/models/user_preferences.dart'; // To use user preferences for filtering

class PropertyService {

  // Collection reference for properties
  final CollectionReference _propertiesCollection =
      FirebaseFirestore.instance.collection('properties');

  // --- Public Methods ---

  /// Fetches a stream of all properties from Firestore.
  Stream<List<Property>> getPropertiesStream() {
    return _propertiesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Property.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null)).toList();
    });
  }

  /// Fetches a stream of properties filtered by the user's current preferences.
  /// It listens to changes in UserPreferences to re-filter the results.
  Stream<List<Property>> getFilteredPropertiesStream(UserPreferences userPreferences) {
    // Start with a base query
    Query query = _propertiesCollection;

    // Apply housing type filter if set
    if (userPreferences.housingType != null && userPreferences.housingType!.isNotEmpty) {
      query = query.where('type', isEqualTo: userPreferences.housingType);
    }

    // Apply other filters based on userPreferences
    // Example: Location filter (case-insensitive search requires more complex solutions or exact match)
    if (userPreferences.location != null && userPreferences.location!.isNotEmpty) {
      // For exact match
      query = query.where('location', isEqualTo: userPreferences.location);
      // For case-insensitive or partial match, you'd need client-side filtering after fetching
      // or a dedicated search service (e.g., Algolia, ElasticSearch)
    }

    if (userPreferences.minBudget != null) {
      query = query.where('price', isGreaterThanOrEqualTo: userPreferences.minBudget);
    }
    if (userPreferences.maxBudget != null) {
      query = query.where('price', isLessThanOrEqualTo: userPreferences.maxBudget);
    }
    if (userPreferences.bedrooms != null) {
      query = query.where('bedrooms', isEqualTo: userPreferences.bedrooms);
    }
    if (userPreferences.bathrooms != null) {
      query = query.where('bathrooms', isEqualTo: userPreferences.bathrooms);
    }

    // Type-specific filters (example for Permanent Home)
    if (userPreferences.housingType == 'permanent' && userPreferences.houseType != null) {
      query = query.where('houseType', isEqualTo: userPreferences.houseType);
    }

    // Type-specific filters (example for Rental)
    if (userPreferences.housingType == 'rental') {
      if (userPreferences.selfContained != null) {
        query = query.where('selfContained', isEqualTo: userPreferences.selfContained);
      }
      if (userPreferences.fenced != null) {
        query = query.where('fenced', isEqualTo: userPreferences.fenced);
      }
    }

    // Type-specific filters (example for Airbnb)
    if (userPreferences.housingType == 'airbnb') {
      // REMOVED: guests filter
      userPreferences.airbnbAmenities.forEach((amenityKey, isSelected) {
        if (isSelected) {
          // This creates a query like where('amenities.wifi', isEqualTo: true)
          // Ensure your Firestore documents have this nested structure for 'amenities'
          query = query.where('amenities.$amenityKey', isEqualTo: true);
        }
      });
    }

    // Order results (optional)
    query = query.orderBy('price', descending: false); // Order by price ascending

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Property.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null)).toList();
    });
  }

  /// Adds a new property to Firestore.
  Future<void> addProperty(Property property) async {
    try {
      // For adding, you often let Firestore generate the ID, or use property.id if it's pre-generated.
      // If property.id is empty/null, add() generates one. If it's set, use set() with the ID.
      if (property.id.isEmpty) {
        await _propertiesCollection.add(property.toFirestore());
      } else {
        await _propertiesCollection.doc(property.id).set(property.toFirestore());
      }
      //print('Property added/updated successfully: ${property.title}');
    } catch (e) {
      //print('Error adding property: $e');
      rethrow;
    }
  }

  // You can add more methods here: updateProperty, deleteProperty, getPropertyById, etc.
}