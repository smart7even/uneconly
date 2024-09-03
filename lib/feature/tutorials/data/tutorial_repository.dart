import 'package:l/l.dart';
import 'package:uneconly/feature/tutorials/data/tutorial_network_data_provider.dart';

abstract class ITutorialRepository {
  Future<Map<String, dynamic>> fetchNews();
}

class TutorialRepository implements ITutorialRepository {
  TutorialRepository({
    required final ITutorialNetworkDataProvider networkDataProvider,
  }) : _networkDataProvider = networkDataProvider;

  final ITutorialNetworkDataProvider _networkDataProvider;

  @override
  Future<Map<String, dynamic>> fetchNews() async {
    try {
      return await _networkDataProvider.fetchNews();
    } on Object catch (e, stackTrace) {
      l.e('An error occured in TutorialRepository', stackTrace);

      rethrow;
    }
  }
}
