/// What to show while the image is loading
enum ImagePlaceholder {
  /// Animated shimmer effect (default)
  shimmer,

  /// Blurred color preview — requires [blurHash] parameter
  blurHash,

  /// Solid color box
  color,

  /// Show nothing (transparent)
  none,
}
