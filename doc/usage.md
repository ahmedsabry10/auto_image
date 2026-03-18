# Usage

`AutoImage` accepts **any image source** in `src` and automatically detects the type:

- Network URL
- Asset path
- File path
- Base64 (`data:image/...;base64,...`)
- SVG (asset or network)

## One source for users (anySrc)

```dart
AutoImage(
  anySrc,
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
  shape: ImageShape.roundedRect,
  borderRadius: BorderRadius.circular(16),
  placeholder: ImagePlaceholder.shimmer, // shimmer while loading
  blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj', // blur preview
  transform: ImageTransform.grayscaleFilter, // grayscale filter
  cache: CacheConfig.longLived, // cache 30 days
  retry: RetryConfig(maxAttempts: 3), // retry on fail
  fadeIn: Duration(milliseconds: 400), // fade animation
  onLoad: () => print('✅ loaded!'), // on success
  onError: (e, s) => print('❌ error: $e'), // on error
  onProgress: (p) => print('📥 ${(p * 100).toInt()}%'), // download %
)
```

## Custom loading UI (optional progress)

```dart
AutoImage(
  anySrc,
  loadingBuilder: (context, {progress}) {
    return Center(
      child: CircularProgressIndicator(value: progress),
    );
  },
)
```
