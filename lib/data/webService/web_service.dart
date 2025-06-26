import 'dart:io';

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
        'key': googleMapsApiKey, // ✅ Platform-aware key
        'sessiontoken': sessionToken,
      });
      debugPrint('✅ Dio Suggestion Response: ${response.data}');
      return response.data['predictions'] ?? [];
    } catch (e) {
      debugPrint('❌ Suggestion Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId, String sessionToken) async {
    try {
      Response response = await dio.get(placeLocationBaseUrl, queryParameters: {
        'place_id': placeId,
        'fields': 'geometry',
        'key': googleMapsApiKey, // ✅ Platform-aware key
        'sessiontoken': sessionToken,
      });
      debugPrint('✅ Place Details: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('❌ Place Details Error: $e');
      return {};
    }
  }
}

String get googleMapsApiKey {
  if (Platform.isAndroid) {
    return dotenv.env['GOOGLE_API_KEY_ANDROID'] ?? '';
  } else if (Platform.isIOS) {
    return dotenv.env['GOOGLE_API_KEY_IOS'] ?? ''; // Update if needed
  } else {
    return '';
  }
}
