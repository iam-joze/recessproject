import '../models/property.dart';
import 'kmeans_utils.dart';

class RecommendationService {
  final List<Property> properties;

  RecommendationService(this.properties);

  List<List<double>> _extractFeatures() {
    return properties.map((p) {
      return [
        p.price / 1000000, // normalize price
        _roomTypeToDouble(p.roomType),
        p.selfContained ? 1.0 : 0.0,
        p.fenced ? 1.0 : 0.0,
        p.furnished ? 1.0 : 0.0,
      ];
    }).toList();
  }

  double _roomTypeToDouble(String type) {
    switch (type.toLowerCase()) {
      case 'bedsitter':
        return 0.0;
      case '1 bedroom':
        return 1.0;
      case '2 bedroom':
        return 2.0;
      default:
        return -1.0;
    }
  }

  List<Property> recommend({
    required double budget,
    required String roomType,
    required bool selfContained,
    required bool fenced,
    required bool furnished,
    int kClusters = 3,
  }) {
    final data = _extractFeatures();
    final kmeans = KMeans(k: kClusters);
    final result = kmeans.fit(data);

    final input = [
      budget / 1000000,
      _roomTypeToDouble(roomType),
      selfContained ? 1.0 : 0.0,
      fenced ? 1.0 : 0.0,
      furnished ? 1.0 : 0.0,
    ];

    final clusterIndex = kmeans.predict(input, result.centroids);

    return [
      for (int i = 0; i < result.clusterLabels.length; i++)
        if (result.clusterLabels[i] == clusterIndex) properties[i]
    ];
  }
}
