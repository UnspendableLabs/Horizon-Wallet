import 'dart:io';

const _publicBuildVariables = {
  'HORIZON_ANALYTICS_ENABLED',
  'HORIZON_COUNTERPARTY_API_BASE',
  'HORIZON_ENABLE_DB_VIEWER',
  'HORIZON_ESPLORA_BASE',
  'HORIZON_IS_EXTENSION',
  'HORIZON_NETWORK',
  'HORIZON_POSTHOG_API_HOST',
  'HORIZON_POSTHOG_API_KEY',
  'HORIZON_SENTRY_DSN',
  'HORIZON_SENTRY_ENABLED',
  'HORIZON_SENTRY_ENVIRONMENT',
  'HORIZON_SENTRY_SAMPLE_RATE',
  'HORIZON_VERSION_INFO_ENDPOINT',
};

Future<void> main() async {
  final flutter = File('flutter/bin/flutter').existsSync()
      ? 'flutter/bin/flutter'
      : 'flutter';
  final dart = File('flutter/bin/dart').existsSync()
      ? 'flutter/bin/dart'
      : 'dart';
  final defines = Platform.environment.entries
      .where((entry) => _publicBuildVariables.contains(entry.key))
      .map((entry) => '--dart-define=${entry.key}=${entry.value}')
      .toList();

  final vercelEnvironment = Platform.environment['VERCEL_ENV'];
  if (vercelEnvironment != null &&
      vercelEnvironment.isNotEmpty &&
      !Platform.environment.containsKey('HORIZON_SENTRY_ENVIRONMENT')) {
    defines.add('--dart-define=HORIZON_SENTRY_ENVIRONMENT=$vercelEnvironment');
  }

  final build = await _run(flutter, [
    'build',
    'web',
    '--release',
    '--source-maps',
    ...defines,
  ]);
  if (build != 0) {
    exitCode = build;
    return;
  }

  final authToken = Platform.environment['SENTRY_AUTH_TOKEN'];
  if (authToken == null || authToken.isEmpty) {
    stderr.writeln(
      'Sentry source-map upload skipped: SENTRY_AUTH_TOKEN is not configured',
    );
  } else {
    final upload = await _run(dart, ['run', 'sentry_dart_plugin']);
    if (upload != 0) {
      exitCode = upload;
      return;
    }
  }

  await _deletePublicSourceMaps();
}

Future<int> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

Future<void> _deletePublicSourceMaps() async {
  final buildDirectory = Directory('build/web');
  if (!buildDirectory.existsSync()) {
    return;
  }

  await for (final entity in buildDirectory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.map')) {
      await entity.delete();
    }
  }
}
