import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'source/source_detector.dart';

/// Preloads images into cache before they appear on screen.
///
/// ```dart
/// // Preload a single image
/// await OmniImagePreloader.preload(context, 'https://example.com/photo.jpg');
///
/// // Preload a list of images (e.g. before navigating to a gallery)
/// await OmniImagePreloader.preloadAll(context, imageUrls);
/// ```
class OmniImagePreloader {
  OmniImagePreloader._();

  /// Preloads a single image into cache
  static Future<void> preload(
    BuildContext context,
    String src, {
    Map<String, String>? headers,
  }) async {
    final type = SourceDetector.detect(src);

    switch (type) {
      case ImageSourceType.network:
        await precacheImage(
          CachedNetworkImageProvider(src, headers: headers),
          context,
        );
        break;

      case ImageSourceType.asset:
        await precacheImage(AssetImage(src), context);
        break;

      case ImageSourceType.file:
      case ImageSourceType.base64:
      case ImageSourceType.svg:
        // These are either sync or not cacheable via precacheImage
        break;
    }
  }

  /// Preloads a list of images concurrently
  static Future<void> preloadAll(
    BuildContext context,
    List<String> sources, {
    Map<String, String>? headers,
    int concurrency = 3,
  }) async {
    // Process in batches to avoid flooding the network
    for (var i = 0; i < sources.length; i += concurrency) {
      final batch = sources.skip(i).take(concurrency).toList();
      await Future.wait(
        batch.map((src) => preload(context, src, headers: headers)),
        eagerError: false, // Don't fail all if one fails
      );
    }
  }

  /// Clears a specific image from the cache
  static Future<void> evict(String src) async {
    final type = SourceDetector.detect(src);
    if (type == ImageSourceType.network) {
      await CachedNetworkImage.evictFromCache(src);
    }
  }

  /// Clears all cached network images
  static Future<void> clearCache() async {
    final manager = DefaultCacheManager();
    await manager.emptyCache();
  }
}
