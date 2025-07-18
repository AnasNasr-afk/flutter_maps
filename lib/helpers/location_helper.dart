import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationHelper {
  static Future<Position> getCurrentLocation() async {
    try {
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        // Prompt the user to enable location services
        await Geolocator.openLocationSettings();
        // Recheck after user opens settings
        isServiceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!isServiceEnabled) {
          throw LocationServiceDisabledException();
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        throw LocationPermissionPermanentlyDeniedException();
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      return position;
    } catch (e) {
      if (e is LocationServiceDisabledException) {
        throw "Location services are disabled. Please enable them in your device settings.";
      } else if (e is LocationPermissionDeniedException) {
        throw "Location permission denied. Please allow location access.";
      } else if (e is LocationPermissionPermanentlyDeniedException) {
        throw "Location permission permanently denied. Please enable it in app settings.";
      } else if (e is TimeoutException) {
        throw "Location request timed out. Please try again.";
      } else {
        throw "Failed to get location: ${e.toString()}";
      }
    }
  }


  // Helper method to check if we have location permission
  static Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // Helper method to check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Method to open app settings for permissions
  static Future<void> openAppSettings() async {
    await openAppSettings(); // From permission_handler
  }

  // Method to open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

class LocationServiceDisabledException implements Exception {}

class LocationPermissionDeniedException implements Exception {}

class LocationPermissionPermanentlyDeniedException implements Exception {}
