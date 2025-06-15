import 'package:flutter_maps/data/models/place_details_model.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:flutter_maps/data/webService/web_service.dart';

class MapsRepo {
  final WebService webService;

  MapsRepo(this.webService);

  Future<List<PlaceSuggestionModel>> getSuggestions(String place, String sessionToken) async {
    final suggestions = await webService.getSuggestions(place, sessionToken);
    return suggestions.map((suggestion) => PlaceSuggestionModel.fromJson(suggestion as Map<String, dynamic>)).toList();
  }

  Future<PlaceDetailsModel> getLocationDetails(String placeId, String sessionToken) async {
    final placeDetails = await webService.getPlaceDetails(placeId, sessionToken);
    // return placeDetails.map((details) => PlaceDetailsModel.fromJson(details as Map<String, dynamic>)).toList();
    return PlaceDetailsModel.fromJson(placeDetails);
  }


}