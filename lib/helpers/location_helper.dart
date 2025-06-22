  import 'package:geolocator/geolocator.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';

  class LocationHelper {
    static Future<Position> getCurrentLocation() async {
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return Future.error("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error("Location permissions are denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location permissions are permanently denied. Please enable them in settings.");
      }

      return await Geolocator.getCurrentPosition();
    }
    // TODO: Utility to parse location string to LatLng
    static LatLng? extractLatLngFromString(String? location) {
      if (location == null) return null;
      final parts = location.split(',');
      if (parts.length != 2) return null;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    }

  }
