import 'package:dio/dio.dart';
import 'package:l/l.dart';
import 'package:uneconly/feature/tutorials/model/asset_path.dart';

abstract class IAssetNetworkDataProvider {
  Future<Map<String, dynamic>> fetchNewsByPath(AssetPath path);
}

class AssetNetworkDataProvider implements IAssetNetworkDataProvider {
  AssetNetworkDataProvider({
    required final Dio dio,
  }) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> fetchNewsByPath(AssetPath path) async {
    try {
      final response = await _dio.get('/asset/${path.name}');

      return response.data['content'] as Map<String, dynamic>;
    } on Object catch (e, stackTrace) {
      l.e('An error occured in AssetNetworkDataProvider', stackTrace);

      rethrow;
    }
  }
}
