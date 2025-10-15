import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class Image extends Element {
  String src;
  String alt;

  Image({required this.src, required this.alt});

  @override
  String build() {
    return '<img src="$src" alt="${alt.escape()}">';
  }
}

class Em extends Element {
  Iterable<Element> children;

  Em({required this.children});

  @override
  String build() {
    return "<em>"
        "${children.map((el) => el.build()).join()}"
        "</em>";
  }
}
