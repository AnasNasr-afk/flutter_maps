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

  static Marker buildIssueMarker({
  required double latitude,
  required double longitude,
  required String category,
  required String description,
  required String status,
  VoidCallback? onTap,
  bool showInfoWindow = true,
  }) {
  final color = getStatusColor(status);

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

  static double _toHue(Color color) {
  if (color == Colors.green.shade600) return BitmapDescriptor.hueGreen;
  if (color == Colors.blue.shade600) return BitmapDescriptor.hueBlue;
  if (color == Colors.orange.shade600) return BitmapDescriptor.hueOrange;
  if (color == Colors.redAccent.shade400) return BitmapDescriptor.hueRed;
  return BitmapDescriptor.hueAzure;
  }




}
