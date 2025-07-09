/// Parses natural language search queries for filtering rentals
Map<String, dynamic> parseSearchQuery(String query) {
  final lowerQuery = query.toLowerCase();

  // Room Type
  final roomTypes = ['bedsitter', '1 bedroom', '2 bedroom'];
  final roomType = roomTypes.firstWhere(
    (type) => lowerQuery.contains(type),
    orElse: () => 'Any',
  );

  // Budget Extraction
  final budgetRegex = RegExp(r'(?:under|below)\s*(\d+[kK]?)');
  final budgetMatch = budgetRegex.firstMatch(lowerQuery);
  double? budget;
  if (budgetMatch != null) {
    final match = budgetMatch.group(1)!.toLowerCase().replaceAll('k', '000');
    budget = double.tryParse(match);
  }

  // Amenity Flags
  final isSelfContained = lowerQuery.contains('self-contained') || lowerQuery.contains('self contained');
  final isFurnished = lowerQuery.contains('furnished');
  final isFenced = lowerQuery.contains('fenced');

  // Location Extraction (basic)
  final locations = ['kisaasi', 'ntinda', 'bukoto'];
  final location = locations.firstWhere(
    (loc) => lowerQuery.contains(loc),
    orElse: () => '',
  );

  return {
    'roomType': roomType,
    'budget': budget,
    'selfContained': isSelfContained,
    'furnished': isFurnished,
    'fenced': isFenced,
    'location': location,
  };
}
