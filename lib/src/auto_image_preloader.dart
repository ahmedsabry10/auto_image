import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'source/source_detector.dart';

/// Preloads images into cache before they appear on screen.
///
/// ```dart
/// // Preload a single image
/// await AutoImagePreloader.preload(context, 'https://example.com/photo.jpg');
///
/// // Preload a list of images (e.g. before navigating to a gallery)
/// await AutoImagePreloader.preloadAll(context, imageUrls);
/// ```
class AutoImagePreloader {
  AutoImagePreloader._();

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
    for (var i = 0; i < sources.length; i += concurrency) {
      final batch = sources.skip(i).take(concurrency).toList();
      await Future.wait(
        batch.map((src) => preload(context, src, headers: headers)),
        eagerError: false,
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
