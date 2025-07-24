const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
// This allows your Cloud Function to interact with other Firebase services
// like Firestore and FCM (Firebase Cloud Messaging).
admin.initializeApp();

// Get references to Firestore collections
const db = admin.firestore();
const usersCollection = db.collection("users");
const propertiesCollection = db.collection("properties");

/**
 * Cloud Function triggered when a new property document is created in Firestore.
 * It checks if the new property matches any user's preferences and sends
 * a push notification to those users.
 */
exports.onNewPropertyCreated = functions.firestore
    .document("properties/{propertyId}")
    .onCreate(async (snapshot, context) => {
      const newProperty = snapshot.data();
      const propertyId = snapshot.id;
      console.log(`New property created: ${newProperty.title} (ID: ${propertyId})`);

      // 1. Fetch all user preferences
      let usersSnapshot;
      try {
        usersSnapshot = await usersCollection.get();
      } catch (error) {
        console.error("Error fetching users:", error);
        return null; // Stop execution if we can't get users
      }

      const notificationPromises = [];

      // 2. Iterate through each user to check for matches
      usersSnapshot.forEach((userDoc) => {
        const userPrefs = userDoc.data();
        const userId = userDoc.id;
        const fcmToken = userPrefs.fcmToken;

        // Only proceed if the user has an FCM token and their preferences are somewhat complete
        if (!fcmToken || !userPrefs.housingType) {
          console.log(`Skipping user ${userId}: No FCM token or housing type preference.`);
          return; // Continue to the next user
        }

        // --- 3. Implement Matching Logic ---
        // This is the core of your notification system.
        // Adjust this logic to be as detailed as your UserPreferences model allows.

        let isMatch = true;

        // Match by Housing Type
        if (userPrefs.housingType && newProperty.type !== userPrefs.housingType) {
          isMatch = false;
        }

        // Match by Location (exact match for simplicity; fuzzy search is complex for Firestore)
        if (isMatch && userPrefs.location && newProperty.location) {
          // Case-insensitive comparison
          if (newProperty.location.toLowerCase() !== userPrefs.location.toLowerCase()) {
            isMatch = false;
          }
        }

        // Match by Budget
        if (isMatch && userPrefs.minBudget !== undefined && newProperty.price < userPrefs.minBudget) {
          isMatch = false;
        }
        if (isMatch && userPrefs.maxBudget !== undefined && newProperty.price > userPrefs.maxBudget) {
          isMatch = false;
        }

        // Match by Bedrooms
        if (isMatch && userPrefs.bedrooms !== undefined && newProperty.bedrooms < userPrefs.bedrooms) { // min bedrooms
          isMatch = false;
        }

        // Match by Bathrooms
        if (isMatch && userPrefs.bathrooms !== undefined && newProperty.bathrooms < userPrefs.bathrooms) { // min bathrooms
          isMatch = false;
        }

        // --- Type-Specific Filters ---
        if (isMatch) {
          switch (userPrefs.housingType) {
            case "permanent":
              if (userPrefs.houseType && newProperty.houseType !== userPrefs.houseType) {
                isMatch = false;
              }
              break;
            case "rental":
              if (userPrefs.selfContained !== undefined && newProperty.selfContained !== undefined && newProperty.selfContained !== userPrefs.selfContained) {
                isMatch = false;
              }
              if (userPrefs.fenced !== undefined && newProperty.fenced !== undefined && newProperty.fenced !== userPrefs.fenced) {
                isMatch = false;
              }
              break;
            case "airbnb":
              if (userPrefs.guests !== undefined && newProperty.guests !== undefined && newProperty.guests < userPrefs.guests) { // Property must accommodate at least user's min guests
                isMatch = false;
              }
              // Amenities matching (example: all user's *required* amenities must be present)
              if (userPrefs.airbnbAmenities) {
                for (const amenityKey in userPrefs.airbnbAmenities) {
                  if (userPrefs.airbnbAmenities[amenityKey] === true) { // If user requires this amenity
                    if (!newProperty.amenities || newProperty.amenities[amenityKey] !== true) {
                      isMatch = false;
                      break; // No need to check further amenities for this user
                    }
                  }
                }
              }
              break;
          }
        }

        // If it's a match, prepare and send the notification
        if (isMatch) {
          console.log(`Property matches preferences for user: ${userId}`);

          const payload = {
            notification: {
              title: `New ${newProperty.type} property available!`,
              body: `${newProperty.title} in ${newProperty.location} for \$${newProperty.price}. Check it out!`,
              imageUrl: newProperty.imageUrl || "", // Optional: Add an image to the notification
            },
            data: {
              propertyId: propertyId, // Pass property ID to the app for deep linking
              screen: "propertyDetail", // Can be used by the app to navigate
            // You can add more data fields here
            },
          };

          // Send notification to the user's device
          notificationPromises.push(
              admin.messaging().sendToDevice(fcmToken, payload)
                  .then((response) => {
                    const successCount = response.successCount;
                    const failureCount = response.failureCount;
                    console.log(`Notification sent to user ${userId}: Success=${successCount}, Failure=${failureCount}`);

                    // Handle invalid tokens (e.g., remove from user's document)
                    if (failureCount > 0) {
                      response.results.forEach((result, index) => {
                        const error = result.error;
                        if (error && (error.code === "messaging/invalid-registration-token" ||
                                error.code === "messaging/registration-token-not-registered")) {
                          console.error(`Invalid FCM token for user ${userId}. Removing token.`);
                          // Remove the invalid token from Firestore
                          usersCollection.doc(userId).update({
                            fcmToken: admin.firestore.FieldValue.delete(),
                          })
                              .then(() => console.log(`FCM token deleted for user ${userId}`))
                              .catch((err) => console.error(`Error deleting FCM token for user ${userId}:`, err));
                        }
                      });
                    }
                    return response;
                  })
                  .catch((error) => {
                    console.error(`Error sending notification to user ${userId}:`, error);
                    return Promise.reject(error); // Propagate error
                  }),
          );
        }
      });

      // Wait for all notification promises to resolve
      await Promise.allSettled(notificationPromises);

      console.log("Finished processing new property notification.");
      return null; // Cloud Functions should return null or a Promise that resolves to null
    });
