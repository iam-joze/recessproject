import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/mock_properties.dart';
//import '../models/property.dart';
import '../services/search_parser.dart';
import '../services/distance_helper.dart';
import '../services/recommendation_service.dart';
import '../widgets/filter_modal.dart';
import '../widgets/property_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  double _maxBudget = 1000000;
  String _selectedRoomType = 'Any';
  bool _filterSelfContained = false;
  bool _filterFurnished = false;
  bool _filterFenced = false;

  bool _filterNearby = false;
  double? _userLat;
  double? _userLon;
  final double _radiusKm = 5.0;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLat = position.latitude;
      _userLon = position.longitude;
    });
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FilterModal(
          maxBudget: _maxBudget,
          selectedRoomType: _selectedRoomType,
          selfContained: _filterSelfContained,
          furnished: _filterFurnished,
          fenced: _filterFenced,
          onApply: ({
            double? maxBudget,
            String? roomType,
            bool? selfContained,
            bool? furnished,
            bool? fenced,
          }) {
            setState(() {
              if (maxBudget != null) _maxBudget = maxBudget;
              if (roomType != null) _selectedRoomType = roomType;
              if (selfContained != null) _filterSelfContained = selfContained;
              if (furnished != null) _filterFurnished = furnished;
              if (fenced != null) _filterFenced = fenced;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.toLowerCase();

    final filteredProperties = mockProperties.where((property) {
      final withinBudget = property.price <= _maxBudget;
      final roomMatch = _selectedRoomType == 'Any' ||
          property.roomType.toLowerCase() == _selectedRoomType.toLowerCase();
      final selfContainedMatch = !_filterSelfContained || property.selfContained;
      final fencedMatch = !_filterFenced || property.fenced;
      final furnishedMatch = !_filterFurnished || property.furnished;
      final locationMatch =
          searchText.isEmpty || property.location.toLowerCase().contains(searchText);

      final nearbyMatch = !_filterNearby ||
          (_userLat != null &&
              _userLon != null &&
              calculateDistanceKm(
                    _userLat!,
                    _userLon!,
                    property.latitude,
                    property.longitude,
                  ) <=
                  _radiusKm);

      return withinBudget &&
          roomMatch &&
          selfContainedMatch &&
          fencedMatch &&
          furnishedMatch &&
          locationMatch &&
          nearbyMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yo Broker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterModal,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a rental...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                final parsed = parseSearchQuery(value);

                setState(() {
                  _selectedRoomType = parsed['roomType'];
                  _maxBudget = parsed['budget'] ?? 2000000;
                  _filterSelfContained = parsed['selfContained'];
                  _filterFurnished = parsed['furnished'];
                  _filterFenced = parsed['fenced'];
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show nearby only'),
                Switch(
                  value: _filterNearby,
                  onChanged: (value) {
                    setState(() {
                      _filterNearby = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular Rentals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PropertyList(properties: filteredProperties),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                final recommender = RecommendationService(mockProperties);
                final recs = recommender.recommend(
                  budget: _maxBudget,
                  roomType: _selectedRoomType,
                  selfContained: _filterSelfContained,
                  fenced: _filterFenced,
                  furnished: _filterFurnished,
                );

                showModalBottomSheet(
                  context: context,
                  builder: (_) => SizedBox(
                    height: 400,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Recommended for You',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(child: PropertyList(properties: recs)),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Get Recommendations'),
            ),
          ),
        ],
      ),
    );
  }
}
