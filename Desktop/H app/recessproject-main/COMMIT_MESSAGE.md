feat: Add interactive map view for property discovery

This commit adds a comprehensive interactive map feature to the housing app,
significantly enhancing the user experience for property discovery.

## New Features:
- **Map View Toggle**: Users can switch between list and map views
- **Interactive Property Map**: Visual representation of properties with custom markers
- **Property Information Display**: Horizontal scrollable property cards at bottom
- **Map Controls**: User location and radius filtering with adjustable slider
- **Match Score Visualization**: Color-coded markers (green for high match >70%)

## Technical Implementation:
- Created `SimpleMapView` widget with custom painters for map rendering
- Added `MapPainter` for background grid and radius circles
- Added `PropertyMarkersPainter` for interactive property markers
- Integrated map toggle in `DiscoverListingsScreen`
- Added map-related dependencies to `pubspec.yaml`

## User Experience Improvements:
- Spatial awareness of property locations
- Quick visual comparison of nearby properties
- Intuitive property exploration through map interface
- Enhanced filtering with visual radius indicators
- Seamless navigation between list and map views

## Files Added:
- `lib/widgets/simple_map_view.dart` - Main map view implementation
- `MAP_FEATURE_README.md` - Feature documentation

## Files Modified:
- `lib/screens/discover_listings_screen.dart` - Added map toggle and integration
- `pubspec.yaml` - Added map dependencies

This feature addresses the need for visual property discovery, making the
housing search process more intuitive and efficient for users. 