import 'package:flutter/widgets.dart';

/// Shape of the displayed image
enum ImageShape {
  /// Default rectangular image
  rectangle,

  /// Circular image (perfect circle)
  circle,

  /// Rounded rectangle — use with [borderRadius]
  roundedRect,

  /// Custom clip path — use with [clipper]
  custom,
}

/// Extension to apply shape clipping to a widget
extension ImageShapeExtension on ImageShape {
  Widget applyTo(
    Widget child, {
    BorderRadius? borderRadius,
    CustomClipper<Path>? clipper,
  }) {
    switch (this) {
      case ImageShape.circle:
        return ClipOval(child: child);

      case ImageShape.roundedRect:
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: child,
        );

      case ImageShape.custom:
        assert(clipper != null, 'clipper required for ImageShape.custom');
        return ClipPath(clipper: clipper, child: child);

      case ImageShape.rectangle:
        return child;
    }
  }
}
