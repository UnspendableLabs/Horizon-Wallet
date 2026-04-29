import 'dart:io';
import 'dart:convert';
import 'package:process_runner/process_runner.dart';

final _process = ProcessRunner(printOutputDefault: true);

void main(List<String> args) async {
  final browser =
      Platform.environment['TARGET_BROWSER']?.toLowerCase() ?? "chromium";
  final analyticsEnabled =
      Platform.environment['HORIZON_ANALYTICS_ENABLED'] ?? 'false';

  final posthogApiKey = Platform.environment['HORIZON_POSTHOG_API_KEY'] ?? '';

  final posthogApiHost = Platform.environment['HORIZON_POSTHOG_API_HOST'] ?? '';

  final isSentryEnabled =
      Platform.environment['HORIZON_SENTRY_ENABLED'] ?? 'false';
  final sentryDsn = Platform.environment['HORIZON_SENTRY_DSN'] ?? '';
  final sentrySampleRate =
      Platform.environment['HORIZON_SENTRY_SAMPLE_RATE'] ?? '1.0';

  // Read version from manifest.json
  final manifestContent = await File('web/manifest.json').readAsString();
  final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
  final version = manifestJson['version'];

  if (browser != "chromium") {
    print(
        'Chromium is only supported build target.  See https://bugzilla.mozilla.org/show_bug.cgi?id=1688314');
    exit(1);
  }

  await buildBLS();
  final originalIndexHtml = await buildIndexHtml();
  final originalManifest = await buildManifest(browser);
  await buildFlutter(analyticsEnabled, posthogApiKey, posthogApiHost,
      isSentryEnabled, sentryDsn, sentrySampleRate, version);

  // reset index.html
  await resetFile('web/index.html', originalIndexHtml);
}

Future<void> buildFlutter(
    String analyticsEnabled,
    String posthogApiKey,
    String posthogApiHost,
    String isSentryEnabled,
    String sentryDsn,
    String sentrySampleRate,
    String version) async {
  // Run the Flutter build command with environment variables
  await _process.runProcess([
    'flutter',
    'build',
    'web',
    '--csp',
    '--no-web-resources-cdn',
    '--dart-define=FLUTTER_WEB_USE_SKIA=false',
    '--release',
    '--source-maps',
    '--dart-define=HORIZON_IS_EXTENSION=true',
    '--dart-define=HORIZON_ANALYTICS_ENABLED=$analyticsEnabled',
    '--dart-define=HORIZON_POSTHOG_API_KEY=$posthogApiKey',
    '--dart-define=HORIZON_POSTHOG_API_HOST=$posthogApiHost',
    '--dart-define=HORIZON_SENTRY_ENABLED=$isSentryEnabled',
    '--dart-define=HORIZON_SENTRY_DSN=$sentryDsn',
    '--dart-define=HORIZON_SENTRY_SAMPLE_RATE=$sentrySampleRate',
  ]);
  print('Flutter web build complete.');

  if (isSentryEnabled == 'true') {
    await uploadSourceMaps(version);
  }
}

Future<void> uploadSourceMaps(String version) async {
  print('Uploading source maps to Sentry for release: $version...');

  final sentryProject = Platform.environment['SENTRY_PROJECT'];
  final sentryOrg = Platform.environment['SENTRY_ORG'];
  final sentryAuthToken = Platform.environment['SENTRY_AUTH_TOKEN'];

  if (sentryProject == null || sentryOrg == null || sentryAuthToken == null) {
    print(
        'WARNING: Sentry upload skipped - missing SENTRY_PROJECT, SENTRY_ORG, or SENTRY_AUTH_TOKEN');
    return;
  }

  await _process.runProcess([
    'flutter',
    'pub',
    'run',
    'sentry_dart_plugin',
    '--sentry-define=upload_source_maps=true',
    '--sentry-define=upload_sources=true',
    '--sentry-define=release=$version',
    '--sentry-define=project=$sentryProject',
    '--sentry-define=org=$sentryOrg',
    '--sentry-define=auth_token=$sentryAuthToken',
  ]);
  print('Source maps uploaded successfully for release: $version');
}

Future<void> buildBLS() async {
  print('Building BLS bundle...');
  final toolDir = Directory('tool');
  await _process.runProcess(
    ['npm', 'install'],
    workingDirectory: toolDir,
  );
  await _process.runProcess(
    [
      'npx',
      'esbuild',
      'bls-entry.mjs',
      '--bundle',
      '--format=iife',
      '--global-name=__horizon_bls__',
      '--outfile=../web/assets/noble-bls.js',
    ],
    workingDirectory: toolDir,
  );
  print('BLS bundle built successfully.');
}

Future<String> buildManifest(String browser) async {
  // Read the template manifest
  final original = await File('web/manifest.json').readAsString();
  final manifest = jsonDecode(original) as Map<String, dynamic>;

  if (browser == 'chromium') {
    manifest['background'] = {
      'service_worker': 'background.js',
      'type': 'module',
    };
  } else if (browser == 'firefox') {
    manifest['background'] = {
      'scripts': ['background.js']
    };
  }

  const outputPath = 'web/manifest.json';
  final outputFile = File(outputPath);
  // Write the manifest file
  await outputFile
      .writeAsString(const JsonEncoder.withIndent('  ').convert(manifest));

  return original;
}

Future<String> buildIndexHtml() async {
  // Read the original index.html
  const indexPath = 'web/index.html';
  var content = await File(indexPath).readAsString();

  // Remove the serviceWorkerVersion injection for the extension build
  final serviceWorkerRegex = RegExp(
    r'<script>\s*// The value below is injected by flutter build, do not touch.\s*var serviceWorkerVersion = \{\{flutter_service_worker_version\}\};\s*</script>',
    multiLine: true,
  );
  final content_ = content.replaceAll(serviceWorkerRegex, '');
  print('Removed service worker version injection for extension build.');

  // Define output path for modified index.html
  const outputPath = 'web/index.html';
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(content_);
  print('Prepared index.html for extension build at $outputPath');

  return content;
}

Future<void> resetFile(String path, String content) async {
  final outputFile = File(path);
  await outputFile.writeAsString(content);
}
