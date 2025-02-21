import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

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
      Response response = await dio.get(baseUrl, queryParameters: {
        'input': place,
        'types': 'address',
        'components': 'country:eg',
        'key': googleAPIKey,
        'sessiontoken': sessionToken,
      });
      return response.data['predictions'] ?? [];
    } catch (e) {
      debugPrint('WebService Error: $e');
      return [];
    }
  }
}