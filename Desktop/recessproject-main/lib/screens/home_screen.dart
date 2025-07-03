import 'package:flutter/material.dart';

// (Temporary) We'll define a simple data model for a House Listing here for now.
// In a real app, this would come from a backend or more complex data source.
class HouseListing {
  final String id;
  final String imageUrl;
  final String location;
  final double rentPrice;
  final String landlordName;
  final double landlordRating;
  final String availabilityStatus;
  final int? bedrooms;
  final int? bathrooms;

  HouseListing({
    required this.id,
    required this.imageUrl,
    required this.location,
    required this.rentPrice,
    required this.landlordName,
    required this.landlordRating,
    required this.availabilityStatus,
    this.bedrooms,
    this.bathrooms,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // For Bottom Navigation Bar
  final TextEditingController _searchController = TextEditingController();

  // Placeholder list of house listings
  final List<HouseListing> _houseListings = [
    HouseListing(
      id: 'h1',
      imageUrl:
          'https://via.placeholder.com/400x250/FF5733/FFFFFF?text=House+1', // Placeholder image
      location: 'Kololo, Kampala',
      rentPrice: 450000.0,
      landlordName: 'Mr. Kato',
      landlordRating: 4.2,
      availabilityStatus: 'Vacant',
      bedrooms: 2,
      bathrooms: 2,
    ),
    HouseListing(
      id: 'h2',
      imageUrl:
          'https://via.placeholder.com/400x250/33A0FF/FFFFFF?text=House+2',
      location: 'Naguru, Kampala',
      rentPrice: 800000.0,
      landlordName: 'Ms. Nakato',
      landlordRating: 4.5,
      availabilityStatus: 'Available Soon',
      bedrooms: 3,
      bathrooms: 2,
    ),
    HouseListing(
      id: 'h3',
      imageUrl:
          'https://via.placeholder.com/400x250/33FF57/FFFFFF?text=House+3',
      location: 'Entebbe',
      rentPrice: 300000.0,
      landlordName: 'Mr. Opio',
      landlordRating: 3.9,
      availabilityStatus: 'Vacant',
      bedrooms: 1,
      bathrooms: 1,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Implement navigation to Favorites/Profile screens
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Hamburger Menu icon
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Open Navigation Drawer
            print('Hamburger menu tapped');
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for homes...',
            border: InputBorder.none, // No border for clean look in app bar
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (value) {
            // TODO: Implement search logic
            print('Search submitted: $value');
          },
        ),
        actions: [
          // Filter/Sort icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open Filter/Sort options
              print('Filter/Sort tapped');
            },
          ),
        ],
        toolbarHeight: 80, // Increase app bar height to accommodate search bar
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _houseListings.length,
        itemBuilder: (context, index) {
          final house = _houseListings[index];
          return HouseCard(house: house); // Reusable HouseCard widget
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- Reusable HouseCard Widget ---
class HouseCard extends StatelessWidget {
  final HouseListing house;

  const HouseCard({super.key, required this.house});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              house.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
                  house.location,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'UGX ${house.rentPrice.toInt()}/month',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                if (house.bedrooms != null && house.bathrooms != null)
                  Text(
                    '${house.bedrooms} Beds • ${house.bathrooms} Baths',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${house.landlordName} ★ ${house.landlordRating}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Spacer(), // Pushes availability to the right
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: house.availabilityStatus == 'Vacant'
                            ? Colors.green[100]
                            : Colors.orange[100],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        house.availabilityStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: house.availabilityStatus == 'Vacant'
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to House Details Screen
                      print(
                        'View Details for ${house.location} (ID: ${house.id})',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
