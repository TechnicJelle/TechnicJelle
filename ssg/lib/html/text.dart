import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class T extends Element {
  String text;

  T(this.text);

  T.single(List<Element> elements)
    : text = elements.map((el) => el.build()).join();

  T.multiline(List<Element> lines)
    : text = lines.map((el) => el.build()).join("<br>\n");

  @override
  String build() {
    return text;
  }
}

class P extends Element {
  List<Element> children;
  List<String>? classes;

  P({required this.children, this.classes});

  P.text(String text) : children = [T(text)];

  @override
  String build() {
    return "<p${classes.classes()}>"
        '${children.map((el) => el.build()).join("\n")}'
        "</p>";
  }
}

class A extends Element {
  String href;
  List<Element> children;
  List<String>? classes;

  A({required this.href, required this.children, this.classes});

  @override
  String build() {
    return '<a href="$href"${classes.classes()}>\n'
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</a>";
  }
}

class Span extends Element {
  List<Element> children;
  List<String>? classes;

  Span({required this.children, this.classes});

  @override
  String build() {
    return "<span${classes.classes()}>\n"
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</span>";
  }
}

class Summary extends Element {
  String summary;

  Summary(this.summary);

  @override
  String build() {
    return "<summary>$summary</summary>";
  }
}

class Details extends Element {
  Summary summary;
  List<Element> children;

  Details({required this.summary, required this.children});

  @override
  String build() {
    return "<details>\n"
        "${summary.build()}\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</details>";
  }
}
