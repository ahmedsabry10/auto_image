# omni_image

A smart Flutter image widget that handles **network, asset, file, base64, and SVG** images with a single unified API.

No more switching between `Image.network`, `Image.asset`, `CachedNetworkImage`, `flutter_svg`, and `Image.memory`. Just use `OmniImage`.

---

## Features

- 🌐 **Network** images with automatic caching
- 📦 **Asset** images from your project
- 📁 **File** images from device storage
- 🔤 **Base64** images — decoded automatically
- 🎨 **SVG** — network and asset, no extra setup
- 🧠 **Auto-detection** — no need to pick the right widget
- ✨ **Shimmer** placeholder out of the box
- 🎭 **BlurHash** placeholder support
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
  omni_image: ^1.0.0
```

```bash
flutter pub add omni_image
```

---

## Quick Start

```dart
import 'package:omni_image/omni_image.dart';

// Network
OmniImage('https://example.com/photo.jpg')

// Asset
OmniImage('assets/images/logo.png')

// File
OmniImage('/storage/emulated/0/DCIM/photo.jpg')

// Base64
OmniImage('data:image/png;base64,iVBORw0KGgo...')

// SVG
OmniImage('assets/icons/logo.svg')
OmniImage('https://example.com/icon.svg')
```

---

## Examples

### Shimmer placeholder (default)
```dart
OmniImage(
  'https://example.com/photo.jpg',
  width: 300,
  height: 200,
  shape: ImageShape.roundedRect,
  borderRadius: BorderRadius.circular(16),
)
```

### BlurHash placeholder
```dart
OmniImage(
  'https://example.com/photo.jpg',
  placeholder: ImagePlaceholder.blurHash,
  blurHash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
)
```

### Circle avatar
```dart
OmniImage(
  'https://example.com/avatar.jpg',
  width: 60,
  height: 60,
  shape: ImageShape.circle,
)
```

### Error handling with retry
```dart
OmniImage(
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
OmniImage('url', transform: ImageTransform.grayscaleFilter)

// Sepia
OmniImage('url', transform: ImageTransform.sepiaFilter)

// Custom
OmniImage(
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
OmniImage(
  'https://example.com/large-photo.jpg',
  onProgress: (progress) {
    print('${(progress * 100).toInt()}% loaded');
  },
)
```

### Cache control
```dart
OmniImage(
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
await OmniImagePreloader.preloadAll(context, imageUrls);
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
| `svgColor` | `Color?` | null | SVG tint color |
| `onLoad` | `VoidCallback?` | null | Called when loaded |
| `onError` | `ErrorCallback?` | null | Called on error |
| `onProgress` | `ProgressCallback?` | null | Download progress |

---

## License

MIT
