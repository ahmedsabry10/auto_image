import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/cache_config.dart';
import 'models/image_placeholder.dart';
import 'models/image_shape.dart';
import 'models/retry_config.dart';
import 'placeholder/blurhash_placeholder.dart';
import 'placeholder/shimmer_placeholder.dart';
import 'source/source_detector.dart';
import 'transform/image_transform.dart';

/// Callback types
typedef ProgressCallback = void Function(double progress);
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);
typedef FallbackBuilder = Widget Function(
  Object error,
  StackTrace? stackTrace,
  VoidCallback retry,
);
typedef LoadingBuilder = Widget Function(
  BuildContext context, {
  double? progress,
});

/// AutoImage — one widget for all your image needs.
///
/// ```dart
/// // Network
/// AutoImage('https://example.com/photo.jpg')
///
/// // Asset
/// AutoImage('assets/images/logo.png')
///
/// // File
/// AutoImage('/storage/emulated/0/DCIM/photo.jpg')
///
/// // Base64
/// AutoImage('data:image/png;base64,iVBORw0KGgo...')
///
/// // SVG (network or asset)
/// AutoImage('assets/icons/logo.svg')
/// AutoImage('https://example.com/icon.svg')
/// ```
class AutoImage extends StatefulWidget {
  const AutoImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    // Placeholder
    this.placeholder = ImagePlaceholder.shimmer,
    this.placeholderWidget,
    this.loadingBuilder,
    this.blurHash,
    this.placeholderColor,
    // Error
    this.errorWidget,
    this.fallbackBuilder,
    // Shape
    this.shape = ImageShape.rectangle,
    this.borderRadius,
    this.clipper,
    // Cache
    this.cache = const CacheConfig(),
    // Retry
    this.retry = const RetryConfig(),
    // Transform
    this.transform,
    // Animation
    this.fadeIn = const Duration(milliseconds: 300),
    // Network options
    this.headers,
    // Tint (SVG, PNG, and other raster formats)
    this.imageColor,
    // Callbacks
    this.onLoad,
    this.onError,
    this.onProgress,
  });

  /// The image source — URL, asset path, file path, base64, or SVG
  final String src;

  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;

  /// What to show while loading
  final ImagePlaceholder placeholder;

  /// Custom placeholder widget (overrides [placeholder])
  final Widget? placeholderWidget;

  /// Builder for a custom loading widget.
  ///
  /// If provided, it overrides [placeholderWidget] and [placeholder] and can
  /// optionally receive network download progress \(0.0 → 1.0\).
  final LoadingBuilder? loadingBuilder;

  /// BlurHash string for [ImagePlaceholder.blurHash]
  final String? blurHash;

  /// Background color for [ImagePlaceholder.color]
  final Color? placeholderColor;

  /// Widget to show when loading fails
  final Widget? errorWidget;

  /// Builder with error details + retry callback
  final FallbackBuilder? fallbackBuilder;

  /// Shape of the image
  final ImageShape shape;

  /// Border radius for [ImageShape.roundedRect]
  final BorderRadius? borderRadius;

  /// Custom clipper for [ImageShape.custom]
  final CustomClipper<Path>? clipper;

  /// Cache configuration for network images
  final CacheConfig cache;

  /// Retry configuration for network failures
  final RetryConfig retry;

  /// Visual filter transforms (grayscale, sepia, blur…)
  final ImageTransform? transform;

  /// Fade-in duration when image appears
  final Duration fadeIn;

  /// HTTP headers for network requests (e.g. Authorization)
  final Map<String, String>? headers;

  /// Tint color ([BlendMode.srcIn]) for SVG and raster images (PNG, JPEG, WebP, …).
  ///
  /// Same behavior as Flutter’s SVG `colorFilter`: opaque pixels take this color;
  /// transparency is preserved. Best for monochrome icons and masks.
  final Color? imageColor;

  /// Called when image finishes loading successfully
  final VoidCallback? onLoad;

  /// Called when image fails to load
  final ErrorCallback? onError;

  /// Called during network download with progress 0.0 → 1.0
  final ProgressCallback? onProgress;

  @override
  State<AutoImage> createState() => _AutoImageState();
}

class _AutoImageState extends State<AutoImage> {
  late ImageSourceType _sourceType;
  Object? _error;
  StackTrace? _stackTrace;
  int _retryKey = 0;

  @override
  void initState() {
    super.initState();
    _sourceType = SourceDetector.detect(widget.src);
  }

  @override
  void didUpdateWidget(AutoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _sourceType = SourceDetector.detect(widget.src);
      _error = null;
    }
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    widget.onError?.call(error, stackTrace);
    if (!mounted) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = error;
            _stackTrace = stackTrace;
          });
        }
      });
    } else {
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _retryKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final fallback = widget.fallbackBuilder?.call(_error!, _stackTrace, _retry) ??
          widget.errorWidget ??
          _DefaultErrorWidget(onRetry: _retry);

      return _applyShape(_applySize(fallback));
    }

    final image = KeyedSubtree(
      key: ValueKey(_retryKey),
      child: _buildImage(),
    );

    return _applyShape(_applyTransform(_applySize(image)));
  }

  Widget _buildImage() {
    switch (_sourceType) {
      case ImageSourceType.network:
        return _buildNetworkImage();
      case ImageSourceType.asset:
        return _buildAssetImage();
      case ImageSourceType.file:
        return _buildFileImage();
      case ImageSourceType.base64:
        return _buildBase64Image();
      case ImageSourceType.svg:
        return _buildSvgImage();
    }
  }

  /// [BlendMode.srcIn] tint for raster ([ColorFiltered]) and SVG.
  ColorFilter? get _rasterTintFilter =>
      widget.imageColor != null ? ColorFilter.mode(widget.imageColor!, BlendMode.srcIn) : null;

  Widget _applyRasterTint(Widget child) {
    final filter = _rasterTintFilter;
    if (filter == null) return child;
    return ColorFiltered(colorFilter: filter, child: child);
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: widget.src,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      httpHeaders: widget.headers,
      fadeInDuration: widget.fadeIn,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      cacheKey: widget.cache.key,
      progressIndicatorBuilder: widget.onProgress != null
          ? (context, url, progress) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onProgress?.call(progress.progress ?? 0);
              });
              return _buildLoading(context, progress: progress.progress);
            }
          : null,
      placeholder: widget.onProgress == null
          ? (context, url) => _buildLoading(context)
          : null,
      errorWidget: (context, url, error) {
        _handleError(error, null);
        return _buildLoading(context);
      },
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onLoad?.call();
        });
        return _applyRasterTint(
          Image(
            image: imageProvider,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            alignment: widget.alignment,
          ),
        );
      },
    );
  }

  Widget _buildAssetImage() {
    return _applyRasterTint(
      Image.asset(
        widget.src,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        frameBuilder: _fadeFrameBuilder,
        errorBuilder: (context, error, stackTrace) {
          _handleError(error, stackTrace);
          return _buildLoading(context);
        },
      ),
    );
  }

  Widget _buildFileImage() {
    final path = widget.src.replaceFirst('file://', '');
    return _applyRasterTint(
      Image.file(
        File(path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        frameBuilder: _fadeFrameBuilder,
        errorBuilder: (context, error, stackTrace) {
          _handleError(error, stackTrace);
          return _buildLoading(context);
        },
      ),
    );
  }

  Widget _buildBase64Image() {
    try {
      final base64Str = widget.src.contains(',') ? widget.src.split(',').last : widget.src;
      final bytes = base64Decode(base64Str);
      return _applyRasterTint(
        Image.memory(
          bytes,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          frameBuilder: _fadeFrameBuilder,
          errorBuilder: (context, error, stackTrace) {
            _handleError(error, stackTrace);
            return _buildLoading(context);
          },
        ),
      );
    } catch (e, s) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleError(e, s));
      return _buildLoading(context);
    }
  }

  Widget _buildSvgImage() {
    final isNetwork = widget.src.startsWith('http');
    final colorFilter = _rasterTintFilter;

    if (isNetwork) {
      return SvgPicture.network(
        widget.src,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        headers: widget.headers ?? {},
        colorFilter: colorFilter,
        placeholderBuilder: (context) => _buildLoading(context),
      );
    }

    return SvgPicture.asset(
      widget.src,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      colorFilter: colorFilter,
      placeholderBuilder: (context) => _buildLoading(context),
    );
  }

  Widget _buildLoading(
    BuildContext context, {
    double? progress,
  }) {
    final loadingBuilder = widget.loadingBuilder;
    if (loadingBuilder != null) {
      return loadingBuilder(context, progress: progress);
    }

    if (widget.placeholderWidget != null) return widget.placeholderWidget!;

    switch (widget.placeholder) {
      case ImagePlaceholder.shimmer:
        return ShimmerPlaceholder(
          width: widget.width,
          height: widget.height,
          borderRadius: widget.shape == ImageShape.roundedRect ? widget.borderRadius : null,
        );

      case ImagePlaceholder.blurHash:
        if (widget.blurHash != null) {
          return BlurHashPlaceholder(
            blurHash: widget.blurHash!,
            width: widget.width,
            height: widget.height,
          );
        }
        return _colorPlaceholder();

      case ImagePlaceholder.color:
        return _colorPlaceholder();

      case ImagePlaceholder.none:
        return const SizedBox.shrink();
    }
  }

  Widget _colorPlaceholder() => Container(
        width: widget.width,
        height: widget.height,
        color: widget.placeholderColor ?? const Color(0xFFE0E0E0),
      );

  Widget _fadeFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded || frame != null) {
      if (frame == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onLoad?.call();
        });
      }
      return child;
    }
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: widget.fadeIn,
      child: child,
    );
  }

  Widget _applySize(Widget child) {
    if (widget.width == null && widget.height == null) return child;
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }

  Widget _applyTransform(Widget child) {
    if (widget.transform == null) return child;
    return widget.transform!.applyTo(child);
  }

  Widget _applyShape(Widget child) {
    return widget.shape.applyTo(
      child,
      borderRadius: widget.borderRadius,
      clipper: widget.clipper,
    );
  }
}

class _DefaultErrorWidget extends StatefulWidget {
  const _DefaultErrorWidget({this.onRetry});
  final VoidCallback? onRetry;

  @override
  State<_DefaultErrorWidget> createState() => _DefaultErrorWidgetState();
}

class _DefaultErrorWidgetState extends State<_DefaultErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRetry() {
    _controller.forward(from: 0).then((_) {
      widget.onRetry?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final minSide = size.shortestSide;
          final iconSize = (minSide * 0.35).clamp(8.0, 28.0);

          return GestureDetector(
            onTap: _handleRetry,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (minSide >= 24)
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF9F9F9), Color(0xFFEFEFEF)],
                      ),
                    ),
                  ),
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) => Transform.rotate(
                      angle: _controller.value * 6.28318,
                      child: child,
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: iconSize,
                      color: const Color(0xFFC0C0C0),
                    ),
                  ),
                ),
                if (minSide >= 70)
                  Positioned(
                    bottom: minSide * 0.12,
                    left: 0,
                    right: 0,
                    child: Text(
                      'tap to retry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (minSide * 0.1).clamp(9.0, 11.0),
                        color: const Color(0xFFCCCCCC),
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
