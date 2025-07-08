import 'package:flutter/foundation.dart';
import 'package:housingapp/models/property.dart';

class UserPreferences with ChangeNotifier {
  String? _name;
  String? _phoneNumber;
  String? _housingType; // permanent, rental, airbnb

  // Common preferences
  String? _location; // Preferred region/city
  double? _minBudget;
  double? _maxBudget;

  // Permanent Home / Rental specific
  String? _houseType; // apartment, bungalow, etc. (for Permanent Home)
  String? _roomType; // e.g., 1-bedroom, 2-bedroom (for Rental)
  bool? _selfContained; // (for Rental)
  bool? _fenced; // (for Rental)

  // Airbnb specific
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int? _guests;
  Map<String, bool> _airbnbAmenities = {}; // e.g., {'kitchen': true, 'wifi': false}

  final List<String> _savedPropertyIds = []; // Store IDs of saved properties

  // --- Getters ---
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;
  String? get housingType => _housingType;
  String? get location => _location;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  String? get houseType => _houseType;
  String? get roomType => _roomType;
  bool? get selfContained => _selfContained;
  bool? get fenced => _fenced;
  DateTime? get checkInDate => _checkInDate;
  DateTime? get checkOutDate => _checkOutDate;
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
    // Clear other type-specific preferences when type changes
    _location = null;
    _minBudget = null;
    _maxBudget = null;
    _houseType = null;
    _roomType = null;
    _selfContained = null;
    _fenced = null;
    _checkInDate = null;
    _checkOutDate = null;
    _guests = null;
    _airbnbAmenities = {};
    notifyListeners();
  }

  // For Permanent Home & Rental
  void updateLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void updateBudgetRange({double? min, double? max}) {
    _minBudget = min;
    _maxBudget = max;
    notifyListeners();
  }

  // For Permanent Home
  void updateHouseType(String type) {
    _houseType = type;
    notifyListeners();
  }

  // For Rental
  void updateRentalDetails({String? roomType, bool? selfContained, bool? fenced}) {
    _roomType = roomType ?? _roomType;
    _selfContained = selfContained ?? _selfContained;
    _fenced = fenced ?? _fenced;
    notifyListeners();
  }

  // For Airbnb
  void updateAirbnbDetails({
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    Map<String, bool>? amenities,
  }) {
    _checkInDate = checkIn ?? _checkInDate;
    _checkOutDate = checkOut ?? _checkOutDate;
    _guests = guests ?? _guests;
    if (amenities != null) {
      _airbnbAmenities = amenities;
    }
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
    _houseType = null;
    _roomType = null;
    _selfContained = null;
    _fenced = null;
    _checkInDate = null;
    _checkOutDate = null;
    _guests = null;
    _airbnbAmenities = {};
    notifyListeners();
  }
}