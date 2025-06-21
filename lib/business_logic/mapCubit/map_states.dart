import 'package:flutter_maps/data/models/place_details_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/place_suggestion_model.dart';

abstract class MapStates {}

class MapInitialState extends MapStates {}

class MapPlacesLoadedState extends MapStates {
  final List<PlaceSuggestionModel> placeSuggestionModel;

  MapPlacesLoadedState({required this.placeSuggestionModel});
}

class MapErrorState extends MapStates {}

class MapDetailsLoadedState extends MapStates {
  final PlaceDetailsModel placeDetails;
  final PlaceSuggestionModel placeSuggestion; // ✅ Add this

  MapDetailsLoadedState(this.placeDetails, this.placeSuggestion); // ✅ Include in constructor
}

class MapMarkersUpdatedState extends MapStates {
  final Set<Marker> markers;
  MapMarkersUpdatedState(this.markers);
}

class MapPlaceSelectingState extends MapStates {}

class MapPlaceSelectedState extends MapStates {
  final LatLng position;
  final String description;

  MapPlaceSelectedState({required this.position, required this.description});
}

class MapIssueSubmittedState extends MapStates {
  final LatLng location;
  final String issueDescription;

  MapIssueSubmittedState(this.location, this.issueDescription);
}
class MapDetailsErrorState extends MapStates {}

class MapMarkerState extends MapStates{
  final Set<Marker> markers;

  MapMarkerState({this.markers = const {}});

  MapMarkerState copyWith({Set<Marker>? markers}) {
    return MapMarkerState(markers: markers ?? this.markers);
  }
}


class MapAdminState extends MapStates {
  final bool isAdmin;
  MapAdminState(this.isAdmin);
}
