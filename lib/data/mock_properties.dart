import 'package:yo_broker/models/property.dart';

final List<Property> mockProperties = [
  Property(
    id: '1',
    title: 'Modern Self-Contained Bedsitter',
    location: 'Kisaasi',
    price: 450000,
    roomType: 'Bedsitter',
    selfContained: true,
    fenced: true,
    furnished: false,
    imageUrl: 'https://picsum.photos/200/300?random=1',
    latitude: 0.3600,
    longitude: 32.6500,
  ),
  Property(
    id: '2',
    title: '1 Bedroom Apartment in Ntinda',
    location: 'Ntinda',
    price: 600000,
    roomType: '1 Bedroom',
    selfContained: true,
    fenced: true,
    furnished: true,
    imageUrl: 'https://picsum.photos/200/300?random=2',
    latitude: 0.4200,
    longitude: 64.6500,
  ),
];
