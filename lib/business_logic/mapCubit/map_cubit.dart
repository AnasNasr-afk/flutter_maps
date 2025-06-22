import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_maps/business_logic/mapCubit/map_states.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

import '../../data/models/place_suggestion_model.dart';
import '../../helpers/admin_services.dart';
import '../../helpers/location_helper.dart';
import '../../presentation/widgets/admin_issue_bottom_sheet.dart';
import '../../presentation/widgets/app_markers.dart';
import '../issueCubit/issue_cubit.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapCubit extends Cubit<MapStates> {
  final MapsRepo mapsRepo;

  MapCubit(this.mapsRepo) : super(MapInitialState()) {
    debugPrint('[MapCubit] 🔄 Constructor called, initializing...');
    loadMarkersFromFirebase();
    checkAdmin();
  }

  static MapCubit get(context) => BlocProvider.of(context);
  final Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> _issueMarkers = {};
  final Set<Marker> _searchMarkers = {};

  Set<Marker> get allMarkers => {..._issueMarkers, ..._searchMarkers};
  FloatingSearchBarController searchBarController =
      FloatingSearchBarController();
  bool isAdmin = false;

  void emitPlacesSuggestion(String places, String sessionToken) {
    debugPrint('[MapCubit] 🔍 emitPlacesSuggestion() with query: $places');
    mapsRepo.getSuggestions(places, sessionToken).then((placeSuggestions) {
      emit(MapPlacesLoadedState(placeSuggestionModel: placeSuggestions));
    }).catchError((error) {
      emit(MapErrorState());
      debugPrint('Error fetching place suggestions: $error');
    });
  }

  void emitPlaceDetails(String placesId, String sessionToken,
      PlaceSuggestionModel placeSuggestionModel) {
    debugPrint('🔍 Fetching details for place ID: $placesId');
    mapsRepo.getLocationDetails(placesId, sessionToken).then((placeDetails) {
      emit(MapDetailsLoadedState(
          placeDetails, placeSuggestionModel)); // ✅ Pass both correctly
    }).catchError((error) {
      emit(MapDetailsErrorState());
      debugPrint('Error fetching place suggestions: $error');
    });
  }

  void selectPlace(
      String placeId, String description, String sessionToken) async {
    debugPrint('[MapCubit] 📌 selectPlace() for $description');
    debugPrint('🔍 Selecting place: $placeId, Description: $description');
    emit(MapPlaceSelectingState());

    try {
      final placeDetails =
          await mapsRepo.getLocationDetails(placeId, sessionToken);
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

  void setMarkers(Set<Marker> newMarkers) {
    _issueMarkers
      ..clear()
      ..addAll(newMarkers);
    emit(MapMarkerState(markers: allMarkers));
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

  late BuildContext _mapContext;

  void setContext(BuildContext context) {
    _mapContext = context;
  }

  Future<void> loadMarkersFromFirebase() async {
    debugPrint('[MapCubit] 🔄 Fetching markers from Firebase...');

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('issues').get();
      final Set<Marker> fetchedMarkers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        double? lat;
        double? lng;

        if (data.containsKey('location')) {
          final parts = (data['location'] as String).split(',');
          if (parts.length == 2) {
            lat = double.tryParse(parts[0].trim());
            lng = double.tryParse(parts[1].trim());
          }
        }

        if (lat == null || lng == null) continue;

        final category = data['category'] ?? 'Other';
        final description = data['description'] ?? '';
        final status = data['status'] ?? 'pending'; // ✅ Extracted once

        final marker = AppMarkers.buildIssueMarker(
          latitude: lat,
          longitude: lng,
          category: category,
          description: description,
          status: status,
          // ✅ Used here
          onTap: () {
            if (isAdmin) {
              debugPrint('[MapCubit] Admin tapped marker: $description');
              showModalBottomSheet(
                context: _mapContext,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withAlpha(80),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  maxChildSize: 0.95,
                  minChildSize: 0.6,
                  expand: false,
                  builder: (_, controller) {
                    return BlocProvider.value(
                      value: BlocProvider.of<MapCubit>(_mapContext),
                      child: BlocProvider(
                        create: (_) => IssueCubit(),
                        child: AdminIssueBottomSheet(
                          category: category,
                          description: description,
                          imagePath: data['image'] ?? '',
                          name: data['userName'] ?? 'Unknown',
                          email: data['userEmail'] ?? 'Unknown',
                          status: status,
                          docId: doc.id,
                          adminResolvedImage: data['adminResolvedImage'] ?? '',
                          onGetDirections: () {
                            Navigator.pop(_mapContext);
                            final latLng = LocationHelper.extractLatLngFromString(data['location']);
                            if (latLng != null) {
                              Future.delayed(const Duration(milliseconds: 300), () {
                                _mapContext.read<MapCubit>().drawRouteToIssue(
                                  latLng.latitude,
                                  latLng.longitude,
                                );
                              });
                            } else {
                              debugPrint('❌ Invalid location string: ${data['location']}');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        );

        fetchedMarkers.add(marker);
      }

      _issueMarkers
        ..clear()
        ..addAll(fetchedMarkers);

      emit(MapMarkerState(markers: allMarkers));
    } catch (e) {
      debugPrint('[MapCubit] ❌ Failed to load markers: $e');
      emit(MapErrorState());
    }
  }

  bool isAdminChecked = false;

  void checkAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final isAdmin = await AdminServices.isAdmin(uid);
      this.isAdmin = isAdmin;
      isAdminChecked = true;
      emit(MapAdminState(isAdmin));
    }
  }

  void refreshMarkers() {
    loadMarkersFromFirebase();
  }



  Future<void> drawRouteToIssue(double destLat, double destLng) async {
    debugPrint('🧭 drawRouteToIssue START: $destLat, $destLng');

    final origin = await LocationHelper.getCurrentLocation();

    debugPrint('📍 Origin: ${origin.latitude}, ${origin.longitude}');

    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.env['GOOGLE_API_KEY']!,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destLat, destLng),
        mode: TravelMode.driving,
      ),
    );

    debugPrint('📈 Fetched ${result.points.length} polyline points');


    if (result.points.isEmpty) {
      debugPrint('❌ No route found');
      emit(MapRouteErrorState('No route found'));
      return;
    }

    final polylineCoordinates = result.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: polylineCoordinates,
    );

    debugPrint('✅ Emitting MapRouteState with ${polyline.points.length} points');

    emit(MapRouteState(
      polyline: polyline,
      cameraTarget: LatLng(destLat, destLng),
    ));
  }
}
