import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';

class MatchingAlgorithm {
  /// Calculates a match score (0-100) between user preferences and a property.
  static double calculateMatchScore(UserPreferences preferences, Property property) {
    double score = 0;
    int maxPossibleScore = 0; // This will dynamically build based on preferences
    // --- Core Match (High Weight - Always considered) ---
    if (preferences.housingType == property.type) {
      score += 30;
    }
    maxPossibleScore += 30;

    // Location (More nuanced: exact match preferred, otherwise partial)
    if (preferences.location != null && preferences.location!.isNotEmpty) {
      maxPossibleScore += 25;
      if (property.location.toLowerCase() == preferences.location!.toLowerCase()) {
        score += 25; // Exact match
      } else if (property.location.toLowerCase().contains(preferences.location!.toLowerCase())) {
        score += 15; // Partial match
      }
    }

    // Budget (Penalize heavily if outside bounds)
    maxPossibleScore += 30;
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

    // Bedrooms (General preference: property must have at least the preferred number)
    if (preferences.bedrooms != null) {
      maxPossibleScore += 15; // Added weight for bedrooms
      if (property.bedrooms >= preferences.bedrooms!) {
        score += 15;
      }
    }

    // Bathrooms (General preference: property must have at least the preferred number)
    if (preferences.bathrooms != null) {
      maxPossibleScore += 15; // NEW: Added weight for bathrooms
      if (property.bathrooms >= preferences.bathrooms!) {
        score += 15;
      }
    }

    // --- Type-Specific Preferences (Conditional Weighting) ---
    // These only add to maxPossibleScore if the corresponding preference is set.

    if (preferences.housingType == 'permanent') {
      // House Type (e.g., apartment, bungalow)
      if (preferences.houseType != null && preferences.houseType!.isNotEmpty) {
        maxPossibleScore += 20; // Adjusted weight for permanent specific (was 30 with bedrooms)
        if (property.houseType != null &&
            preferences.houseType!.toLowerCase() == property.houseType!.toLowerCase()) {
          score += 20;
        }
      }

    } else if (preferences.housingType == 'rental') {
      // Self-contained
      if (preferences.selfContained != null) {
        maxPossibleScore += 10; // Part of rental specific
        if (preferences.selfContained! == property.selfContained) {
          score += 10;
        }
      }
      // Fenced
      if (preferences.fenced != null) {
        maxPossibleScore += 10; // Part of rental specific
        if (preferences.fenced! == property.fenced) {
          score += 10;
        }
      }

    } else if (preferences.housingType == 'airbnb') {
      // Amenities Match
      if (preferences.airbnbAmenities.isNotEmpty) {
        int preferredAmenitiesCount = preferences.airbnbAmenities.values.where((v) => v).length;
        if (preferredAmenitiesCount > 0) {
          maxPossibleScore += 20; // Max points for amenities
          int amenityMatches = 0;
          preferences.airbnbAmenities.forEach((key, value) {
            if (value == true && property.amenities != null && property.amenities![key] == true) {
              amenityMatches++;
            }
          });
          // Proportional score for amenities
          score += ((amenityMatches / preferredAmenitiesCount) * 20).toInt();
        }
      }
    }

    // Normalize score to 100%
    if (maxPossibleScore == 0) return 0; // Avoid division by zero if no criteria applied
    double normalizedScore = (score / maxPossibleScore) * 100;

    // Ensure score is between 0 and 100
    return normalizedScore.clamp(0.0, 100.0);
  }
}