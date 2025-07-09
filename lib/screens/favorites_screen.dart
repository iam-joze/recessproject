import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/favorites_service.dart';
import '../data/mock_properties.dart';
import '../widgets/property_list.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  List<Property> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _favoritesService.getFavorites();
    final results = mockProperties.where((p) => ids.contains(p.id)).toList();
    setState(() => _favorites = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _favorites.isEmpty
          ? const Center(child: Text('No favorites yet.'))
          : PropertyList(properties: _favorites),
    );
  }
}
