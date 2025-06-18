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
  final Set<Marker> _issueMarkers = {}; // From Firebase
  final Set<Marker> _searchMarkers = {}; // From search bar  FloatingSearchBarController searchBarController = FloatingSearchBarController();
  Set<Marker> get allMarkers => {..._issueMarkers, ..._searchMarkers};
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



  void addSearchMarker(Marker marker) {
    _searchMarkers
      ..clear()
      ..add(marker);
    emit(MapMarkerState(markers: allMarkers));
  }
  void clearSearchMarkers() {
    _searchMarkers.clear();
    emit(MapMarkerState(markers: allMarkers));
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
        } else if (data.containsKey('location')) {
          try {
            final parts = (data['location'] as String).split(',');
            if (parts.length == 2) {
              lat = double.tryParse(parts[0].trim());
              lng = double.tryParse(parts[1].trim());
            }
          } catch (e) {
            debugPrint('[MapCubit] ⚠️ Failed to parse location in ${doc.id}');
          }
        }

        if (lat == null || lng == null) {
          debugPrint('[MapCubit] ⛔ Skipping invalid doc ${doc.id}');
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
      }

      _issueMarkers
        ..clear()
        ..addAll(fetchedMarkers);

      emit(MapMarkerState(markers: allMarkers));
      debugPrint('[MapCubit] ✅ Loaded ${_issueMarkers.length} issue markers.');
    } catch (e) {
      debugPrint('[MapCubit] ❌ Failed to load markers: $e');
      emit(MapErrorState());
    }
  }





}
