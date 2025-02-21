import 'package:dio/dio.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:flutter_maps/data/webService/web_service.dart';

class MapsRepo {
  final WebService webService;

  MapsRepo(this.webService);

  Future<List<PlaceSuggestionModel>> getSuggestions(String place, String sessionToken) async {
    final suggestions = await webService.getSuggestions(place, sessionToken);
    return suggestions.map((suggestion) => PlaceSuggestionModel.fromJson(suggestion as Map<String, dynamic>)).toList();
  }
}