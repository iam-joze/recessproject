import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:housingapp/screens/property_detail_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PropertyMapView extends StatefulWidget {
  final List<Property> properties;
  final Function(Property) onPropertyTap;
  final double? userLatitude;
  final double? userLongitude;

  const PropertyMapView({
    super.key,
    required this.properties,
    required this.onPropertyTap,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _showUserLocation = false;
  double _radiusKm = 5.0;
  bool _showRadius = false;

  @override
  void initState() {
    super.initState();
    _initializeUserLocation();
  }

  Future<void> _initializeUserLocation() async {
    if (widget.userLatitude != null && widget.userLongitude != null) {
      setState(() {
        _userLocation = LatLng(widget.userLatitude!, widget.userLongitude!);
      });
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      var permission = await Permission.location.request();
      if (permission.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  List<LatLng> _getRadiusCirclePoints(LatLng center, double radiusKm) {
    List<LatLng> points = [];
    for (int i = 0; i < 360; i += 5) {
      double angle = i * pi / 180;
      double lat = center.latitude + (radiusKm / 111.32) * cos(angle);
      double lng = center.longitude +
          (radiusKm / (111.32 * cos(center.latitude * pi / 180))) * sin(angle);
      points.add(LatLng(lat, lng));
    }
    return points;
  }

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

    // Calculate map bounds
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var property in widget.properties) {
      minLat = min(minLat, property.latitude);
      maxLat = max(maxLat, property.latitude);
      minLng = min(minLng, property.longitude);
      maxLng = max(maxLng, property.longitude);
    }

    // Add user location to bounds if available
    if (_userLocation != null) {
      minLat = min(minLat, _userLocation!.latitude);
      maxLat = max(maxLat, _userLocation!.latitude);
      minLng = min(minLng, _userLocation!.longitude);
      maxLng = max(maxLng, _userLocation!.longitude);
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _userLocation ??
                LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
            initialZoom: 12,
            onTap: (_, __) => setState(() => _showRadius = false),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.housingapp',
            ),
            // User location marker
            if (_userLocation != null && _showUserLocation)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.my_location,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            // Radius circle
            if (_showRadius && _userLocation != null)
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _getRadiusCirclePoints(_userLocation!, _radiusKm),
                    color: AppStyles.primaryColor.withOpacity(0.2),
                    borderColor: AppStyles.primaryColor,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            // Property markers
            MarkerLayer(
              markers: widget.properties.map((property) {
                return Marker(
                  point: LatLng(property.latitude, property.longitude),
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => widget.onPropertyTap(property),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: property.matchScore != null &&
                                  property.matchScore! > 70
                              ? Colors.green
                              : AppStyles.primaryColor,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatPrice(property.price, property.type),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppStyles.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (property.matchScore != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: property.matchScore! > 70
                                    ? Colors.green
                                    : AppStyles.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${property.matchScore!.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 6,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
                    if (_showUserLocation && _userLocation != null) {
                      _mapController.move(_userLocation!, 15);
                    }
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
      ],
    );
  }
}
