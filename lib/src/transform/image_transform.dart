import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Apply visual filters to the image
class ImageTransform {
  const ImageTransform({
    this.grayscale = 0.0,
    this.sepia = 0.0,
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.blur = 0.0,
    this.opacity = 1.0,
  });

  /// Grayscale intensity 0.0 (color) → 1.0 (full grayscale)
  final double grayscale;

  /// Sepia intensity 0.0 → 1.0
  final double sepia;

  /// Brightness multiplier — 1.0 = normal, >1.0 = brighter
  final double brightness;

  /// Contrast multiplier — 1.0 = normal
  final double contrast;

  /// Blur radius in pixels
  final double blur;

  /// Opacity 0.0 → 1.0
  final double opacity;

  // ── Presets ──────────────────────────────────────────

  static const ImageTransform none = ImageTransform();

  static const ImageTransform grayscaleFilter = ImageTransform(grayscale: 1.0);

  static const ImageTransform sepiaFilter = ImageTransform(sepia: 1.0);

  static const ImageTransform dimmed = ImageTransform(opacity: 0.5);

  static const ImageTransform softBlur = ImageTransform(blur: 4.0);

  // ── Apply ─────────────────────────────────────────────

  /// Wraps [child] with the appropriate filters
  Widget applyTo(Widget child) {
    Widget result = child;

    // Apply blur
    if (blur > 0) {
      result = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: result,
      );
    }

    // Apply color matrix (grayscale, sepia, brightness, contrast)
    final matrix = _buildColorMatrix();
    if (matrix != null) {
      result = ColorFiltered(
        colorFilter: ColorFilter.matrix(matrix),
        child: result,
      );
    }

    // Apply opacity
    if (opacity < 1.0) {
      result = Opacity(opacity: opacity.clamp(0.0, 1.0), child: result);
    }

    return result;
  }

  /// Returns a 5x4 color matrix combining all active filters.
  /// Returns null if no color transformation is needed.
  List<double>? _buildColorMatrix() {
    final hasGrayscale = grayscale > 0;
    final hasSepia = sepia > 0;
    final hasBrightness = brightness != 1.0;
    final hasContrast = contrast != 1.0;

    if (!hasGrayscale && !hasSepia && !hasBrightness && !hasContrast) {
      return null;
    }

    // Start with identity matrix
    var matrix = _identityMatrix();

    if (hasGrayscale) matrix = _multiply(matrix, _grayscaleMatrix(grayscale));
    if (hasSepia) matrix = _multiply(matrix, _sepiaMatrix(sepia));
    if (hasBrightness) matrix = _multiply(matrix, _brightnessMatrix(brightness));
    if (hasContrast) matrix = _multiply(matrix, _contrastMatrix(contrast));

    return matrix;
  }

  static List<double> _identityMatrix() => [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static List<double> _grayscaleMatrix(double amount) {
    final v = 1 - amount;
    const lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
    return [
      lumR + v * (1 - lumR), lumG - v * lumG,       lumB - v * lumB,       0, 0,
      lumR - v * lumR,       lumG + v * (1 - lumG), lumB - v * lumB,       0, 0,
      lumR - v * lumR,       lumG - v * lumG,       lumB + v * (1 - lumB), 0, 0,
      0,                     0,                     0,                     1, 0,
    ];
  }

  static List<double> _sepiaMatrix(double amount) {
    final v = 1 - amount;
    return [
      0.393 + v * 0.607, 0.769 - v * 0.769, 0.189 - v * 0.189, 0, 0,
      0.349 - v * 0.349, 0.686 + v * 0.314, 0.168 - v * 0.168, 0, 0,
      0.272 - v * 0.272, 0.534 - v * 0.534, 0.131 + v * 0.869, 0, 0,
      0,                 0,                 0,                  1, 0,
    ];
  }

  static List<double> _brightnessMatrix(double brightness) {
    final b = brightness - 1;
    return [
      1, 0, 0, 0, b * 255,
      0, 1, 0, 0, b * 255,
      0, 0, 1, 0, b * 255,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _contrastMatrix(double contrast) {
    final t = (1 - contrast) / 2 * 255;
    return [
      contrast, 0,        0,        0, t,
      0,        contrast, 0,        0, t,
      0,        0,        contrast, 0, t,
      0,        0,        0,        1, 0,
    ];
  }

  /// Simple 4x5 matrix multiplication
  static List<double> _multiply(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        double sum = 0;
        for (var i = 0; i < 4; i++) {
          sum += a[row * 5 + i] * b[i * 5 + col];
        }
        if (col == 4) sum += a[row * 5 + 4];
        result[row * 5 + col] = sum;
      }
    }
    return result;
  }
}
