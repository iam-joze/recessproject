import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tenant Home',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TenantHomeScreen(),
    );
  }
}

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const SavedPropertiesTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemSelected(String title) {
    Navigator.pop(context); // close drawer
    if (title == 'Logout') {
      // TODO: Implement logout logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
      // Navigate to login or splash screen as needed
    } else {
      // Just show placeholder message for now
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title tapped')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(onItemSelected: _onDrawerItemSelected),
      appBar: AppBar(
        title: const Text('Find Your Next Home'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PropertySearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter pressed')),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final void Function(String) onItemSelected;

  const NavigationDrawer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final drawerItems = [
      _DrawerItem(icon: Icons.home, title: 'Home'),
      _DrawerItem(icon: Icons.favorite, title: 'Saved Properties'),
      _DrawerItem(icon: Icons.person, title: 'Profile'),
      _DrawerItem(icon: Icons.settings, title: 'Settings'),
      _DrawerItem(icon: Icons.logout, title: 'Logout'),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Tenant Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ...drawerItems.map((item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () => onItemSelected(item.title),
              )),
        ],
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String title;

  _DrawerItem({required this.icon, required this.title});
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> properties = [
      {
        'imageUrl': 'https://via.placeholder.com/150',
        'location': 'Kampala, Uganda',
        'price': 'UGX 500,000/month',
        'landlord': 'Mr. John Doe',
        'available': true,
      },
      {
        'imageUrl': 'https://via.placeholder.com/150',
        'location': 'Entebbe, Uganda',
        'price': 'UGX 400,000/month',
        'landlord': 'Ms. Jane Smith',
        'available': false,
      },
    ];

    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final prop = properties[index];
        return HouseCard(
          imageUrl: prop['imageUrl'],
          location: prop['location'],
          price: prop['price'],
          landlord: prop['landlord'],
          available: prop['available'],
        );
      },
    );
  }
}

class SavedPropertiesTab extends StatelessWidget {
  const SavedPropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No saved properties yet.'));
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}

class HouseCard extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String price;
  final String landlord;
  final bool available;

  const HouseCard({
    super.key,
    required this.imageUrl,
    required this.location,
    required this.price,
    required this.landlord,
    required this.available,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(price, style: const TextStyle(color: Colors.green, fontSize: 14)),
                const SizedBox(height: 5),
                Text('Landlord: $landlord', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 5),
                Text(
                  available ? 'Available' : 'Not Available',
                  style: TextStyle(
                    fontSize: 13,
                    color: available ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
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

class PropertySearchDelegate extends SearchDelegate<String> {
  final List<String> sampleLocations = [
    'Kampala',
    'Entebbe',
    'Jinja',
    'Mukono',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    final results = sampleLocations
        .where((loc) => loc.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results
          .map((loc) => ListTile(
                title: Text(loc),
                onTap: () {
                  close(context, loc);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searched for: $loc')),
                  );
                },
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = sampleLocations
        .where((loc) => loc.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions
          .map((loc) => ListTile(
                title: Text(loc),
                onTap: () {
                  query = loc;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }
}
