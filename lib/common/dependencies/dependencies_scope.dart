import 'package:dio/dio.dart';
import 'package:uneconly/common/database/database.dart';

class DependenciesScope {
  final Dio dio;
  final MyDatabase database;

  DependenciesScope({
    required this.database,
    required this.dio,
  });
}
