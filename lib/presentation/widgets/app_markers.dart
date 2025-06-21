import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../helpers/components.dart';


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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
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


  // static Marker buildIssueMarker({
  //   required IssueModel issue,
  //   required VoidCallback onTap,
  // }) {
  //   final markerHue = getMarkerHue(issue.category);
  //
  //   return Marker(
  //     onTap: onTap,
  //     position: _parseLatLng(issue.location),
  //     markerId: MarkerId('issue_${issue.uId}_${DateTime.now().millisecondsSinceEpoch}'),
  //     infoWindow: InfoWindow(
  //       title: issue.category,
  //       snippet: issue.description,
  //     ),
  //     icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
  //   );
  // }
  // static LatLng _parseLatLng(String location) {
  //   final parts = location.split(',');
  //   return LatLng(double.parse(parts[0]), double.parse(parts[1]));
  // }




  static Marker buildIssueMarker({
  required double latitude,
  required double longitude,
  required String category,
  required String description,
  required String status, // ✅ Required for color
  VoidCallback? onTap,
  bool showInfoWindow = true,
  }) {
  final color = getStatusColor(status); // ✅ Get consistent status color

  return Marker(
  onTap: onTap,
  position: LatLng(latitude, longitude),
  markerId: MarkerId('issue_${DateTime.now().millisecondsSinceEpoch}'),
  infoWindow: showInfoWindow
  ? InfoWindow(title: category, snippet: description)
      : InfoWindow.noText,
  icon: BitmapDescriptor.defaultMarkerWithHue(_toHue(color)),
  );
  }

  // ✅ Converts Color to Google Maps marker hue
  static double _toHue(Color color) {
  // Map basic color identity to hues (limited by Google Maps API constraints)
  if (color == Colors.green.shade600) return BitmapDescriptor.hueGreen;
  if (color == Colors.blue.shade600) return BitmapDescriptor.hueBlue;
  if (color == Colors.orange.shade600) return BitmapDescriptor.hueOrange;
  if (color == Colors.redAccent.shade400) return BitmapDescriptor.hueRed;
  return BitmapDescriptor.hueAzure; // fallback hue
  }




}
