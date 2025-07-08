import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/widgets/custom_button.dart';
import 'package:housingapp/models/user_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late bool _isPropertySaved; // Manage saved state locally

  @override
  void initState() {
    super.initState();
    // Initialize saved state from UserPreferences
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
        amenity[0].toUpperCase() + amenity.substring(1), // Capitalize first letter
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
                widget.property.title,
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
                tag: 'propertyImage_${widget.property.id}', // Must match the tag in ListingCard
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
                              .where((entry) => entry.value) // Show only true amenities
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
                          // TODO: Implement booking or contact logic in Phase 4
                          if (widget.property.type == 'airbnb') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Simulating Booking... (Phase 4)')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Simulating Contact Landlord... (Phase 3)')),
                            );
                            // For "Contact Landlord", we'll just show a success message for now
                            // In a real app, this would involve sending an email/message to the landlord.
                            _showContactSuccessDialog(context);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Save Property',
                        color: Colors.blueGrey, // A different color for save
                        onPressed: () {
                          // TODO: Implement Save Property logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Saving ${widget.property.title}... (Phase 3)')),
                          );
                          _showSaveSuccessDialog(context);
                        },
                      ),
                      const SizedBox(height: 50), // Extra space at the bottom
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
              'Your request to contact the landlord for "${widget.property.title}" has been sent successfully.'),
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
  }

  void _showSaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Property Saved!'),
          content: Text(
              'You have saved "${widget.property.title}" to your list.'),
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
  }
}