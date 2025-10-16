import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Image extends Element {
  String src;
  String alt;

  Image({
    required this.src,
    required this.alt,
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return '<img src="$src" alt="${alt.escape()}"$modifiers>';
  }
}
