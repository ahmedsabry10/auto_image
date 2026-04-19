## 0.1.0

- **Breaking:** Renamed `svgColor` to `imageColor` so the API clearly applies to all image kinds, not only SVG.
- Apply `imageColor` tint ([`BlendMode.srcIn`](https://api.flutter.dev/flutter/dart-ui/BlendMode.html)) to raster images (network, asset, file, base64) as well as SVG; network placeholders stay untinted.

## 0.0.6

- Add pub.dev screenshot gallery metadata.
- Render screenshots reliably in README.

## 0.0.7

- Fix README screenshots rendering on pub.dev using raw GitHub image URLs.

## 0.0.5

- Add `loadingBuilder` for fully custom loading UI (optional progress for network images).
- Improve docs and screenshots for pub.dev.

## 0.0.4

- Initial release.
