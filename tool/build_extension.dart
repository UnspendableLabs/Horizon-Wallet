import 'dart:io';
import 'dart:convert';
import 'package:process_runner/process_runner.dart';

final _process = ProcessRunner(printOutputDefault: true);

void main(List<String> args) async {
  final browser =
      Platform.environment['TARGET_BROWSER']?.toLowerCase() ?? "chromium";
  final network = Platform.environment['HORIZON_NETWORK'] ?? 'mainnet';
  final apiBase = Platform.environment['HORIZON_COUNTERPARTY_API_BASE'];
  final apiUsername = Platform.environment['HORIZON_COUNTERPARTY_API_USERNAME'];
  final apiPassword = Platform.environment['HORIZON_COUNTERPARTY_API_PASSWORD'];
  final analyticsEnabled =
      Platform.environment['HORIZON_ANALYTICS_ENABLED'] ?? 'false';

  final posthogApiKey = Platform.environment['HORIZON_POSTHOG_API_KEY'] ?? '';

  final posthogApiHost = Platform.environment['HORIZON_POSTHOG_API_HOST'] ?? '';

  if (browser != "chromium") {
    print(
        'Chromium is only supported build target.  See https://bugzilla.mozilla.org/show_bug.cgi?id=1688314');
    exit(1);
  }

  if (apiBase == null) {
    print('HORIZON_COUNTERPARTY_API_BASE is required.');
    exit(1);
  }

  if (apiUsername == null) {
    print('HORIZON_COUNTERPARTY_API_USERNAME is required.');
    exit(1);
  }

  if (apiPassword == null) {
    print('HORIZON_COUNTERPARTY_API_PASSWORD is required.');
    exit(1);
  }

  final originalIndexHtml = await buildIndexHtml();
  final originalManifest = await buildManifest(browser);
  await buildFlutter(network, apiBase, apiUsername, apiPassword,
      analyticsEnabled, posthogApiKey, posthogApiHost);

  // reset index.html
  await resetFile('web/index.html', originalIndexHtml);
}

Future<void> buildFlutter(
    String network,
    String apiBase,
    String username,
    String password,
    String analyticsEnabled,
    String posthogApiKey,
    String posthogApiHost) async {
  // Run the Flutter build command with environment variables
  await _process.runProcess([
    'flutter',
    'build',
    'web',
    '--web-renderer',
    'html',
    '--csp',
    '--no-web-resources-cdn',
    '--release',
    '--dart-define=HORIZON_IS_EXTENSION=true',
    '--dart-define=HORIZON_NETWORK=$network',
    '--dart-define=HORIZON_ENABLE_DB_VIEWER=true',
    '--dart-define=HORIZON_COUNTERPARTY_API_BASE=$apiBase',
    '--dart-define=HORIZON_COUNTERPARTY_API_USERNAME=$username',
    '--dart-define=HORIZON_COUNTERPARTY_API_PASSWORD=$password',
    '--dart-define=HORIZON_ANALYTICS_ENABLED=$analyticsEnabled',
    '--dart-define=HORIZON_POSTHOG_API_KEY=$posthogApiKey',
    '--dart-define=HORIZON_POSTHOG_API_HOST=$posthogApiHost',
  ]);
  print('Flutter web build complete.');
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
