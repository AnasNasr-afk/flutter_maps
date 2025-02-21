import '../data/models/place_suggestion_model.dart';

abstract class MapStates {}

class MapInitialState extends MapStates {}

class MapPlacesLoadedState extends MapStates {
  final List<PlaceSuggestionModel> placeSuggestionModel;

  MapPlacesLoadedState({required this.placeSuggestionModel});
}

class MapErrorState extends MapStates {}