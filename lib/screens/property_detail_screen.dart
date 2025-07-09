import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:housingapp/widgets/custom_button.dart'; // Ensure CustomButton is imported

// Assuming you have a MockNotificationService for later. Add this import for now.
import 'package:housingapp/services/mock_notification_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late bool _isPropertySaved;

  @override
  void initState() {
    super.initState();
    _isPropertySaved = Provider.of<UserPreferences>(context, listen: false)
        .isPropertySaved(widget.property.id);
  }

  String _formatPrice(double price, String type) {
    final formatter = NumberFormat.currency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    String period = '';
    if (type == 'rental') {
      period = '/month';
    } else if (type == 'airbnb') {
      period = '/night';
    }
    return formatter.format(price) + period;
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppStyles.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Chip(
      label: Text(
        amenity[0].toUpperCase() + amenity.substring(1),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppStyles.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: Text(
                widget.property.title, // Use widget.property
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 3.0,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: 'propertyImage_${widget.property.id}',
                child: Image.network(
                  widget.property.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppStyles.lightGrey,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: AppStyles.darkGrey, size: 80),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPrice(widget.property.price, widget.property.type),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppStyles.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 24, color: AppStyles.darkGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.property.location,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppStyles.darkGrey,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.property.distanceKm != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${widget.property.distanceKm!.toStringAsFixed(1)} km away',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppStyles.darkGrey,
                                ),
                          ),
                        ),
                      const Divider(height: 32),
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.property.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureRow(Icons.king_bed, '${widget.property.bedrooms} Bedrooms'),
                      _buildFeatureRow(Icons.bathtub, '${widget.property.bathrooms} Bathrooms'),
                      _buildFeatureRow(Icons.square_foot, '${widget.property.areaSqFt} SqFt'),
                      if (widget.property.type == 'permanent' && widget.property.houseType != null)
                        _buildFeatureRow(Icons.architecture, 'Type: ${widget.property.houseType![0].toUpperCase() + widget.property.houseType!.substring(1)}'),
                      if (widget.property.type == 'rental' && widget.property.roomType != null)
                        _buildFeatureRow(Icons.room_preferences, 'Room Type: ${widget.property.roomType![0].toUpperCase() + widget.property.roomType!.substring(1)}'),
                      if (widget.property.selfContained == true)
                        _buildFeatureRow(Icons.lock, 'Self-contained'),
                      if (widget.property.fenced == true)
                        _buildFeatureRow(Icons.fence, 'Fenced Compound'),
                      if (widget.property.type == 'airbnb' && widget.property.maxGuests != null)
                        _buildFeatureRow(Icons.group, 'Max Guests: ${widget.property.maxGuests}'),

                      const Divider(height: 32),

                      if (widget.property.type == 'airbnb' && widget.property.amenities != null && widget.property.amenities!.isNotEmpty) ...[
                        Text(
                          'Amenities',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: widget.property.amenities!.entries
                              .where((entry) => entry.value)
                              .map((entry) => _buildAmenityChip(entry.key))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Match Score if available
                      if (widget.property.matchScore != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppStyles.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: AppStyles.accentColor, size: 30),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'This property is a ${widget.property.matchScore!.toInt()}% match for your preferences!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppStyles.darkGrey,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: widget.property.type == 'airbnb' ? 'Book Now' : 'Contact Landlord',
                        onPressed: () {
                          if (widget.property.type == 'airbnb') {
                            _showAirbnbBookingDialog(context, widget.property); // Call new booking dialog
                          } else {
                            _showContactSuccessDialog(context); // Existing contact dialog
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: _isPropertySaved ? 'Unsave Property' : 'Save Property',
                        color: _isPropertySaved ? Colors.red.shade400 : Colors.blueGrey,
                        onPressed: () {
                          final preferences = Provider.of<UserPreferences>(context, listen: false);
                          setState(() {
                            if (_isPropertySaved) {
                              preferences.removeSavedProperty(widget.property.id);
                              _isPropertySaved = false;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unsaved ${widget.property.title}')),
                              );
                            } else {
                              preferences.addSavedProperty(widget.property.id);
                              _isPropertySaved = true;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Saved ${widget.property.title}')),
                              );
                              // Simulate a notification for saving a property
                              Provider.of<MockNotificationService>(context, listen: false)
                                  .addNotification('Property Saved', 'You saved "${widget.property.title}".');
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Sent!'),
          content: Text(
              'Your request to contact the landlord for "${widget.property.title}" has been sent successfully. A landlord will contact you shortly.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    // Simulate a notification for contacting landlord
    Provider.of<MockNotificationService>(context, listen: false)
        .addNotification('Contact Sent', 'Your inquiry for "${widget.property.title}" has been sent.');
  }

  // NEW METHOD: Airbnb Booking/Inquiry Dialog
  void _showAirbnbBookingDialog(BuildContext context, Property property) {
    final userPreferences = Provider.of<UserPreferences>(context, listen: false);
    final String checkInDateStr = userPreferences.checkInDate != null
        ? DateFormat('MMM dd, yyyy').format(userPreferences.checkInDate!)
        : 'Not selected';
    final String checkOutDateStr = userPreferences.checkOutDate != null
        ? DateFormat('MMM dd, yyyy').format(userPreferences.checkOutDate!)
        : 'Not selected';
    final int guests = userPreferences.guests ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflicts
        return AlertDialog(
          title: const Text('Book Airbnb'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Property: ${property.title}'),
                const SizedBox(height: 10),
                Text('Location: ${property.location}'),
                const SizedBox(height: 10),
                Text('Price per night: ${_formatPrice(property.price, 'airbnb')}'),
                const Divider(),
                Text('Your Booking Details:', style: Theme.of(dialogContext).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Check-in: $checkInDateStr'),
                Text('Check-out: $checkOutDateStr'),
                Text('Guests: $guests'),
                const SizedBox(height: 20),
                Text(
                    'Note: This is a simulation. Actual booking involves payment and confirmation.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppStyles.darkGrey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Confirm Booking',
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking request for ${property.title} sent!')),
                );
                // Simulate a notification for booking
                Provider.of<MockNotificationService>(context, listen: false)
                    .addNotification('Booking Confirmed', 'Your booking for "${property.title}" is pending confirmation.');
              },
            ),
          ],
        );
      },
    );
  }
}