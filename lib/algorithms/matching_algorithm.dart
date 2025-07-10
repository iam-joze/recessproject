import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/models/property.dart';

class MatchingAlgorithm {
  /// Calculates a match score (0-100) between user preferences and a property.
  /// This version includes more sophisticated logic and weighting.
  static double calculateMatchScore(UserPreferences preferences, Property property) {
    double score = 0;
    int maxPossibleScore = 0; // This will dynamically build based on preferences

    // --- Core Match (High Weight - Always considered) ---

    // Housing Type (Should already be filtered by DiscoverListingsScreen,
    // but contributes to score if it matches the preference for completeness)
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
      maxPossibleScore += 15; // NEW: Added weight for bedrooms
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
      // Note: Bedrooms logic for permanent moved to general criteria above.

    } else if (preferences.housingType == 'rental') {
      // Room Type
      if (preferences.roomType != null && preferences.roomType!.isNotEmpty) {
        maxPossibleScore += 20; // Part of rental specific
        if (property.roomType != null &&
            preferences.roomType!.toLowerCase() == property.roomType!.toLowerCase()) {
          score += 20;
        }
      }
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
      // Dates Availability (crucial for Airbnb)
      if (preferences.checkInDate != null && preferences.checkOutDate != null) {
        maxPossibleScore += 30; // High weight for date availability
        if (property.availableDates != null) {
          bool datesMatch = _checkAirbnbDateAvailability(
              preferences.checkInDate!, preferences.checkOutDate!, property.availableDates!);
          if (datesMatch) {
            score += 30;
          }
        }
      }

      // Guests Capacity (Property must accommodate at least preferred guests)
      if (preferences.guests != null) {
        maxPossibleScore += 20; // Medium weight for guest capacity
        if (property.maxGuests != null && preferences.guests! <= property.maxGuests!) {
          score += 20;
        }
      }

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

  /// Helper to check if a property is available for a given date range.
  static bool _checkAirbnbDateAvailability(
      DateTime checkIn, DateTime checkOut, List<DateTime> availableDates) {
    if (availableDates.isEmpty) return false;

    // Normalize availableDates to start of day for accurate comparison
    Set<DateTime> availableDatesSet = availableDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    // Iterate through each day in the requested range (inclusive of check-in, exclusive of check-out)
    for (DateTime d = DateTime(checkIn.year, checkIn.month, checkIn.day);
         d.isBefore(DateTime(checkOut.year, checkOut.month, checkOut.day));
         d = d.add(const Duration(days: 1))) {
      if (!availableDatesSet.contains(d)) {
        return false; // Not available on this day
      }
    }
    return true; // Available for the entire range
  }
}