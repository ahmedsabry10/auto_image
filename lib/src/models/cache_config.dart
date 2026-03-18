/// Configuration for image caching
class CacheConfig {
  const CacheConfig({
    this.maxAge = const Duration(days: 7),
    this.maxMemoryCacheCount = 100,
    this.key,
    this.enabled = true,
  });

  /// How long to keep cached images (default: 7 days)
  final Duration maxAge;

  /// Max number of images in memory cache (default: 100)
  final int maxMemoryCacheCount;

  /// Custom cache key — useful if same URL returns different images
  final String? key;

  /// Whether caching is enabled (default: true)
  final bool enabled;

  /// Disable caching completely
  static const CacheConfig disabled = CacheConfig(enabled: false);

  /// Short-lived cache — good for user-generated content
  static const CacheConfig shortLived = CacheConfig(
    maxAge: Duration(hours: 1),
  );

  /// Long-lived cache — good for static assets
  static const CacheConfig longLived = CacheConfig(
    maxAge: Duration(days: 30),
  );
}
