import 'package:flutter/material.dart';
import '../models/property.dart';
import './property_card.dart';

class PropertyList extends StatelessWidget {
  final List<Property> properties;

  const PropertyList({super.key, required this.properties});

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const Center(
        child: Text('No properties match your criteria.'),
      );
    }

    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return PropertyCard(property: properties[index]);
      },
    );
  }
}
