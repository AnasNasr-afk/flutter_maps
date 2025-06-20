class PlaceDetailsModel {
  late Result result;

  PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    result = Result.fromJson(json['result']);
  }
}

class Result {
  late Geometry geometry;

  Result.fromJson(Map<String, dynamic> json) {
    geometry = Geometry.fromJson(json['geometry']);
  }
}

class Geometry {
  late Location location;

  Geometry.fromJson(Map<String, dynamic> json) {
    location = Location.fromJson(json['location']);
  }
}

class Location {
  late double lat;
  late double lng;

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toDouble() ?? 0.0;
    lng = json['lng']?.toDouble() ?? 0.0;
  }
}
