import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/mapCubit/map_states.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import '../../data/models/place_suggestion_model.dart';
import '../../presentation/widgets/app_markers.dart';

class MapCubit extends Cubit<MapStates> {
  final MapsRepo mapsRepo;


  MapCubit(this.mapsRepo) : super(MapInitialState()){
    loadMarkersFromFirebase();
  }

  static MapCubit get(context) => BlocProvider.of(context);
  final Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  FloatingSearchBarController searchBarController = FloatingSearchBarController();

  void emitPlacesSuggestion(String places, String sessionToken) {
    mapsRepo.getSuggestions(places, sessionToken).then((placeSuggestions) {
      emit(MapPlacesLoadedState(placeSuggestionModel: placeSuggestions));
    }).catchError((error) {
      emit(MapErrorState());
      debugPrint('Error fetching place suggestions: $error');
    });
  }

  void emitPlaceDetails(String placesId, String sessionToken, PlaceSuggestionModel placeSuggestionModel) {
    mapsRepo.getLocationDetails(placesId, sessionToken).then((placeDetails) {
      emit(MapDetailsLoadedState(placeDetails, placeSuggestionModel)); // ✅ Pass both correctly
    }).catchError((error) {
      emit(MapDetailsErrorState());
      debugPrint('Error fetching place suggestions: $error');
    });
  }
  void selectPlace(String placeId, String description, String sessionToken) async {
    emit(MapPlaceSelectingState());

    try {
      final placeDetails = await mapsRepo.getLocationDetails(placeId, sessionToken);
      final latLng = LatLng(
        placeDetails.result.geometry.location.lat,
        placeDetails.result.geometry.location.lng,
      );

      emit(MapPlaceSelectedState(position: latLng, description: description));
    } catch (e) {
      emit(MapErrorState());
      debugPrint('Error selecting place: $e');
    }
  }





  void addMarker(Marker marker) {
    markers.add(marker);
    emit(MapMarkerState(markers: markers));
  }
  Future<void> loadMarkersFromFirebase() async {
    debugPrint('[MapCubit] 🔄 Fetching markers from Firebase...');

    try {
      final snapshot = await FirebaseFirestore.instance.collection('issues').get();
      final Set<Marker> fetchedMarkers = {};
      debugPrint('[MapCubit] 📦 Total documents fetched: ${snapshot.docs.length}');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        double? lat;
        double? lng;

        if (data.containsKey('lat') && data.containsKey('lng')) {
          lat = data['lat'];
          lng = data['lng'];
          debugPrint('[MapCubit] ✅ Found lat/lng in doc ${doc.id}: ($lat, $lng)');
        } else if (data.containsKey('location')) {
          try {
            final locationString = data['location'] as String;
            final parts = locationString.split(',');
            if (parts.length == 2) {
              lat = double.tryParse(parts[0].trim());
              lng = double.tryParse(parts[1].trim());
              debugPrint('[MapCubit] 🧠 Parsed from "location" in doc ${doc.id}: ($lat, $lng)');
            }
          } catch (e) {
            debugPrint('[MapCubit] ⚠️ Error parsing location in doc ${doc.id}: $e');
          }
        }

        if (lat == null || lng == null) {
          debugPrint('[MapCubit] ⛔ Skipping document ${doc.id} due to missing lat/lng');
          continue;
        }

        final position = LatLng(lat, lng);
        final type = data['category'] ?? 'Other';

        final marker = Marker(
          markerId: MarkerId(doc.id),
          position: position,
          infoWindow: InfoWindow(title: type),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            AppMarkers.getMarkerHue(type),
          ),
        );

        fetchedMarkers.add(marker);
        debugPrint('[MapCubit] 📍 Added marker for doc ${doc.id} at ($lat, $lng)');
      }

      debugPrint('[MapCubit] ✅ Total valid markers: ${fetchedMarkers.length}');
      emit(MapMarkerState(markers: fetchedMarkers));
    } catch (e) {
      debugPrint('[MapCubit] ❌ Failed to load markers: $e');
      emit(MapErrorState());
    }
  }





}
