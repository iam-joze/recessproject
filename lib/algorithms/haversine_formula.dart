import 'dart:math' show cos, sqrt, asin, sin, pi;

class HaversineFormula {
  // Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculates the distance between two geographical points (lat, lon) in kilometers
  /// using the Haversine formula.
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * asin(sqrt(a));
    var distance = earthRadiusKm * c; // Distance in km

    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}