import "package:ssg/html/body.dart";
import "package:ssg/html/head.dart";

abstract class Element {
  String build();
}

class HTML extends Element {
  String lang;
  Head head;
  Body body;

  HTML({required this.lang, required this.head, required this.body});

  @override
  String build() {
    return '<html lang="$lang">\n'
        "${head.build()}\n\n"
        "${body.build()}\n"
        "</html>";
  }
}
