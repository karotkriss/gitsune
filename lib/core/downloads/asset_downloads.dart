import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Resolves the directory a downloaded file should land in: the platform's
/// downloads directory (app-scoped on Android, the sandboxed Downloads
/// folder on iOS), falling back to the app's document directory on the rare
/// platform that reports none currently available. Creates the directory if
/// it doesn't exist yet.
Future<Directory> resolveDownloadsDirectory() async {
  final dir =
      await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}
