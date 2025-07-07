import 'package:flutter/foundation.dart';

class UserPreferences with ChangeNotifier {
  String? _name;
  String? _phoneNumber;
  String? _housingType; // permanent, rental, airbnb

  // Getters
  String? get name => _name;
  String? get phoneNumber => _phoneNumber;
  String? get housingType => _housingType;

  void updateUserDetails({required String name, required String phoneNumber}) {
    _name = name;
    _phoneNumber = phoneNumber;
    notifyListeners(); // Notify widgets listening to this model
  }

  void updateHousingType(String type) {
    _housingType = type;
    notifyListeners();
  }

  // You can add more methods here to update other preferences as we go
  // e.g., updateLocation, updateBudget, etc.
}