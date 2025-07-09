import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';

class MatchingAlgorithm {
  /// Calculates a match score (0-100) between user preferences and a property.
  /// This version includes more sophisticated logic and weighting.
  static double calculateMatchScore(UserPreferences preferences, Property property) {
    double score = 0;
    int maxPossibleScore = 0;

    // --- Core Match (High Weight) ---
    // Housing Type (Should already be filtered, but adds to score confirmation)
    if (preferences.housingType == property.type) {
      score += 30; // High weight
    }
    maxPossibleScore += 30;

    // Location (More nuanced: exact match preferred, otherwise partial)
    if (preferences.location != null && preferences.location!.isNotEmpty) {
      maxPossibleScore += 25; // Medium-high weight
      if (property.location.toLowerCase() == preferences.location!.toLowerCase()) {
        score += 25; // Exact match
      } else if (property.location.toLowerCase().contains(preferences.location!.toLowerCase())) {
        score += 15; // Partial match
      }
    }

    // Budget (Penalize heavily if outside bounds)
    maxPossibleScore += 30; // High weight for budget
    bool budgetMatches = true;
    if (preferences.minBudget != null && property.price < preferences.minBudget!) {
      budgetMatches = false;
    }
    if (preferences.maxBudget != null && property.price > preferences.maxBudget!) {
      budgetMatches = false;
    }
    if (budgetMatches) {
      score += 30;
    }

    // --- Type-Specific Preferences ---

    if (preferences.housingType == 'permanent') {
      maxPossibleScore += 30; // Combined weight for permanent specific
      int permScore = 0;
      // House Type
      if (preferences.houseType != null && property.houseType != null &&
          preferences.houseType!.toLowerCase() == property.houseType!.toLowerCase()) {
        permScore += 20;
      }

      // Bedrooms (simple check, could be range later)
      if (property.bedrooms >= 3) { // Assume user prefers more bedrooms for permanent
          permScore += 10;
      }
      score += permScore;

    } else if (preferences.housingType == 'rental') {
      maxPossibleScore += 40; // Combined weight for rental specific
      int rentalScore = 0;
      // Room Type
      if (preferences.roomType != null && property.roomType != null &&
          preferences.roomType!.toLowerCase() == property.roomType!.toLowerCase()) {
        rentalScore += 20;
      }
      // Self-contained
      if (preferences.selfContained != null) {
        if (preferences.selfContained! == property.selfContained) {
          rentalScore += 10;
        }
      }
      // Fenced
      if (preferences.fenced != null) {
        if (preferences.fenced! == property.fenced) {
          rentalScore += 10;
        }
      }
      score += rentalScore;

    } else if (preferences.housingType == 'airbnb') {
      maxPossibleScore += 70; // Airbnb has more criteria
      int airbnbScore = 0;

      // Dates Availability (crucial for Airbnb)
      if (preferences.checkInDate != null && preferences.checkOutDate != null && property.availableDates != null) {
        bool datesMatch = _checkAirbnbDateAvailability(
            preferences.checkInDate!, preferences.checkOutDate!, property.availableDates!);
        if (datesMatch) {
          airbnbScore += 30; // High weight for date availability
        }
      }

      // Guests Capacity
      if (preferences.guests != null && property.maxGuests != null &&
          preferences.guests! <= property.maxGuests!) {
        airbnbScore += 20; // Medium weight for guest capacity
      }

      // Amenities Match
      if (preferences.airbnbAmenities.isNotEmpty) {
        int amenityMatches = 0;
        int preferredAmenitiesCount = preferences.airbnbAmenities.values.where((v) => v).length;
        if (preferredAmenitiesCount > 0) {
          preferences.airbnbAmenities.forEach((key, value) {
            if (value == true && property.amenities != null && property.amenities![key] == true) {
              amenityMatches++;
            }
          });
          // Proportional score for amenities, caps at 20 points
          airbnbScore += ((amenityMatches / preferredAmenitiesCount) * 20).toInt();
        }
      }
      score += airbnbScore;
    }

    // Normalize score to 100%
    if (maxPossibleScore == 0) return 0; // Avoid division by zero if no criteria applied
    double normalizedScore = (score / maxPossibleScore) * 100;

    // Ensure score is between 0 and 100
    return normalizedScore.clamp(0.0, 100.0);
  }

  /// Helper to check if a property is available for a given date range.
  static bool _checkAirbnbDateAvailability(
      DateTime checkIn, DateTime checkOut, List<DateTime> availableDates) {
    if (availableDates.isEmpty) return false;

    // Convert availableDates to a set of DateTimes for quick lookup
    Set<DateTime> availableDatesSet = availableDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // Iterate through each day in the requested range (exclusive of check-out day for simplicity)
    for (DateTime d = checkIn; d.isBefore(checkOut); d = d.add(const Duration(days: 1))) {
      if (!availableDatesSet.contains(DateTime(d.year, d.month, d.day))) {
        return false; // Not available on this day
      }
    }
    return true; // Available for the entire range
  }
}