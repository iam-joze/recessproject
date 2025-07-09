import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/favorites_service.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final result = await _favoritesService.isFavorite(widget.property.id);
    setState(() {
      _isFavorite = result;
    });
  }

  void _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.property.id);
    final result = await _favoritesService.isFavorite(widget.property.id);
    setState(() {
      _isFavorite = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(p.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: _toggleFavorite,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${p.roomType} • ${p.location}'),
                Text('UGX ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
