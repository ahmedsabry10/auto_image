/// Types of image sources auto_image supports
enum ImageSourceType {
  /// https:// or http:// URL
  network,

  /// assets/ path from pubspec.yaml
  asset,

  /// Absolute file path on device
  file,

  /// data:image/...;base64,... string
  base64,

  /// .svg file — network or asset
  svg,
}

/// Detects the source type from a string automatically
class SourceDetector {
  SourceDetector._();

  static ImageSourceType detect(String src) {
    // Base64
    if (src.startsWith('data:image')) return ImageSourceType.base64;

    // SVG — check extension before URL check
    if (_isSvg(src)) return ImageSourceType.svg;

    // Network URL
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return ImageSourceType.network;
    }

    // Asset path
    if (src.startsWith('assets/') || src.startsWith('packages/')) {
      return ImageSourceType.asset;
    }

    // Absolute file path
    if (src.startsWith('/') || src.startsWith('file://')) {
      return ImageSourceType.file;
    }

    // Fallback: treat as asset
    return ImageSourceType.asset;
  }

  static bool _isSvg(String src) {
    final lower = src.toLowerCase();
    // Remove query params before checking extension
    final pathOnly = lower.split('?').first;
    return pathOnly.endsWith('.svg') || pathOnly.endsWith('.svgz');
  }
}
