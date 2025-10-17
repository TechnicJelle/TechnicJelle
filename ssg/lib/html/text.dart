import "package:ssg/html/base.dart";

class T extends Element {
  String text;

  T(this.text) : super(children: []);

  T.single(Iterable<Element> elements) : text = elements.map((el) => el.build()).join(), super(children: []);

  T.multiline(Iterable<Element> lines) : text = lines.map((el) => el.build()).join("<br>\n"), super(children: []);

  @override
  String build() {
    return text;
  }
}

class P extends Element {
  P({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  P.text(String text) : super(children: [T(text)]);

  @override
  String build() {
    return "<p$modifiers>"
        '${children.map((el) => el.build()).join("\n")}'
        "</p>";
  }
}

class A extends Element {
  String href;

  A({
    required this.href,
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return '<a href="$href"$modifiers>\n'
        '${children.map((el) => el.build()).join("\n")}\n'
        "</a>";
  }
}

class Span extends Element {
  Span({
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<span$modifiers>"
        '${children.map((el) => el.build()).join(" ")}'
        "</span>";
  }
}

class Summary extends Element {
  String summary;

  Summary(
    this.summary, {
    super.id,
    super.classes,
    super.inlineStyles,
  }) : super(children: []);

  @override
  String build() {
    return "<summary$modifiers>$summary</summary>";
  }
}

class Details extends Element {
  Summary summary;

  Details({
    required this.summary,
    required super.children,
    super.id,
    super.classes,
    super.inlineStyles,
  });

  @override
  String build() {
    return "<details$modifiers>\n"
        "${summary.build()}\n"
        '${children.map((el) => el.build()).join("\n")}\n'
        "</details>";
  }
}

class Em extends Element {
  Em({required super.children});

  @override
  String build() {
    return "<em>"
        "${children.map((el) => el.build()).join()}"
        "</em>";
  }
}
