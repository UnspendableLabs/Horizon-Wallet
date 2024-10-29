import 'dart:io';
import 'package:process_runner/process_runner.dart';

final _process = ProcessRunner(printOutputDefault: true);

void main() async {
  for (var script in [
    'background.dart',
    // 'content_script.dart',
    // 'options.dart'
  ]) {
    await _process.runProcess([
      Platform.resolvedExecutable,
      'compile',
      'js',
      'web/$script',
      '--output',
      'build/web/$script.js',
    ]);
  }
}
