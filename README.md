# auto_image

A smart Flutter image widget that handles **network, asset, file, base64, and SVG** images with a single unified API.

No more switching between `Image.network`, `Image.asset`, `CachedNetworkImage`, `flutter_svg`, and `Image.memory`. Just use `AutoImage`.

## Screenshots

### Asset

![Asset examples](https://raw.githubusercontent.com/ahmedsabry10/auto_image/main/doc/screenshots/asset.png)

### SVG

![SVG examples](https://raw.githubusercontent.com/ahmedsabry10/auto_image/main/doc/screenshots/svg.png)

### File + Base64

![File/Base64 examples](https://raw.githubusercontent.com/ahmedsabry10/auto_image/main/doc/screenshots/file_base64.png)

### Network

![Network examples](https://raw.githubusercontent.com/ahmedsabry10/auto_image/main/doc/screenshots/network.png)

## Features

- 🌐 **Network** images with automatic caching
- 📦 **Asset** images from your project
- 📁 **File** images from device storage
- 🔤 **Base64** images — decoded automatically
- 🎨 **SVG** — network and asset, no extra setup
- 🧠 **Auto-detection** — no need to pick the right widget
- ✨ **Shimmer** placeholder out of the box
- 🎭 **BlurHash** placeholder support
- 🧩 **Custom loading UI** with `loadingBuilder` (optional progress)
- ⚠️ **Error handling** with retry button
- 🔄 **Auto retry** with configurable policy
- ✂️ **Shapes** — circle, rounded, custom clipper
- 🎬 **Transforms** — grayscale, sepia, blur, brightness, contrast
- 📊 **Download progress** callback
- 💾 **Cache control** — duration, max size, custom key

---

## Installation

```yaml
dependencies:
  auto_image: ^0.0.7
```

```bash
flutter pub add auto_image
```

---

## Quick start

```dart
import 'package:auto_image/auto_image.dart';

// Network
AutoImage('https://example.com/photo.jpg')

// Asset
AutoImage('assets/images/logo.png')

// File
AutoImage('/storage/emulated/0/DCIM/photo.jpg')

// Base64
AutoImage('data:image/png;base64,iVBORw0KGgo...')

// SVG
AutoImage('assets/icons/logo.svg')
AutoImage('https://example.com/icon.svg')
```

---

## Main example (anySrc)

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

More docs: `doc/usage.md`

## More examples

### Shimmer placeholder (default)
```dart
AutoImage(
  'https://example.com/photo.jpg',
  width: 300,
  height: 200,
  shape: ImageShape.roundedRect,
  borderRadius: BorderRadius.circular(16),
)
```

### BlurHash placeholder
```dart
AutoImage(
  'https://example.com/photo.jpg',
  placeholder: ImagePlaceholder.blurHash,
  blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
)
```

### Custom loading widget (with progress)
```dart
AutoImage(
  'https://example.com/large-photo.jpg',
  loadingBuilder: (context, {progress}) {
    return Center(
      child: CircularProgressIndicator(value: progress),
    );
  },
)
```

### Circle avatar
```dart
AutoImage(
  'https://example.com/avatar.jpg',
  width: 60,
  height: 60,
  shape: ImageShape.circle,
)
```

### Error handling with retry
```dart
AutoImage(
  'https://example.com/photo.jpg',
  retry: RetryConfig(maxAttempts: 3),
  fallbackBuilder: (error, stackTrace, retry) => ErrorCard(
    message: error.toString(),
    onRetry: retry,
  ),
)
```

### Image transforms
```dart
// Grayscale
AutoImage('url', transform: ImageTransform.grayscaleFilter)

// Sepia
AutoImage('url', transform: ImageTransform.sepiaFilter)

// Custom
AutoImage(
  'url',
  transform: ImageTransform(
    brightness: 1.2,
    contrast: 1.1,
    blur: 2.0,
  ),
)
```

### Download progress
```dart
AutoImage(
  'https://example.com/large-photo.jpg',
  onProgress: (progress) {
    print('${(progress * 100).toInt()}% loaded');
  },
)
```

### Cache control
```dart
AutoImage(
  'https://example.com/photo.jpg',
  cache: CacheConfig(
    maxAge: Duration(days: 30),
    key: 'my-custom-key',
  ),
)
```

### Preloading
```dart
// Preload before navigating to a gallery screen
await AutoImagePreloader.preloadAll(context, imageUrls);
Navigator.push(context, GalleryRoute());
```

---

## API Reference

| Parameter | Type | Default | Description |
|---|---|---|---|
| `src` | `String` | required | Image source — any type |
| `width` | `double?` | null | Width |
| `height` | `double?` | null | Height |
| `fit` | `BoxFit` | cover | How image fills container |
| `placeholder` | `ImagePlaceholder` | shimmer | Loading placeholder type |
| `loadingBuilder` | `LoadingBuilder?` | null | Custom loading widget (progress optional) |
| `blurHash` | `String?` | null | BlurHash string |
| `errorWidget` | `Widget?` | null | Widget shown on error |
| `fallbackBuilder` | `FallbackBuilder?` | null | Builder with error + retry |
| `shape` | `ImageShape` | rectangle | Clip shape |
| `borderRadius` | `BorderRadius?` | null | For roundedRect shape |
| `cache` | `CacheConfig` | default | Cache settings |
| `retry` | `RetryConfig` | 3 attempts | Retry settings |
| `transform` | `ImageTransform?` | null | Visual filters |
| `fadeIn` | `Duration` | 300ms | Fade animation duration |
| `headers` | `Map<String,String>?` | null | HTTP headers |
| `imageColor` | `Color?` | null | Tint (SVG + raster: PNG, JPEG, …); `BlendMode.srcIn` |
| `onLoad` | `VoidCallback?` | null | Called when loaded |
| `onError` | `ErrorCallback?` | null | Called on error |
| `onProgress` | `ProgressCallback?` | null | Download progress |

---

## License

MIT
