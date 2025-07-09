class Property {
  final String id;
  final String title;
  final String location;
  final double price;
  final String roomType;
  final bool selfContained;
  final bool fenced;
  final bool furnished;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.roomType,
    required this.selfContained,
    required this.fenced,
    required this.furnished,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
}
