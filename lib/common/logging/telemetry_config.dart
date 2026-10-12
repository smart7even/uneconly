/// Public routing policy. The DSN is an ingestion address, never an API token.
class TelemetryConfig {
  const TelemetryConfig({this.mode = 'appmetrica', this.sentryDsn = ''});
  final String mode;
  final String sentryDsn;
  bool get appmetrica => mode == 'appmetrica' || mode == 'both';
  bool get sentry => mode == 'sentry' || mode == 'both';

  factory TelemetryConfig.parse(Object? value) {
    if (value == null) return const TelemetryConfig();
    if (value is! Map ||
        !const {
          'appmetrica',
          'sentry',
          'both',
          'off',
        }.contains(value['mode'])) {
      throw const FormatException('Invalid telemetry mode');
    }
    final dsn = value['sentry_dsn'] ?? '';
    if (dsn is! String) throw const FormatException('Invalid Sentry DSN');
    final result = TelemetryConfig(
      mode: value['mode'] as String,
      sentryDsn: dsn,
    );
    if (result.sentry) {
      final uri = Uri.tryParse(dsn);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host != 'sentry.roadmapik.com' ||
          (uri.hasPort && uri.port != 443) ||
          uri.userInfo.isEmpty ||
          uri.userInfo.contains(':') ||
          !RegExp(r'^/[0-9]+$').hasMatch(uri.path) ||
          uri.hasQuery ||
          uri.hasFragment) {
        throw const FormatException('Untrusted Sentry destination');
      }
    }
    return result;
  }
}
