import 'dart:typed_data';
import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

/// Displays a BlurHash-decoded color preview while the real image loads
class BlurHashPlaceholder extends StatefulWidget {
  const BlurHashPlaceholder({
    super.key,
    required this.blurHash,
    this.width,
    this.height,
  });

  final String blurHash;
  final double? width;
  final double? height;

  @override
  State<BlurHashPlaceholder> createState() => _BlurHashPlaceholderState();
}

class _BlurHashPlaceholderState extends State<BlurHashPlaceholder> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  void _decode() {
    try {
      // BlurHash.decode() returns a BlurHash object
      // .toImage(w, h) converts it to img.Image
      final decoded = BlurHash.decode(widget.blurHash).toImage(32, 32);
      final png = img.encodePng(decoded);
      if (mounted) {
        setState(() => _imageBytes = Uint8List.fromList(png));
      }
    } catch (_) {
      // Silently fall back to grey box on invalid hash
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: const Color(0xFFE0E0E0),
      );
    }

    return Image.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.none,
    );
  }
}
