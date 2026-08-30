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
  final dart =
      File('flutter/bin/dart').existsSync() ? 'flutter/bin/dart' : 'dart';
  final defines = Platform.environment.entries
      .where((entry) => _publicBuildVariables.contains(entry.key))
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => '--dart-define=${entry.key}=${entry.value}')
      .toList();

  // An explicit environment wins; otherwise mirror Vercel's, so that preview
  // and development deployments cannot report themselves as production. An
  // empty HORIZON_SENTRY_ENVIRONMENT counts as unset, not as an override.
  final vercelEnvironment = Platform.environment['VERCEL_ENV'];
  final configuredEnvironment =
      Platform.environment['HORIZON_SENTRY_ENVIRONMENT'];
  if (vercelEnvironment != null &&
      vercelEnvironment.isNotEmpty &&
      (configuredEnvironment == null || configuredEnvironment.isEmpty)) {
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

  await _uploadSourceMaps(dart);
  // Runs whatever the upload did: the maps must never reach the public
  // artifact, and a failed upload must not leave them behind.
  await _deletePublicSourceMaps();
}

/// Uploads source maps to Sentry, best effort.
///
/// Deliberately non-fatal: symbolication is nice to have, but a flaky
/// sentry-cli download or a slow `wait_for_processing` must not be able to
/// take down a wallet deployment.
Future<void> _uploadSourceMaps(String dart) async {
  final authToken = Platform.environment['SENTRY_AUTH_TOKEN'];
  if (authToken == null || authToken.isEmpty) {
    stderr.writeln(
      'Sentry source-map upload skipped: SENTRY_AUTH_TOKEN is not configured',
    );
    return;
  }

  final upload = await _run(dart, ['run', 'sentry_dart_plugin']);
  if (upload != 0) {
    stderr.writeln(
      'Sentry source-map upload failed with exit code $upload; '
      'continuing without symbolication',
    );
  }
}

Future<int> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

/// Deletes every source map from the public build output.
///
/// The `//# sourceMappingURL=` comments in the emitted JavaScript are left in
/// place: they only 404, and rewriting the JavaScript here would invalidate the
/// content hashes Flutter has already baked into `flutter_service_worker.js`.
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
