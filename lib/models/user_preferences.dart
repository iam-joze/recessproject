import 'package:flutter/foundation.dart';
import 'package:housingapp/models/property.dart'; // Although Property model still has roomType, UserPreferences no longer cares about it.

class UserPreferences with ChangeNotifier {
  String? _name;
  String? _phoneNumber;
  String? _housingType; // permanent, rental, airbnb

  // Common preferences for matching
  String? _location; // Preferred region/city
  double? _minBudget;
  double? _maxBudget;
  int? _bedrooms; // NEW: Added for general property matching
  int? _bathrooms; // NEW: Added for general property matching

  // Permanent Home specific
  String? _houseType; // apartment, bungalow, etc. (for Permanent Home)

  // Rental specific
  bool? _selfContained; // (for Rental)
  bool? _fenced; // (for Rental)

  // Airbnb specific
  // REMOVED: DateTime? _checkInDate;
  // REMOVED: DateTime? _checkOutDate;
  int? _guests; // Corresponds to maxGuests in Property for matching
  Map<String, bool> _airbnbAmenities = {}; // e.g., {'kitchen': true, 'wifi': false}

  final List<String> _savedPropertyIds = []; // Store IDs of saved properties

  // --- Getters ---
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;
  String? get housingType => _housingType;
  String? get location => _location;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  int? get bedrooms => _bedrooms; // NEW getter
  int? get bathrooms => _bathrooms; // NEW getter
  String? get houseType => _houseType;
  bool? get selfContained => _selfContained;
  bool? get fenced => _fenced;
  // REMOVED: DateTime? get checkInDate => _checkInDate;
  // REMOVED: DateTime? get checkOutDate => _checkOutDate;
  int? get guests => _guests;
  Map<String, bool> get airbnbAmenities => _airbnbAmenities;
  List<String> get savedPropertyIds => List.unmodifiable(_savedPropertyIds);

  // --- Setters / Updaters ---
  void updateUserDetails({required String name, required String phoneNumber}) {
    _name = name;
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  void updateHousingType(String type) {
    _housingType = type;
    // Clear ALL other type-specific and common preferences when type changes
    _location = null;
    _minBudget = null;
    _maxBudget = null;
    _bedrooms = null; // Clear on type change
    _bathrooms = null; // Clear on type change
    _houseType = null;
    _selfContained = null;
    _fenced = null;
    // REMOVED: _checkInDate = null;
    // REMOVED: _checkOutDate = null;
    _guests = null;
    _airbnbAmenities = {};
    notifyListeners();
  }

  // Common preference updaters
  void updateLocation(String? location) { // Made nullable for clearing
    _location = location;
    notifyListeners();
  }

  void updateBudgetRange({double? min, double? max}) {
    _minBudget = min;
    _maxBudget = max;
    notifyListeners();
  }

  void updateBedrooms(int? bedrooms) { // NEW updater
    _bedrooms = bedrooms;
    notifyListeners();
  }

  void updateBathrooms(int? bathrooms) { // NEW updater
    _bathrooms = bathrooms;
    notifyListeners();
  }

  // For Permanent Home
  void updateHouseType(String? type) { // Made nullable for clearing
    _houseType = type;
    notifyListeners();
  }

  // For Rental
  void updateRentalDetails({bool? selfContained, bool? fenced}) {
    _selfContained = selfContained;
    _fenced = fenced;
    notifyListeners();
  }

  // For Airbnb
  void updateAirbnbDetails({
    // REMOVED: DateTime? checkIn,
    // REMOVED: DateTime? checkOut,
    int? guests,
    Map<String, bool>? amenities,
  }) {
    // REMOVED: _checkInDate = checkIn;
    // REMOVED: _checkOutDate = checkOut;
    _guests = guests;
    _airbnbAmenities = amenities ?? {}; // Directly assign or empty map
    notifyListeners();
  }

  void toggleAirbnbAmenity(String amenityKey, bool value) {
    _airbnbAmenities[amenityKey] = value;
    notifyListeners();
  }

  void addSavedProperty(String propertyId) {
    if (!_savedPropertyIds.contains(propertyId)) {
      _savedPropertyIds.add(propertyId);
      notifyListeners();
      print('Property $propertyId saved!'); // For debugging
    }
  }

  void removeSavedProperty(String propertyId) {
    if (_savedPropertyIds.remove(propertyId)) {
      notifyListeners();
      print('Property $propertyId unsaved!'); // For debugging
    }
  }

  bool isPropertySaved(String propertyId) {
    return _savedPropertyIds.contains(propertyId);
  }

  // Reset all preferences (e.g., for logout or starting over)
  void resetPreferences() {
    _name = null;
    _phoneNumber = null;
    _housingType = null;
    _location = null;
    _minBudget = null;
    _maxBudget = null;
    _bedrooms = null;
    _bathrooms = null;
    _houseType = null;
    _selfContained = null;
    _fenced = null;
    // REMOVED: _checkInDate = null;
    // REMOVED: _checkOutDate = null;
    _guests = null;
    _airbnbAmenities = {};
    _savedPropertyIds.clear(); // Also clear saved properties on full reset
    notifyListeners();
  }
}