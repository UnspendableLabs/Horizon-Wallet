import 'dart:io';
import 'dart:convert';
import 'package:process_runner/process_runner.dart';

final _process = ProcessRunner(printOutputDefault: true);

void main(List<String> args) async {
  final browser = Platform.environment['TARGET_BROWSER']?.toLowerCase();
  final network = Platform.environment['HORIZON_NETWORK'] ?? 'mainnet';
  final apiUsername = Platform.environment['HORIZON_COUNTERPARTY_API_USERNAME'];
  final apiPassword = Platform.environment['HORIZON_COUNTERPARTY_API_PASSWORD'];

  if (browser == "firefox") {
    print('Firefox is not supported for extension build. See https://bugzilla.mozilla.org/show_bug.cgi?id=1688314');
    exit(1);
  }

  if (browser == null || (browser != 'chromium' && browser != 'firefox')) {
    print(
        'Please set the TARGET_BROWSER environment variable to "chromium" or "firefox".');
    exit(1);
  }

  if (apiUsername == null || apiPassword == null) {
    print(
        'Please set both HORIZON_COUNTERPARTY_API_USERNAME and HORIZON_COUNTERPARTY_API_PASSWORD environment variables.');
    exit(1);
  }

  final originalIndexHtml = await buildIndexHtml();
  await buildBackgroundJS();
  final originalManifest = await buildManifest(browser);
  await buildFlutter(network, apiUsername, apiPassword);

  // reset index.html
  await resetFile('web/index.html', originalIndexHtml);
  // await resetFile('web/manifest.json', originalManifest);
}

Future<void> buildFlutter(
    String network, String username, String password) async {
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
    '--dart-define=HORIZON_NETWORK=$network',
    '--dart-define=HORIZON_ENABLE_DB_VIEWER=true',
    '--dart-define=HORIZON_COUNTERPARTY_API_USERNAME=$username',
    '--dart-define=HORIZON_COUNTERPARTY_API_PASSWORD=$password',
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

  final outputPath = 'web/manifest.json';
  final outputFile = File(outputPath);
  // Write the manifest file
  await outputFile
      .writeAsString(JsonEncoder.withIndent('  ').convert(manifest));

  return original;
}

Future<String> buildIndexHtml() async {
  // Read the original index.html
  final indexPath = 'web/index.html';
  var content = await File(indexPath).readAsString();

  // Remove the serviceWorkerVersion injection for the extension build
  final serviceWorkerRegex = RegExp(
    r'<script>\s*// The value below is injected by flutter build, do not touch.\s*var serviceWorkerVersion = \{\{flutter_service_worker_version\}\};\s*</script>',
    multiLine: true,
  );
  final content_ = content.replaceAll(serviceWorkerRegex, '');
  print('Removed service worker version injection for extension build.');

  // Define output path for modified index.html
  final outputPath = 'web/index.html';
  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(content_);
  print('Prepared index.html for extension build at $outputPath');

  return content;
}

Future<void> buildBackgroundJS() async {
  await _process.runProcess([
    Platform.resolvedExecutable,
    'compile',
    'js',
    'web/background.dart',
    '--output',
    'build/web/background.js'
  ]);
}

Future<void> resetFile(String path, String content) async {
  final outputFile = File(path);
  await outputFile.writeAsString(content);
}
