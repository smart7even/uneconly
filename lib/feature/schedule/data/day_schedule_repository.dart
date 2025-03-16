import 'package:uneconly/feature/tutorials/data/tutorial_network_data_provider.dart';
import 'package:uneconly/feature/tutorials/model/asset_path.dart';

abstract class IDayScheduleRepository {
  Future<Map<String, dynamic>> fetchContacts();
}

class DayScheduleRepository implements IDayScheduleRepository {
  final IAssetNetworkDataProvider _networkDataProvider;

  DayScheduleRepository({
    required IAssetNetworkDataProvider networkDataProvider,
  }) : _networkDataProvider = networkDataProvider;

  @override
  Future<Map<String, dynamic>> fetchContacts() async {
    return await _networkDataProvider.fetchNewsByPath(
      AssetPath.contacts,
    );
  }
}
