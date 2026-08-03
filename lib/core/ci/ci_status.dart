/// GitLab CI pipeline and job states normalized for product-wide display.
enum CiStatus {
  success,
  failed,
  running,
  pending,
  warning,
  canceled,
  canceling,
  skipped,
  manual,
  created,
  scheduled,
  preparing,
  waitingForResource,
  waitingForCallback,
  unknown;

  factory CiStatus.fromApi(String value) => switch (value) {
    'success' => CiStatus.success,
    'failed' => CiStatus.failed,
    'running' => CiStatus.running,
    'pending' => CiStatus.pending,
    'warning' => CiStatus.warning,
    'canceled' => CiStatus.canceled,
    'canceling' => CiStatus.canceling,
    'skipped' => CiStatus.skipped,
    'manual' => CiStatus.manual,
    'created' => CiStatus.created,
    'scheduled' => CiStatus.scheduled,
    'preparing' => CiStatus.preparing,
    'waiting_for_resource' => CiStatus.waitingForResource,
    'waiting_for_callback' => CiStatus.waitingForCallback,
    _ => CiStatus.unknown,
  };

  /// The API status string [fromApi] maps back to this state, for payloads
  /// that round-trip through the offline cache.
  String get apiValue => switch (this) {
    CiStatus.waitingForResource => 'waiting_for_resource',
    CiStatus.waitingForCallback => 'waiting_for_callback',
    _ => name,
  };

  String get label => switch (this) {
    CiStatus.success => 'Passed',
    CiStatus.failed => 'Failed',
    CiStatus.running => 'Running',
    CiStatus.pending => 'Pending',
    CiStatus.warning => 'Passed with warnings',
    CiStatus.canceled => 'Canceled',
    CiStatus.canceling => 'Canceling',
    CiStatus.skipped => 'Skipped',
    CiStatus.manual => 'Manual',
    CiStatus.created => 'Created',
    CiStatus.scheduled => 'Scheduled',
    CiStatus.preparing => 'Preparing',
    CiStatus.waitingForResource => 'Waiting for resource',
    CiStatus.waitingForCallback => 'Waiting for callback',
    CiStatus.unknown => 'Unknown',
  };
}
