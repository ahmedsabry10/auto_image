import 'package:flutter_test/flutter_test.dart';
import 'package:omni_image/omni_image.dart';

import 'package:omni_image/src/source/source_detector.dart';

void main() {
  // ── SourceDetector tests ─────────────────────────────────────────────────

  group('SourceDetector', () {
    test('detects https network URL', () {
      expect(
        SourceDetector.detect('https://example.com/photo.jpg'),
        ImageSourceType.network,
      );
    });

    test('detects http network URL', () {
      expect(
        SourceDetector.detect('http://example.com/photo.jpg'),
        ImageSourceType.network,
      );
    });

    test('detects asset path', () {
      expect(
        SourceDetector.detect('assets/images/logo.png'),
        ImageSourceType.asset,
      );
    });

    test('detects packages asset path', () {
      expect(
        SourceDetector.detect('packages/my_pkg/assets/icon.png'),
        ImageSourceType.asset,
      );
    });

    test('detects absolute file path', () {
      expect(
        SourceDetector.detect('/storage/emulated/0/DCIM/photo.jpg'),
        ImageSourceType.file,
      );
    });

    test('detects file:// URI', () {
      expect(
        SourceDetector.detect('file:///storage/photo.jpg'),
        ImageSourceType.file,
      );
    });

    test('detects base64 data URI', () {
      expect(
        SourceDetector.detect('data:image/png;base64,iVBORw0KGgo='),
        ImageSourceType.base64,
      );
    });

    test('detects SVG network URL', () {
      expect(
        SourceDetector.detect('https://example.com/icon.svg'),
        ImageSourceType.svg,
      );
    });

    test('detects SVG asset', () {
      expect(
        SourceDetector.detect('assets/icons/logo.svg'),
        ImageSourceType.svg,
      );
    });

    test('detects SVG with query params', () {
      expect(
        SourceDetector.detect('https://example.com/icon.svg?v=2'),
        ImageSourceType.svg,
      );
    });
  });

  // ── RetryConfig tests ────────────────────────────────────────────────────

  group('RetryConfig', () {
    test('default values are correct', () {
      const config = RetryConfig();
      expect(config.maxAttempts, 3);
      expect(config.delay, const Duration(seconds: 2));
      expect(config.useExponentialBackoff, false);
    });

    test('none preset disables retry', () {
      expect(RetryConfig.none.maxAttempts, 0);
    });

    test('linear delay does not change', () {
      const config = RetryConfig(delay: Duration(seconds: 2));
      expect(config.delayForAttempt(1), const Duration(seconds: 2));
      expect(config.delayForAttempt(2), const Duration(seconds: 2));
    });

    test('exponential backoff doubles delay', () {
      const config = RetryConfig(
        delay: Duration(seconds: 1),
        useExponentialBackoff: true,
      );
      expect(config.delayForAttempt(1), const Duration(seconds: 1));
      expect(config.delayForAttempt(2), const Duration(seconds: 2));
      expect(config.delayForAttempt(3), const Duration(seconds: 4));
    });
  });

  // ── CacheConfig tests ────────────────────────────────────────────────────

  group('CacheConfig', () {
    test('default is enabled with 7 day expiry', () {
      const config = CacheConfig();
      expect(config.enabled, true);
      expect(config.maxAge, const Duration(days: 7));
    });

    test('disabled preset turns off cache', () {
      expect(CacheConfig.disabled.enabled, false);
    });

    test('longLived preset has 30 day expiry', () {
      expect(CacheConfig.longLived.maxAge, const Duration(days: 30));
    });
  });

  // ── ImageTransform tests ────────────────────────────────────────────────

  group('ImageTransform', () {
    test('none preset returns null matrix (no transformation)', () {
      const t = ImageTransform.none;
      expect(t.grayscale, 0.0);
      expect(t.sepia, 0.0);
      expect(t.brightness, 1.0);
      expect(t.contrast, 1.0);
      expect(t.blur, 0.0);
      expect(t.opacity, 1.0);
    });

    test('grayscaleFilter preset sets grayscale to 1', () {
      expect(ImageTransform.grayscaleFilter.grayscale, 1.0);
    });

    test('sepiaFilter preset sets sepia to 1', () {
      expect(ImageTransform.sepiaFilter.sepia, 1.0);
    });
  });
}
