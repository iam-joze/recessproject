import 'dart:math';

class KMeansResult {
  final List<List<double>> centroids;
  final List<int> clusterLabels;

  KMeansResult({required this.centroids, required this.clusterLabels});
}

class KMeans {
  final int k;
  final int maxIterations;

  KMeans({this.k = 3, this.maxIterations = 100});

  KMeansResult fit(List<List<double>> data) {
    final random = Random();
    final centroids = List.generate(k, (_) => [...data[random.nextInt(data.length)]]);
    final labels = List.filled(data.length, 0);

    for (var iter = 0; iter < maxIterations; iter++) {
      // Assign clusters
      for (int i = 0; i < data.length; i++) {
        double minDist = double.infinity;
        int cluster = 0;
        for (int j = 0; j < k; j++) {
          double dist = _euclideanDistance(data[i], centroids[j]);
          if (dist < minDist) {
            minDist = dist;
            cluster = j;
          }
        }
        labels[i] = cluster;
      }

      // Recalculate centroids
      final newCentroids = List.generate(k, (_) => List.filled(data[0].length, 0.0));
      final counts = List.filled(k, 0);

      for (int i = 0; i < data.length; i++) {
        final label = labels[i];
        for (int j = 0; j < data[i].length; j++) {
          newCentroids[label][j] += data[i][j];
        }
        counts[label]++;
      }

      for (int i = 0; i < k; i++) {
        if (counts[i] == 0) continue;
        for (int j = 0; j < newCentroids[i].length; j++) {
          newCentroids[i][j] /= counts[i];
        }
      }

      centroids.setAll(0, newCentroids);
    }

    return KMeansResult(centroids: centroids, clusterLabels: labels);
  }

  int predict(List<double> point, List<List<double>> centroids) {
    double minDist = double.infinity;
    int cluster = 0;
    for (int i = 0; i < centroids.length; i++) {
      final dist = _euclideanDistance(point, centroids[i]);
      if (dist < minDist) {
        minDist = dist;
        cluster = i;
      }
    }
    return cluster;
  }

  double _euclideanDistance(List<double> a, List<double> b) {
    return sqrt(a.asMap().entries.fold(0.0, (sum, e) {
      final i = e.key;
      return sum + pow(a[i] - b[i], 2);
    }));
  }
}
