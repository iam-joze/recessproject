// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:intl/intl.dart'; // For currency formatting

class ListingCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  String _formatPrice(double price, String type) {
    final formatter = NumberFormat.currency(
      locale: 'en_UG', // Uganda Shilling locale
      symbol: 'UGX ',
      decimalDigits: 0, // No decimals for UGX
    );
    String period = '';
    if (type == 'rental') {
      period = '/month';
    } else if (type == 'airbnb') {
      period = '/night';
    }
    return formatter.format(price) + period;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // Ensures image respects card border
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Hero( // Add Hero animation for smooth transition
              tag: 'propertyImage_${property.id}',
              child: Image.asset( // <--- CHANGED FROM Image.network to Image.asset!
                property.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppStyles.lightGrey,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: AppStyles.darkGrey, size: 50), // Changed icon for clarity
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppStyles.textColor,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: AppStyles.darkGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppStyles.darkGrey,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(property.price, property.type),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppStyles.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Basic features row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrapped Text in _buildFeatureChip in Expanded
                      Flexible( // Use Flexible to allow chips to shrink if space is tight
                        child: _buildFeatureChip(Icons.king_bed, '${property.bedrooms} Beds'),
                      ),
                      Flexible(
                        child: _buildFeatureChip(Icons.bathtub, '${property.bathrooms} Baths'),
                      ),
                      Flexible(
                        child: _buildFeatureChip(Icons.square_foot, '${property.areaSqFt} SqFt'),
                      ),
                    ],
                  ),
                  // Optional: Match Score / Distance
                  if (property.matchScore != null || property.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (property.matchScore != null)
                            Flexible( // Use Flexible to allow chips to shrink if space is tight
                              child: _buildInfoChip(
                                label: 'Match: ${property.matchScore!.toInt()}%',
                                color: AppStyles.accentColor,
                              ),
                            ),
                          if (property.distanceKm != null)
                            Flexible( // Use Flexible here too
                              child: _buildInfoChip(
                                label: '${property.distanceKm!.toStringAsFixed(1)} km away',
                                color: AppStyles.primaryColor.withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center content within Flexible
      children: [
        Icon(icon, size: 16, color: AppStyles.darkGrey),
        const SizedBox(width: 4),
        Expanded( // Ensures text within the chip expands and clips if needed
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppStyles.darkGrey),
            overflow: TextOverflow.ellipsis, // Add overflow handling
            maxLines: 1, // Ensure it only takes one line
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis, // Add overflow handling for chip label
        maxLines: 1,
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }
}