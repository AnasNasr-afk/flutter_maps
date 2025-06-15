final RegExp emailRegex = RegExp(
  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$",
);
final RegExp passwordRegex = RegExp(
  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
);


 const String suggestionBaseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
 const String placeLocationBaseUrl = 'https://maps.googleapis.com/maps/api/place/details/json';