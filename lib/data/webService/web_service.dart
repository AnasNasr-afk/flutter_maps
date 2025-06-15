import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../helpers/app_strings.dart';

class WebService {
  late Dio dio;

  WebService() {
    BaseOptions baseOptions = BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveDataWhenStatusError: true,
    );
    dio = Dio(baseOptions);
  }

  Future<List<dynamic>> getSuggestions(String place, String sessionToken) async {
    try {
      Response response = await dio.get(suggestionBaseUrl, queryParameters: {
        'input': place,
        'types': 'address',
        'components': 'country:eg',
        'key': dotenv.env['GOOGLE_API_KEY'],
        'sessiontoken': sessionToken,
      });
      debugPrint('Dio Response: ${response.data}');
      return response.data['predictions'] ?? [];
    } catch (e) {
      debugPrint('WebService Error: $e');
      return [];
    }
  }

  Future<dynamic> getPlaceDetails(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(placeLocationBaseUrl, queryParameters: {
        'place_id': placeId,
        'fields': 'geometry',
        'key': dotenv.env['GOOGLE_API_KEY'],
        'sessiontoken': sessionToken,
      });
      return response.data;
    } catch (e) {
      debugPrint('WebService Error: $e');
      return [];
    }
  }
}