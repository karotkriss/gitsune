import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

/// Summarizes every timeline the perf test reports (one per glass mode)
/// into `build/<reportKey>.timeline_summary.json`.
Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data == null) return;
      for (final entry in data.entries) {
        final timeline = driver.Timeline.fromJson(
          entry.value as Map<String, dynamic>,
        );
        await driver.TimelineSummary.summarize(
          timeline,
        ).writeTimelineToFile(entry.key, pretty: true, includeSummary: true);
      }
    },
  );
}
