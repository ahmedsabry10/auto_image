/// omni_image — A unified Flutter image widget
///
/// Handles network, asset, file, base64, and SVG images
/// with a single consistent API.
library omni_image;

export 'src/omni_image_widget.dart';
export 'src/models/image_shape.dart';
export 'src/models/image_placeholder.dart';
export 'src/models/retry_config.dart';
export 'src/models/cache_config.dart';
export 'src/transform/image_transform.dart';
export 'src/preloader.dart';
export 'src/source/source_detector.dart' show ImageSourceType;
