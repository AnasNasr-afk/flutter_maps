import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AppMarkers {
  static Marker buildCurrentLocationMarker(Position position) {
    return Marker(
      position: LatLng(position.latitude, position.longitude),
      markerId: const MarkerId('currentLocation'),
      infoWindow: const InfoWindow(title: 'You are here'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );
  }

  static Marker buildSearchedPlaceMarker({
    required MarkerId markerId,
    required LatLng latLng,
    required InfoWindow infoWindow,

  }) {
    return Marker(
      markerId: markerId,
      position: latLng,
      infoWindow: infoWindow,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  static double getMarkerHue(String category) {
    switch (category.toLowerCase()) {
      case 'trash':
      // 🟢 Green: environment-related, cleanup needed.
        return BitmapDescriptor.hueGreen;

      case 'broken street area':
      // 🟠 Orange: caution/damage – roadwork or danger.
        return BitmapDescriptor.hueOrange;

      case 'water leak':
      // 🔵 Blue: water-related, visually matches the concept.
        return BitmapDescriptor.hueBlue;

      case 'parking issue':
      // 🟣 Violet: problem but not urgent, still needs regulation.
        return BitmapDescriptor.hueViolet;

      case 'light outage':
      // ⚪ White (light grayish tone): indicates lighting or power.
        return BitmapDescriptor.hueMagenta;

      case 'noise complaint':
      // 🟡 Yellow: alert without danger.
        return BitmapDescriptor.hueYellow;

      case 'other':
      default:
      // 🔘 Cyan: fallback, neutral but noticeable.
        return BitmapDescriptor.hueCyan;
    }
  }


  static Marker buildIssueMarker({
    required double latitude,
    required double longitude,
    required String category,
    required String description,
  }) {
    final markerHue = getMarkerHue(category);

    return Marker(
      position: LatLng(latitude, longitude),
      markerId: MarkerId('issue_${DateTime.now().millisecondsSinceEpoch}'),
      infoWindow: InfoWindow(
        title: category,
        snippet: description,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
    );
  }


}
