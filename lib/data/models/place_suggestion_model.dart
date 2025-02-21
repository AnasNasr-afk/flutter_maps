class PlaceSuggestionModel {
  final String placeId;
  final String description;

  PlaceSuggestionModel({required this.placeId, required this.description});

  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestionModel(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
    );
  }
}