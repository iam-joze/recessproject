// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
//import 'package:housingapp/models/property.dart';

class UserPreferences with ChangeNotifier {
  String? _uid;
  String? _name;
  String? _email;
  String? _housingType;

  String? _location;
  double? _minBudget;
  double? _maxBudget;
  int? _bedrooms;
  int? _bathrooms;

  String? _houseType;

  bool? _selfContained;
  bool? _fenced;

  int? _guests;
  Map<String, bool> _airbnbAmenities = {};

  final List<String> _savedPropertyIds = [];

  String? _fcmToken;

  UserPreferences(); // This allows UserPreferences() to be called.

  // --- Getters ---
  String? get uid => _uid;
  String? get name => _name;
  String? get email => _email;
  String? get housingType => _housingType;
  String? get location => _location;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  int? get bedrooms => _bedrooms;
  int? get bathrooms => _bathrooms;
  String? get houseType => _houseType;
  bool? get selfContained => _selfContained;
  bool? get fenced => _fenced;
  int? get guests => _guests;
  Map<String, bool> get airbnbAmenities => _airbnbAmenities;
  List<String> get savedPropertyIds => List.unmodifiable(_savedPropertyIds);
  String? get fcmToken => _fcmToken;

  // --- Firestore Integration Methods ---

  Map<String, dynamic> toFirestore() {
    return {
      if (_fcmToken != null) "fcmToken": _fcmToken,
      if (_name != null) "name": _name,
      if (_email != null) "email": _email,
      if (_housingType != null) "housingType": _housingType,
      if (_location != null) "location": _location,
      if (_minBudget != null) "minBudget": _minBudget,
      if (_maxBudget != null) "maxBudget": _maxBudget,
      if (_bedrooms != null) "bedrooms": _bedrooms,
      if (_bathrooms != null) "bathrooms": _bathrooms,
      if (_houseType != null) "houseType": _houseType,
      if (_selfContained != null) "selfContained": _selfContained,
      if (_fenced != null) "fenced": _fenced,
      if (_guests != null) "guests": _guests,
      if (_airbnbAmenities.isNotEmpty) "airbnbAmenities": _airbnbAmenities,
      if (_savedPropertyIds.isNotEmpty) "savedPropertyIds": _savedPropertyIds,
    };
  }

  factory UserPreferences.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final prefs = UserPreferences(); 
    prefs._uid = snapshot.id;
    prefs._name = data?['name'] as String?;
    prefs._email = data?['email'] as String?;
    prefs._housingType = data?['housingType'] as String?;
    prefs._location = data?['location'] as String?;
    prefs._minBudget = data?['minBudget'] as double?;
    prefs._maxBudget = data?['maxBudget'] as double?;
    prefs._bedrooms = data?['bedrooms'] as int?;
    prefs._bathrooms = data?['bathrooms'] as int?;
    prefs._houseType = data?['houseType'] as String?;
    prefs._selfContained = data?['selfContained'] as bool?;
    prefs._fenced = data?['fenced'] as bool?;
    prefs._guests = data?['guests'] as int?;
    if (data?['airbnbAmenities'] is Map) {
      prefs._airbnbAmenities = Map<String, bool>.from(data!['airbnbAmenities']);
    }
    if (data?['savedPropertyIds'] is List) {
      prefs._savedPropertyIds.addAll(List<String>.from(data!['savedPropertyIds']));
    }
    prefs._fcmToken = data?['fcmToken'] as String?;
    return prefs;
  }

  // --- Setters / Updaters (Now includes Firestore saving) ---

  Future<void> updateUserDetails({String? uid, required String name, required String email}) async {
    if (uid == null) {
      Logger('UserPreferences').severe("Error: UID is required to save user details to Firestore.");
      return;
    }
    _uid = uid;
    _name = name;
    _email = email;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    await userDocRef.set({
      'name': _name,
      'email': _email,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    notifyListeners();
  }

  Future<void> updateFcmToken(String? token) async {
    if (_uid == null) {
      Logger('UserPreferences').severe("Error: UID is required to update FCM token.");
      return;
    }
    if (_fcmToken == token) {
      // Token hasn't changed, no need to update Firestore
      return;
    }

    _fcmToken = token;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(_uid);
    await userDocRef.set({
      'fcmToken': _fcmToken,
      'lastTokenUpdated': FieldValue.serverTimestamp(), // Optional timestamp
    }, SetOptions(merge: true));

    notifyListeners();
    Logger('UserPreferences').info("FCM Token updated and saved for user $_uid");
  }

  Future<void> loadUserDetails(String uid) async {
    _uid = uid;
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnapshot = await userDocRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        _name = data['name'] as String?;
        _email = data['email'] as String?;
        _housingType = data['housingType'] as String?;
        _location = data['location'] as String?;
        _minBudget = data['minBudget'] as double?;
        _maxBudget = data['maxBudget'] as double?;
        _bedrooms = data['bedrooms'] as int?;
        _bathrooms = data['bathrooms'] as int?;
        _houseType = data['houseType'] as String?;
        _selfContained = data['selfContained'] as bool?;
        _fenced = data['fenced'] as bool?;
        _guests = data['guests'] as int?;
        if (data['airbnbAmenities'] is Map) {
          _airbnbAmenities = Map<String, bool>.from(data['airbnbAmenities']);
        }
        if (data['savedPropertyIds'] is List) {
          _savedPropertyIds.clear();
          _savedPropertyIds.addAll(List<String>.from(data['savedPropertyIds']));
        }
      }
    } else {
      Logger('UserPreferences').warning("User preferences document for $uid does not exist in Firestore.");
    }
    notifyListeners();
  }

  void updateHousingType(String type) {
    _housingType = type;
    _location = null;
    _minBudget = null;
    _maxBudget = null;
    _bedrooms = null;
    _bathrooms = null;
    _houseType = null;
    _selfContained = null;
    _fenced = null;
    _guests = null;
    _airbnbAmenities = {};
    notifyListeners();
  }

  Future<void> updateLocation(String? location) async {
    _location = location;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'location': _location, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateBudgetRange({double? min, double? max}) async {
    _minBudget = min;
    _maxBudget = max;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'minBudget': _minBudget, 'maxBudget': _maxBudget, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateBedrooms(int? bedrooms) async {
    _bedrooms = bedrooms;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'bedrooms': _bedrooms, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateBathrooms(int? bathrooms) async {
    _bathrooms = bathrooms;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'bathrooms': _bathrooms, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateHouseType(String? type) async {
    _houseType = type;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'houseType': _houseType, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateRentalDetails({bool? selfContained, bool? fenced}) async {
    _selfContained = selfContained;
    _fenced = fenced;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'selfContained': _selfContained, 'fenced': _fenced, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> updateAirbnbDetails({
    int? guests,
    Map<String, bool>? amenities,
  }) async {
    _guests = guests;
    _airbnbAmenities = amenities ?? {};
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).set(
        {'guests': _guests, 'airbnbAmenities': _airbnbAmenities, 'lastUpdated': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
    notifyListeners();
  }

  Future<void> toggleAirbnbAmenity(String amenityKey, bool value) async {
    _airbnbAmenities[amenityKey] = value;
    if (_uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update(
        {'airbnbAmenities.$amenityKey': value, 'lastUpdated': FieldValue.serverTimestamp()},
      );
    }
    notifyListeners();
  }

  Future<void> addSavedProperty(String propertyId) async {
    if (_uid == null) return;
    if (!_savedPropertyIds.contains(propertyId)) {
      _savedPropertyIds.add(propertyId);
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'savedPropertyIds': FieldValue.arrayUnion([propertyId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      Logger('UserPreferences').info('Property $propertyId saved!');
    }
  }

  Future<void> removeSavedProperty(String propertyId) async {
    if (_uid == null) return;
    if (_savedPropertyIds.remove(propertyId)) {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'savedPropertyIds': FieldValue.arrayRemove([propertyId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      notifyListeners();
      Logger('UserPreferences').info('Property $propertyId unsaved!');
    }
  }

  bool isPropertySaved(String propertyId) {
    return _savedPropertyIds.contains(propertyId);
  }

  void resetPreferences() {
    _uid = null;
    _name = null;
    _email = null;
    _housingType = null;
    _location = null;
    _minBudget = null;
    _maxBudget = null;
    _bedrooms = null;
    _bathrooms = null;
    _houseType = null;
    _selfContained = null;
    _fenced = null;
    _guests = null;
    _airbnbAmenities = {};
    _savedPropertyIds.clear();
    _fcmToken = null;
    notifyListeners();
  }
}