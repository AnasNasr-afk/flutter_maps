final RegExp emailRegex = RegExp(
  r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$",
);
final RegExp passwordRegex = RegExp(
  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
);

 const String googleAPIKey = 'AIzaSyCxs-270r0w_bkJuak83aQnakuJdq1EFRs';

 const String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';