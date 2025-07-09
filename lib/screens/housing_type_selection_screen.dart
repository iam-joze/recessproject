import 'package:flutter/material.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/models/user_preferences.dart'; // Import UserPreferences
import 'package:provider/provider.dart';
import 'package:housingapp/screens/notifications_screen.dart';
import 'package:housingapp/services/mock_notification_service.dart';
import 'package:housingapp/screens/discover_listings_screen.dart';
import 'package:housingapp/screens/saved_properties_screen.dart'; // Import saved properties screen

class HousingTypeSelectionScreen extends StatefulWidget {
  const HousingTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<HousingTypeSelectionScreen> createState() => _HousingTypeSelectionScreenState();
}

class _HousingTypeSelectionScreenState extends State<HousingTypeSelectionScreen> {
  String? _selectedHousingType; // To hold the selected type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Housing Type'),
        actions: [
          Consumer<MockNotificationService>( // Use Consumer to show unread count
            builder: (context, notificationService, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (notificationService.unreadCount > 0)
                    Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${notificationService.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark), // Bookmark icon for saved properties
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedPropertiesScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'What kind of home are you looking for?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildHousingTypeCard(
                context,
                'Permanent Home',
                Icons.house,
                'permanent',
              ),
              const SizedBox(height: 20),
              _buildHousingTypeCard(
                context,
                'Rental',
                Icons.apartment,
                'rental',
              ),
              const SizedBox(height: 20),
              _buildHousingTypeCard(
                context,
                'Airbnb',
                Icons.bed,
                'airbnb',
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Next',
                onPressed: _selectedHousingType == null
                    ? null // If null, the button will be disabled
                    : () {
                        // Save selected housing type using Provider
                        Provider.of<UserPreferences>(context, listen: false).updateHousingType(
                          _selectedHousingType!,
                        );
                        // Navigate directly to DiscoverListingsScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DiscoverListingsScreen()), // CHANGED NAVIGATION
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHousingTypeCard(
      BuildContext context, String title, IconData icon, String typeValue) {
    bool isSelected = _selectedHousingType == typeValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedHousingType = typeValue;
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}