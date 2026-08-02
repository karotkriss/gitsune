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
    _ => CiStatus.unknown,
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
    CiStatus.unknown => 'Unknown',
  };
}
