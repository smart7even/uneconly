import 'package:dio/dio.dart';
import 'package:l/l.dart';

abstract class ITutorialNetworkDataProvider {
  Future<Map<String, dynamic>> fetchNews();
}

class TutorialNetworkDataProvider implements ITutorialNetworkDataProvider {
  TutorialNetworkDataProvider({
    required final Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> fetchNews() async {
    try {
      final response = await _dio.get('/asset/news');

      return response.data['content'] as Map<String, dynamic>;
    } on Object catch (e, stackTrace) {
      l.e('An error occured in TutorialNetworkDataProvider', stackTrace);

      rethrow;
    }
  }
}
