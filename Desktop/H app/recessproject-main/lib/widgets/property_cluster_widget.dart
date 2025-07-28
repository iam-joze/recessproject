import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:housingapp/models/property.dart';
import 'package:housingapp/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class PropertyClusterWidget extends StatelessWidget {
  final List<Property> properties;
  final Function(Property) onPropertyTap;
  final double clusterRadius = 0.01; // Approximately 1km

  const PropertyClusterWidget({
    super.key,
    required this.properties,
    required this.onPropertyTap,
  });

  List<PropertyCluster> _createClusters() {
    List<PropertyCluster> clusters = [];
    List<Property> unclusteredProperties = List.from(properties);

    while (unclusteredProperties.isNotEmpty) {
      Property centerProperty = unclusteredProperties.removeAt(0);
      List<Property> clusterProperties = [centerProperty];

      // Find properties within cluster radius
      unclusteredProperties.removeWhere((property) {
        double distance = _calculateDistance(
          centerProperty.latitude,
          centerProperty.longitude,
          property.latitude,
          property.longitude,
        );
        if (distance <= clusterRadius) {
          clusterProperties.add(property);
          return true;
        }
        return false;
      });

      // Calculate cluster center
      double avgLat =
          clusterProperties.map((p) => p.latitude).reduce((a, b) => a + b) /
              clusterProperties.length;
      double avgLng =
          clusterProperties.map((p) => p.longitude).reduce((a, b) => a + b) /
              clusterProperties.length;

      clusters.add(PropertyCluster(
        center: LatLng(avgLat, avgLng),
        properties: clusterProperties,
      ));
    }

    return clusters;
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
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
    List<PropertyCluster> clusters = _createClusters();

    return FlutterMap(
      options: MapOptions(
        initialCenter:
            clusters.isNotEmpty ? clusters.first.center : const LatLng(0, 0),
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.housingapp',
        ),
        MarkerLayer(
          markers: clusters.map((cluster) {
            return Marker(
              point: cluster.center,
              width: cluster.properties.length == 1 ? 60 : 80,
              height: cluster.properties.length == 1 ? 60 : 80,
              child: GestureDetector(
                onTap: () {
                  if (cluster.properties.length == 1) {
                    onPropertyTap(cluster.properties.first);
                  } else {
                    _showClusterDetails(context, cluster);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: cluster.properties.length == 1
                        ? Colors.white
                        : AppStyles.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cluster.properties.length == 1
                          ? (cluster.properties.first.matchScore != null &&
                                  cluster.properties.first.matchScore! > 70
                              ? Colors.green
                              : AppStyles.primaryColor)
                          : Colors.white,
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
                  child: cluster.properties.length == 1
                      ? _buildSinglePropertyMarker(cluster.properties.first)
                      : _buildClusterMarker(cluster),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSinglePropertyMarker(Property property) {
    return Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
    );
  }

  Widget _buildClusterMarker(PropertyCluster cluster) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${cluster.properties.length}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'Properties',
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showClusterDetails(BuildContext context, PropertyCluster cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${cluster.properties.length} Properties in this area',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: cluster.properties.length,
                  itemBuilder: (context, index) {
                    final property = cluster.properties[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            property.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 60,
                              height: 60,
                              color: AppStyles.lightGrey,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        title: Text(
                          property.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(property.location),
                            Text(
                              _formatPrice(property.price, property.type),
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: property.matchScore != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: property.matchScore! > 70
                                      ? Colors.green
                                      : AppStyles.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${property.matchScore!.toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onPropertyTap(property);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PropertyCluster {
  final LatLng center;
  final List<Property> properties;

  PropertyCluster({
    required this.center,
    required this.properties,
  });
}
