import "package:ssg/html/body.dart";
import "package:ssg/html/head.dart";
import "package:ssg/utils.dart";

abstract class Element {
  Iterable<Element> children;
  String? id;
  Iterable<String>? classes;
  Iterable<String>? inlineStyles;

  Element({
    required this.children,
    this.id,
    this.classes,
    this.inlineStyles,
  });

  String get modifiers => "${id.id()}${classes.classes()}${inlineStyles.styles()}";

  String build();
}

class HTML extends Element {
  String lang;
  Head head;
  Body body;

  HTML({
    required this.lang,
    required this.head,
    required this.body,
  }) : super(children: []);

  @override
  String build() {
    return '<html lang="$lang">\n'
        "${head.build()}\n\n"
        "${body.build()}\n"
        "</html>";
  }
}
