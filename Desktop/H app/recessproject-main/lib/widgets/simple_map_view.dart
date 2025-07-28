import 'package:flutter/material.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SimpleMapView extends StatefulWidget {
  final List<Property> properties;
  final Function(Property) onPropertyTap;
  final double? userLatitude;
  final double? userLongitude;

  const SimpleMapView({
    super.key,
    required this.properties,
    required this.onPropertyTap,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<SimpleMapView> createState() => _SimpleMapViewState();
}

class _SimpleMapViewState extends State<SimpleMapView> {
  bool _showUserLocation = false;
  double _radiusKm = 5.0;
  bool _showRadius = false;

  String _formatPrice(double price, String type) {
    final formatter = NumberFormat.currency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    String period = type == 'rental'
        ? '/month'
        : type == 'airbnb'
            ? '/night'
            : '';
    return formatter.format(price) + period;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.properties.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: AppStyles.primaryColor),
            SizedBox(height: 20),
            Text(
              'No properties to display on map',
              style: TextStyle(fontSize: 18, color: AppStyles.textColor),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Map-like background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.green.shade50,
              ],
            ),
          ),
          child: CustomPaint(
            painter: MapPainter(
              properties: widget.properties,
              showUserLocation: _showUserLocation,
              showRadius: _showRadius,
              radiusKm: _radiusKm,
              userLatitude: widget.userLatitude,
              userLongitude: widget.userLongitude,
            ),
            child: Container(),
          ),
        ),
        // Property markers overlay
        Positioned.fill(
          child: CustomPaint(
            painter: PropertyMarkersPainter(
              properties: widget.properties,
              onPropertyTap: widget.onPropertyTap,
              formatPrice: _formatPrice,
            ),
            child: GestureDetector(
              onTapUp: (details) {
                // Handle tap to select property
                _handleMapTap(details.localPosition);
              },
            ),
          ),
        ),
        // Control buttons
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _showUserLocation = !_showUserLocation;
                  });
                },
                backgroundColor:
                    _showUserLocation ? AppStyles.primaryColor : Colors.white,
                child: Icon(
                  Icons.my_location,
                  color:
                      _showUserLocation ? Colors.white : AppStyles.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _showRadius = !_showRadius;
                  });
                },
                backgroundColor:
                    _showRadius ? AppStyles.accentColor : Colors.white,
                child: Icon(
                  Icons.radio_button_checked,
                  color: _showRadius ? Colors.white : AppStyles.accentColor,
                ),
              ),
            ],
          ),
        ),
        // Radius slider
        if (_showRadius)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Radius: ${_radiusKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.textColor,
                    ),
                  ),
                  Slider(
                    value: _radiusKm,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: AppStyles.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _radiusKm = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        // Property list overlay
        Positioned(
          bottom: _showRadius ? 100 : 16,
          left: 16,
          right: 16,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: widget.properties.length,
              itemBuilder: (context, index) {
                final property = widget.properties[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          property.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 50,
                            height: 50,
                            color: AppStyles.lightGrey,
                            child:
                                const Icon(Icons.image_not_supported, size: 20),
                          ),
                        ),
                      ),
                      title: Text(
                        property.title,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.location,
                            style: const TextStyle(fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatPrice(property.price, property.type),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppStyles.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: property.matchScore != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: property.matchScore! > 70
                                    ? Colors.green
                                    : AppStyles.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${property.matchScore!.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () => widget.onPropertyTap(property),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleMapTap(Offset position) {
    // Simple tap handling - could be enhanced with actual coordinate mapping
    if (widget.properties.isNotEmpty) {
      // For now, just tap the first property as a demo
      widget.onPropertyTap(widget.properties.first);
    }
  }
}

class MapPainter extends CustomPainter {
  final List<Property> properties;
  final bool showUserLocation;
  final bool showRadius;
  final double radiusKm;
  final double? userLatitude;
  final double? userLongitude;

  MapPainter({
    required this.properties,
    required this.showUserLocation,
    required this.showRadius,
    required this.radiusKm,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw a simple grid pattern to simulate a map
    for (int i = 0; i < size.width; i += 20) {
      for (int j = 0; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, paint);
      }
    }

    // Draw radius circle if enabled
    if (showRadius && userLatitude != null && userLongitude != null) {
      final radiusPaint = Paint()
        ..color = AppStyles.primaryColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      final center = Offset(size.width / 2, size.height / 2);
      final radius = (radiusKm * 10).clamp(20.0, 100.0);
      canvas.drawCircle(center, radius, radiusPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PropertyMarkersPainter extends CustomPainter {
  final List<Property> properties;
  final Function(Property) onPropertyTap;
  final String Function(double, String) formatPrice;

  PropertyMarkersPainter({
    required this.properties,
    required this.onPropertyTap,
    required this.formatPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw property markers as circles
    for (int i = 0; i < properties.length; i++) {
      final property = properties[i];
      final x = (size.width * (i + 1)) / (properties.length + 1);
      final y = size.height * 0.3 + (i % 2) * 50;

      final paint = Paint()
        ..color = property.matchScore != null && property.matchScore! > 70
            ? Colors.green
            : AppStyles.primaryColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 15, paint);

      // Draw price text
      final textPainter = TextPainter(
        text: TextSpan(
          text: formatPrice(property.price, property.type),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
