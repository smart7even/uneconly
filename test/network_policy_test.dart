import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uneconly/common/network/network_policy.dart';

void main() {
  test(
    'a connected twenty-second response is cancelled at the production deadline',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requestSeen = Completer<void>();
      final releaseServer = Completer<void>();
      final requests = server.listen((request) async {
        if (!requestSeen.isCompleted) requestSeen.complete();
        await Future.any<void>([
          Future<void>.delayed(const Duration(seconds: 20)),
          releaseServer.future,
        ]);
        try {
          request.response.write('{}');
          await request.response.close();
        } on Object {
          // The client intentionally closes the connection after its deadline.
        }
      });
      final client = createApiClient(
        baseUrl: 'http://${server.address.host}:${server.port}',
      );

      try {
        final stopwatch = Stopwatch()..start();
        await expectLater(
          client.get<dynamic>('/slow'),
          throwsA(
            isA<DioException>().having(
              (error) => error.type,
              'type',
              DioExceptionType.receiveTimeout,
            ),
          ),
        );
        await requestSeen.future;
        expect(
          stopwatch.elapsed,
          greaterThanOrEqualTo(const Duration(seconds: 11)),
        );
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 15)));
      } finally {
        client.close(force: true);
        if (!releaseServer.isCompleted) releaseServer.complete();
        await requests.cancel();
        await server.close(force: true);
      }
    },
  );

  test('production API deadlines stay below twenty seconds', () {
    expect(apiConnectTimeout, lessThan(const Duration(seconds: 20)));
    expect(apiSendTimeout, lessThan(const Duration(seconds: 20)));
    expect(apiReceiveTimeout, lessThan(const Duration(seconds: 20)));
  });
}
