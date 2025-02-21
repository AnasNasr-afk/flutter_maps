import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/map_states.dart';
import 'package:flutter_maps/data/repository/maps_repo.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class MapCubit extends Cubit<MapStates> {
  final MapsRepo mapsRepo;

  MapCubit(this.mapsRepo) : super(MapInitialState());

  static MapCubit get(context) => BlocProvider.of(context);

  FloatingSearchBarController searchBarController = FloatingSearchBarController();

  void emitPlacesSuggestion(String places, String sessionToken) {
    mapsRepo.getSuggestions(places, sessionToken).then((placeSuggestions) {
      emit(MapPlacesLoadedState(placeSuggestionModel: placeSuggestions));
    }).catchError((error) {
      emit(MapErrorState());
      print('Error fetching place suggestions: $error');
    });
  }
}
