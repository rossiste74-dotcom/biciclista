import 'dart:io';
import 'package:image/image.dart';

void main() async {
  final path = 'assets/icon.png';
  final outPath = 'assets/icon_adaptive_foreground.png';

  print('Reading $path...');
  final file = File(path);
  if (!file.existsSync()) {
    print('Error: $path not found');
    exit(1);
  }

  final bytes = await file.readAsBytes();
  final image = decodePng(bytes);

  if (image == null) {
    print('Error: Could not decode image');
    exit(1);
  }

  print('Original size: ${image.width}x${image.height}');

  // Target scale factor (e.g. 0.75 to reduce by 25%)
  // Android adaptive icon mask is circle of diameter 72dp within 108dp.
  // 72/108 = 0.66. So the safe zone is roughly 66% of the size.
  // If the icon is currently full bleed, it will be cut.
  // Reducing to 70% should be safe.
  final double scale = 0.8;

  final int newWidth = (image.width * scale).round();
  final int newHeight = (image.height * scale).round();

  print('Resizing content to: ${newWidth}x$newHeight...');

  final resized = copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: Interpolation.cubic,
  );

  // Create a new image with original dimensions and transparent background
  final canvas = Image(width: image.width, height: image.height);
  // Image is initialized with 0 (transparent) by default in some versions, but let's be safe
  // clear(canvas, color: ColorRgba8(0, 0, 0, 0)); // Not needed if default is 0

  // Center the resized image
  final x = (image.width - newWidth) ~/ 2;
  final y = (image.height - newHeight) ~/ 2;

  print('Compositing at $x,$y...');

  compositeImage(canvas, resized, dstX: x, dstY: y);

  print('Saving to $outPath...');
  await File(outPath).writeAsBytes(encodePng(canvas));
  print('Done.');
}
