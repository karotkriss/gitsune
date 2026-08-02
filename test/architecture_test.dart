import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:flutter_test/flutter_test.dart';

/// Enforces the core-versus-feature boundary: `core/` is shared
/// infrastructure and must never depend on `features/`, only the reverse.
void main() {
  test(
    'core never imports or exports features',
    () async {
      final projectDir = Directory.current.absolute;
      final coreDir = Directory('${projectDir.path}/lib/core');
      final featuresUri = Directory(
        '${projectDir.path}/lib/features',
      ).absolute.uri.normalizePath();
      // Only core files are resolved, so only include them: resolving the full
      // dependency graph grows with every added package and can blow past the
      // default 30-second test timeout otherwise.
      final collection = AnalysisContextCollection(
        includedPaths: [coreDir.path],
        sdkPath: _dartSdkPath(),
      );
      final violations = <String>[];

      try {
        for (final entity in coreDir.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;

          final path = entity.absolute.path;
          final context = collection.contextFor(path);
          final result = await context.currentSession.getResolvedUnit(path);
          if (result is! ResolvedUnitResult) {
            fail('Could not resolve $path for architecture validation.');
          }

          for (final directive
              in result.unit.directives.whereType<NamespaceDirective>()) {
            final referencesFeature = _referencedUris(
              directive,
              result.uri,
            ).any((uri) => _isFeatureUri(uri, featuresUri));
            if (!referencesFeature) continue;

            final line = result.lineInfo
                .getLocation(directive.offset)
                .lineNumber;
            final source = directive.toSource().replaceAll(RegExp(r'\s+'), ' ');
            violations.add('${entity.path}:$line: $source');
          }
        }
      } finally {
        await collection.dispose();
      }

      expect(
        violations,
        isEmpty,
        reason:
            'core/ must not import or export features/:\n'
            '${violations.join('\n')}',
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

String _dartSdkPath() {
  var directory = File(Platform.resolvedExecutable).parent;

  while (directory.parent.path != directory.path) {
    if (File('${directory.path}/lib/libraries.json').existsSync()) {
      return directory.path;
    }

    final bundledSdk = Directory('${directory.path}/dart-sdk');
    if (File('${bundledSdk.path}/lib/libraries.json').existsSync()) {
      return bundledSdk.path;
    }

    directory = directory.parent;
  }

  throw StateError('Could not locate the Dart SDK.');
}

Iterable<Uri> _referencedUris(
  NamespaceDirective directive,
  Uri containingUri,
) sync* {
  final resolvedUri = switch (directive) {
    ImportDirective() => directive.libraryImport?.uri,
    ExportDirective() => directive.libraryExport?.uri,
  };
  if (resolvedUri is DirectiveUriWithSource) {
    yield resolvedUri.source.uri.normalizePath();
  }

  final uri = directive.uri.stringValue;
  if (uri != null) yield containingUri.resolve(uri).normalizePath();

  for (final configuration in directive.configurations) {
    final resolvedUri = configuration.resolvedUri;
    if (resolvedUri is DirectiveUriWithSource) {
      yield resolvedUri.source.uri.normalizePath();
    }

    final uri = configuration.uri.stringValue;
    if (uri != null) yield containingUri.resolve(uri).normalizePath();
  }
}

bool _isFeatureUri(Uri uri, Uri featuresUri) {
  if (uri.scheme == 'package') {
    final segments = uri.pathSegments;
    return segments.length > 1 &&
        segments.first == 'gitsune' &&
        segments[1] == 'features';
  }

  return uri.scheme == 'file' && uri.path.startsWith(featuresUri.path);
}
