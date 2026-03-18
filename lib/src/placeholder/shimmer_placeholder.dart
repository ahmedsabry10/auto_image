import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

/// Animated shimmer placeholder shown while image loads
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final Color? baseColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? const Color(0xFFE0E0E0);
    final highlight = highlightColor ?? const Color(0xFFF5F5F5);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
