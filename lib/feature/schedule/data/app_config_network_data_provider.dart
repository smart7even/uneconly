import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:uneconly/common/network/network_policy.dart';
import 'package:uneconly/feature/schedule/model/app_config.dart';

abstract interface class IAppConfigNetworkDataProvider {
  Future<AppConfig> fetch({required int? groupId, required String platform});
}

class AppConfigNetworkDataProvider implements IAppConfigNetworkDataProvider {
  AppConfigNetworkDataProvider({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<AppConfig> fetch({
    required int? groupId,
    required String platform,
  }) async {
    final info = await PackageInfo.fromPlatform();
    final queryParameters = <String, dynamic>{
      'platform': platform,
      'app_version': info.version,
    };
    if (groupId != null) {
      queryParameters['group_id'] = groupId;
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/app/config',
      queryParameters: queryParameters,
      options: Options(
        sendTimeout: auxiliarySdkTimeout,
        receiveTimeout: auxiliarySdkTimeout,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('App config response is empty');
    }
    return AppConfig.fromJson(data);
  }
}
