import "package:ssg/html/base.dart";
import "package:ssg/utils.dart";

class T extends Element {
  String text;

  T(this.text);

  T.single(Iterable<Element> elements)
      : text = elements.map((el) => el.build()).join();

  T.multiline(Iterable<Element> lines)
      : text = lines.map((el) => el.build()).join("<br>\n");

  @override
  String build() {
    return text;
  }
}

class P extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

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
  Iterable<Element> children;
  Iterable<String>? classes;

  A({required this.href, required this.children, this.classes});

  @override
  String build() {
    return '<a href="$href"${classes.classes()}>\n'
        '${children.map((el) => el.build()).join("\n\n")}\n'
        "</a>";
  }
}

class Span extends Element {
  Iterable<Element> children;
  Iterable<String>? classes;

  Span({required this.children, this.classes});

  @override
  String build() {
    return "<span${classes.classes()}>"
        '${children.map((el) => el.build()).join(" ")}'
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
  Iterable<Element> children;

  Details({required this.summary, required this.children});

  @override
  String build() {
    return "<details>\n"
        "${summary.build()}\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</details>";
  }
}
