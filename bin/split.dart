import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('/Users/stefanorossi/.gemini/antigravity/brain/31e09489-3c13-4c55-90a3-b170f59d4f7d/media__1773229607451.png');
  if (!file.existsSync()) {
    print('File not found!');
    return;
  }
  final image = decodeImage(file.readAsBytesSync());
  if (image == null) {
    print('Could not decode image');
    return;
  }
  
  final w = image.width ~/ 3;
  final h = image.height;
  
  final outDir = Directory('assets/ranks');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  
  // Left is Gregario, Middle is Capitano, Right is Presidente
  final r1 = copyCrop(image, x: 0, y: 0, width: w, height: h);
  final r2 = copyCrop(image, x: w, y: 0, width: w, height: h);
  final r3 = copyCrop(image, x: w * 2, y: 0, width: w, height: h);
  
  File('${outDir.path}/gregario.png').writeAsBytesSync(encodePng(r1));
  File('${outDir.path}/capitano.png').writeAsBytesSync(encodePng(r2));
  File('${outDir.path}/presidente.png').writeAsBytesSync(encodePng(r3));
  
  print('Done splitting images');
}
