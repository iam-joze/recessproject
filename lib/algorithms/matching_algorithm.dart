import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';

class MatchingAlgorithm {
  /// Calculates a basic match score (0-100) between user preferences and a property.
  /// This is a simplified version and will be enhanced later.
  static double calculateMatchScore(UserPreferences preferences, Property property) {
    double score = 0;
    int maxPossibleScore = 0; // To normalize the score to 100%

    // --- Common Preferences ---

    // Housing Type (should already be filtered, but good for scoring)
    if (preferences.housingType == property.type) {
      score += 20;
    }
    maxPossibleScore += 20;

    // Location (fuzzy match - could be improved with geo-fencing or more robust string matching)
    if (preferences.location != null && preferences.location!.isNotEmpty) {
      maxPossibleScore += 15;
      if (property.location.toLowerCase().contains(preferences.location!.toLowerCase())) {
        score += 15;
      }
    }

    // Budget
    if (preferences.minBudget != null && property.price >= preferences.minBudget!) {
      score += 10;
    }
    maxPossibleScore += 10;

    if (preferences.maxBudget != null && property.price <= preferences.maxBudget!) {
      score += 10;
    }
    maxPossibleScore += 10;

    // --- Type-Specific Preferences ---

    if (preferences.housingType == 'permanent') {
      // House Type
      if (preferences.houseType != null && property.houseType != null &&
          preferences.houseType!.toLowerCase() == property.houseType!.toLowerCase()) {
        score += 20;
      }
      maxPossibleScore += 20;
    } else if (preferences.housingType == 'rental') {
      // Room Type
      if (preferences.roomType != null && property.roomType != null &&
          preferences.roomType!.toLowerCase() == property.roomType!.toLowerCase()) {
        score += 20;
      }
      maxPossibleScore += 20;

      // Self-contained
      if (preferences.selfContained != null && preferences.selfContained == property.selfContained) {
        score += 10;
      }
      maxPossibleScore += 10;

      // Fenced
      if (preferences.fenced != null && preferences.fenced == property.fenced) {
        score += 10;
      }
      maxPossibleScore += 10;

    } else if (preferences.housingType == 'airbnb') {
      // For Airbnb, we'll implement more robust matching in Phase 4 (dates, guests, amenities)
      // For now, a placeholder for amenities
      if (preferences.airbnbAmenities.isNotEmpty) {
        int amenityMatches = 0;
        int preferredAmenitiesCount = preferences.airbnbAmenities.values.where((v) => v).length;
        if (preferredAmenitiesCount > 0) {
            maxPossibleScore += 20; // Max score for amenities
            preferences.airbnbAmenities.forEach((key, value) {
                if (value == true && property.amenities != null && property.amenities![key] == true) {
                    amenityMatches++;
                }
            });
            score += (amenityMatches / preferredAmenitiesCount) * 20; // Proportional score
        }
      }
    }

    // Normalize score to 100%
    if (maxPossibleScore == 0) return 0; // Avoid division by zero
    double normalizedScore = (score / maxPossibleScore) * 100;

    // Ensure score is between 0 and 100
    return normalizedScore.clamp(0.0, 100.0);
  }
}