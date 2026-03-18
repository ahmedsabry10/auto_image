/// Configuration for automatic retry on network failure
class RetryConfig {
  const RetryConfig({
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 2),
    this.useExponentialBackoff = false,
  });

  /// Maximum number of retry attempts (default: 3)
  final int maxAttempts;

  /// Delay between retries (default: 2 seconds)
  final Duration delay;

  /// If true, doubles the delay on each attempt (2s → 4s → 8s)
  final bool useExponentialBackoff;

  /// No retry — fail immediately
  static const RetryConfig none = RetryConfig(maxAttempts: 0);

  /// Aggressive retry — 5 attempts with backoff
  static const RetryConfig aggressive = RetryConfig(
    maxAttempts: 5,
    delay: Duration(seconds: 1),
    useExponentialBackoff: true,
  );

  Duration delayForAttempt(int attempt) {
    if (!useExponentialBackoff) return delay;
    final multiplier = attempt <= 0 ? 1 : (1 << (attempt - 1));
    return Duration(milliseconds: delay.inMilliseconds * multiplier);
  }
}
