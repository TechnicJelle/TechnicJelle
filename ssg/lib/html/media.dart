import "dart:io";

import "package:image/image.dart" as img;
import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Image extends Element {
  String src;
  String alt;
  int? width;
  int? height;

  bool autoSize;

  Image({
    required this.src,
    required this.alt,
    super.id,
    super.classes,
    super.inlineStyles,
    this.width,
    this.height,
    this.autoSize = true,
  }) : super(children: []);

  @override
  String build() {
    return '<img src="$src" alt="${alt.escape()}"$imageSize$modifiers>';
  }

  String get imageSize {
    if (width != null && height != null) {
      return " width=$width height=$height";
    }
    if (width != null) {
      return " width=$width";
    }
    if (height != null) {
      return " height=$height";
    }
    if (autoSize) {
      final file = File(src);
      if (file.existsSync()) {
        final img.Image? imageData = img.decodeImage(file.readAsBytesSync());
        if (imageData == null) return "";
        inlineStyles = [
          "max-width: 100%",
          "height: auto",
          "max-height: ${imageData.height}px",
          ...inlineStyles ?? [],
        ];
        return " width=${imageData.width} height=${imageData.height}";
      }
    }
    return "";
  }
}
